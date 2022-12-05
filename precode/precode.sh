#!/bin/bash
# Preare CodeBase!
# This script is used to improve your work efficiency on below function:
#   1. download APSS AU code
#   2. build APSS AU code
#   3. show what code has been downloaded
#   4. delete discarded APSS AU code

show_status(){
    for chipname in ${!precode_sp[@]}
    do
        if [ $# -eq 3 ] && [! "${chipset_array[@]}" =~ "$2"];then
            echo -e "\n No such chipset: $2 \n"
            exit 
        elif [ $# -eq 2 ] && [ "${chipname}" != "$2" ];then
            continue
        fi
        echo -e "\nChipset: ${chipname}"
        sp_array=(${precode_sp[${chipname}]//,/ })
        for spname in ${sp_array[@]}
        do
            echo -e "\t""SP: ${spname}"
            if [ ! -d "${DLPATH}${chipname}" ];then
                echo -e "\t\t""No downloaded AU"
                continue
            fi
            sppaths=$(find ${DLPATH}${chipname} -maxdepth 1 -name ${spname}"*")
            if [ -z "${sppaths}" ];then
                echo -e "\t\t""No downloaded AU"
                continue
            fi
            sppath_array=(${sppaths//,/ })
            sp_aus=""
            for sppath in ${sppath_array[@]}
            do
                downloaded_au=$(find ${sppath}/AU_*/.precode_log -name $(basename ${MISC_INFO_FLAG}))
                sp_aus="${downloaded_au} ${sp_aus}"
            done
            sp_aus_stripped=${sp_aus// /}
            if [ -z "${sp_aus_stripped}" ];then
                    echo -e "\t\t""No downloaded AU"
                    continue
            fi
            sp_au_array=(${sp_aus//,/ })
            for sp_au in ${sp_au_array[@]}
            do
                sp_au=${sp_au%/*}
                echo -e "\t\t"${sp_au%/*}
            done
        done
    done
    echo ""
    exit
}

show_information(){
    for chipname in ${!precode_sp[@]}
    do
        echo -e "\nChipset: ${chipname}"
        sp_array=(${precode_sp[${chipname}]//,/ })
        for spname in ${sp_array[@]}
        do
           echo -e "\tSP: ${spname}"
           echo -e "\t\tWIKI: ${precode_wiki[${spname}]}"
           echo -e "\t\tMETA: ${precode_meta[${spname}]}"
        done
    done
    echo ""
}

show_registered(){
    for chipname in ${!precode_sp[@]}
    do
        echo -e "\nChipset: ${chipname}"
        sp_array=(${precode_sp[${chipname}]//,/ })
        for spname in ${sp_array[@]}
        do
           echo -e "\t""SP: ${spname}"
        done
    done
    echo ""
}

kill_tmux(){
    tmux list-sessions | awk 'BEGIN{FS=":"}{print $1}' | xargs -n 1 tmux kill-session -t
}

delete_code(){
    remove_path="${USERPATH}remove"
    mkdir -p "${remove_path}"
    for fd in $*
    do
        mv "${fd}" "${remove_path}"
    done
    tmux new -s "precode_remove" -d
    tmux send -t "precode_remove" "rm ${remove_path} -rf" ENTER
}

get_fix(){
    FIX_NUMBER=0
    FIX=""
    FIX_TYPE=""
    FIX_TYPE=$1

    while [ -n "$2" ]
        do
            case "${2:0-1}" in
                [0-9])
                    FIX="${FIX} $2"
                    FIX_NUMBER=$((FIX_NUMBER+1))
                    shift
                    ;;
                *)
                    break
                    ;;
            esac
        done
    if [ -n "${FIX}" ] && [ ${FIX_TYPE} = "manifest" ];then
        fix_manifest=${FIX}
        fix_manifest_number=${FIX_NUMBER}
        fix_manifest_commands="${fix_manifest_commands} && apply_changes ${fix_manifest}"
    fi
    if [ -n "${FIX}" ] && [ ${FIX_TYPE} = "regular" ];then
        fix_regular="${FIX}"
        fix_regular_number=${FIX_NUMBER}
        fix_regular_commands="${fix_manifest_commands} && apply_changes ${fix_regular}"
    fi
}

check_param(){
    if [[ ! "${chipset_array[@]}" =~ "${chipset}" ]];then
        echo "error chipset: "${chipset}
        exit
    fi
    if [[ ! "${sp_array[@]}" =~ "${sp}" ]];then
        echo "error sp: "${sp}
        exit
    fi
        if [[ ! "${au_tag}" =~ "AU_" ]];then
        echo "error AU: "${au_tag}
        exit
    fi
}

# It will just download the tools, if you want to update it please use <USERPATH>/tools/bin_fresh/bin_fresh.sh
check_tool(){
    #check lint tools
    if [ ! -d "${LINT_TOOL}" ];then
        cd ${USERPATH}tools/binary/
    fi

}

create_dir(){
    if [[ -f "${path_orign}/${MISC_INFO_FLAG}" ]] && [[ -f "${path_goal}/${MISC_INFO_FLAG}" ]];then
        echo "error: code already synced"
        echo "path orign: ${path_orign}"
        echo "path goal: ${path_goal}"
        exit
    fi
    if [ ! -f "${path_orign}/${MISC_INFO_FLAG}" ];then
        mkdir -p "${path_orign}/${LOG_PATH}"
    fi
    if [ ! -f "${path_goal}/${MISC_INFO_FLAG}" ];then
        mkdir -p "${path_goal}/${LOG_PATH}"
    fi
}

get_tmux_commands(){
    if [ "${sync_flag}" = "1" ];then
        download_commands="${precode_sync[${sp}]}"
    fi
    if [ "${build_flag}" = "1" ];then
        compile_commands="&& ${precode_build[${sp}]}"
    fi
    if [ "${copy_flag}" = "1" ];then
        copy_commands="&& bash ${SELF_NAME} -co"
    fi
    tmux_commands="${download_commands} ${compile_commands} ${copy_commands}"
}

precode_commands(){
    if [ ! -f "${path_goal}/${MISC_INFO_FLAG}" ];then
        echo "${sp} start download: ${goal}_${au_tag}"
        echo "download path: ${path_goal}"
        
        session_name_goal="${goal}_${au_tag}"
        session_name_goal=${session_name_goal//./_}
        tmux new -s "${session_name_goal}" -d
        tmux send -t "${session_name_goal}" "cd ${path_goal} && ${tmux_commands}" ENTER
        echo "${tmux_commands}" > ${path_goal}/${PRECODE_STEP_FLAG}
    fi
    if [ "${thin_flag}" = "1" ];then
        return
    fi
    if [ ! -f "${path_orign}/${MISC_INFO_FLAG}" ];then
        echo "${sp} start download: orign_${au_tag}"
        echo "download path: ${path_orign}"

        session_name_orign="orign_${au_tag}"
        session_name_orign=${session_name_orign//./_}
        tmux new -s "${session_name_orign}" -d
        tmux send -t "${session_name_orign}" "cd ${path_orign} && ${tmux_commands}" ENTER
        echo "${tmux_commands}" > ${path_orign}/${PRECODE_STEP_FLAG}
    fi
}

parase_variant(){
    if [ $# -gt 1 ];then
        echo "Failed: error args"
        exit
    elif [ $# -eq 1 ];then
        workspace=$1
    else
        workspace=$(pwd)
    fi

    if [ -f "${workspace}/${MISC_INFO_FLAG}" ];then
        chipset=$(sed -n '1p' ${workspace}/${MISC_INFO_FLAG})
        sp=$(sed -n '2p' ${workspace}/${MISC_INFO_FLAG})
        au_tag=$(sed -n '3p' ${workspace}/${MISC_INFO_FLAG})
        goal=$(sed -n '4p' ${workspace}/${MISC_INFO_FLAG})
    elif [ -f "${workspace}/../${MISC_INFO_FLAG}" ];then
        chipset=$(sed -n '1p' ${workspace}/../${MISC_INFO_FLAG})
        sp=$(sed -n '2p' ${workspace}/../${MISC_INFO_FLAG})
        au_tag=$(sed -n '3p' ${workspace}/../${MISC_INFO_FLAG})
        goal=$(sed -n '4p' ${workspace}/../${MISC_INFO_FLAG})
    else
        echo "Failed: can not find ${MISC_INFO_FLAG}"
        exit
    fi
}

copy_image(){
    remote_fd="${USERPATH}tools/binary/flash_image/${chipset}/${sp}_${goal}/${au_tag}"
    ssh ${REMOTE_USER}@${REMOTE_IP} "mkdir -p ${remote_fd}"

    for spname in ${!precode_image[@]}
    do
        if [ "${spname}" != "${sp}" ];then
            continue
        fi
        image_array=(${precode_image[${spname}]//,/ })
        for imagename in ${image_array[@]}
        do
            scp ${workspace}/${imagename} ${REMOTE_USER}@${REMOTE_IP}:${remote_fd}
        done
        exit
    done
    echo "Failed: No such ${sp} images"
}

build_only(){
    if [ -z "${precode_image[${sp}]}" ];then
        echo "Failed: No such ${sp} build commands"
    fi
    
    tmux_commands=${precode_build[${sp}]}
    session_name="build_only_${au_tag}"
    session_name=${session_name//./_}
    tmux new -s "${session_name}" -d
    tmux send -t "${session_name}" "cd ${workspace} && ${tmux_commands}" ENTER
    tmux attach -t ${session_name}
}

buildcopyimageonly(){
    if [ -z "${precode_image[${sp}]}" ];then
        echo "Failed: No such ${sp} build commands"
    fi
    
    tmux_commands="${precode_build[${sp}]} && bash ${SELF_NAME} -co"
    session_name="build_only_${au_tag}"
    session_name=${session_name//./_}
    tmux new -s "${session_name}" -d
    tmux send -t "${session_name}" "cd ${workspace} && ${tmux_commands}" ENTER
    tmux attach -t ${session_name}
}


flash_image(){
    if [ -z "${precode_flash[${sp}]}" ];then
        echo "Failed: No such ${sp} flash commands"
    fi
    remote_fd="${USERPATH}tools/binary/flash_image/${chipset}/${sp}_${goal}/${au_tag}"
    flash_commands="${precode_flash[${sp}]}"
    remote_fd="${USERPATH}tools/binary/flash_image/${chipset}/${sp}_${goal}/${au_tag}"
    ssh ${REMOTE_USER}@${REMOTE_IP} -t "adb devices; adb reboot bootloader; cd ${remote_fd}; ${flash_commands} && fastboot reboot && echo 'Success: flash all images and reboot device'"
}

define_misc_info(){
    # save misc information: Chipset, SP, AU, Goal, META
    misc_commands_info="echo ${chipset} > ${MISC_INFO_FLAG} && echo ${sp} >> ${MISC_INFO_FLAG} && echo ${au_tag} >> ${MISC_INFO_FLAG} && echo ${goal} >> ${MISC_INFO_FLAG} && echo ${meta_info} >> ${MISC_INFO_FLAG}"
}

define_fix_py(){
    fix_commands_py="${fix_manifest} ${fix_regular}"
    fix_commands_py_stripped=${fix_commands_py// /}
    if [ -n "${fix_commands_py_stripped}" ];then
            fix_commands_py="--hotfixes ${fix_commands_py}"
    fi
}

download_post(){
    cd ${ROOT_DIR}
    echo "Sucess: Already started download code"
    echo "tmux name:"
    echo -e "\t${session_name_goal}"
    echo -e "\t${session_name_orign}"
    sleep 2
    tmux attach -t ${session_name_goal}
    exit
}

usage(){
    echo -e "full usage: \n\texample: precode -a xxxx xxxxxxx bugfix -fm 123 -fr 456 -b -c -t -m <meta path>\n"
    echo -e "Sub usage:"

    echo -e "-a|--sync"
    echo -e "\tDescription: download APSS AU code"
    echo -e "\tUsage: precode -a <chipset>  <sp>  <au_tag>  <goal>"
    echo -e "\tFor example: precode -a xxx xxx xxx bugfix"

    echo -e "-fm|--fixmanifest"
    echo -e "\tDescription: apply manifest change when you download code"
    echo -e "\tUsage: precode -fm <manifest changes number>"
    echo -e "\tFor example: precode -a xxxx xxx xxx bugfix -fr 456"

    echo -e "-fr|--fixregular"
    echo -e "\tDescription: apply regular change when you download code"
    echo -e "\tUsage: precode -fr <regular changes number>"
    echo -e "\tFor example: precode -a xxxx xxx xxx bugfix -fr 456"

    echo -e "-b|--build"
    echo -e "\tDescription: build APSS AU code when you download code"
    echo -e "\tUsage: precode -b"
    echo -e "\tFor example: precode -a xxxx xxx xxx bugfix -b"

    echo -e "-c|--copyimage"
    echo -e "\tDescription: copy images when you download code"
    echo -e "\tUsage: precode -c"
    echo -e "\tFor example: precode -a xxxx xxx xxx bugfix -b -c"

    echo -e "-t|--thin"
    echo -e "\tDescription: once set, just download goal code not orign code; default download both"
    echo -e "\tUsage: precode -t"
    echo -e "\tFor example: precode -a xxxx xxx xxx bugfix -t"
    
    echo -e "-m|--meta"
    echo -e "\tDescription: echo meta info to misc log"
    echo -e "\tUsage: precode -m"
    echo -e "\tFor example: precode -a xxxx xxx xxx bugfix -m"

    echo -e "-bo|--buildonly"
    echo -e "\tDescription: build APSS AU code at any time"
    echo -e "\tUsage: precode -bo <workspace> or precode -bo"
    echo -e "\tFor example: precode -bo xxx"

    echo -e "-co|--copyimageonly"
    echo -e "\tDescription: copy images at any time"
    echo -e "\tUsage: precode -co <workspace> or precode -co"
    echo -e "\tFor example: precode -co xxx"

    echo -e "-bco|--buildcopyimageonly"
    echo -e "\tDescription: build and copy images at any time"
    echo -e "\tUsage: precode -bco <workspace> or precode -bco"
    echo -e "\tFor example: precode -bco xxx"

    echo -e "-fo|--flashimageonly"
    echo -e "\tDescription: flash images at any time"
    echo -e "\tUsage: precode -fo <workspace> or precode -fo"
    echo -e "\tFor example: precode -fo xxx"

    echo -e "-do|--deleteonly"
    echo -e "\tDescription: use tmux as background service to delete any workspace"
    echo -e "\tUsage: precode -do <workspace> or precode -do"
    echo -e "\tFor example: precode -do xxx"

    echo -e "-so|--status"
    echo -e "\tDescription: show all already downloaded workspace"
    echo -e "\tUsage: precode -so"
    echo -e "\tFor example: precode -so"

    echo -e "-io|--informationonly"
    echo -e "\tDescription: show downloaded APSS AU code"
    echo -e "\tUsage: precode -io <chipset>(optional)"
    echo -e "\tFor example: precode -io kona or precode -io"

    echo -e "-ko|--killonly"
    echo -e "\tDescription: kill all tmux process at any time"
    echo -e "\tUsage: precode -ko"
    echo -e "\tFor example: precode -ko"

    echo -e "-ro|--registered"
    echo -e "\tDescription: show what Chipset/SP has registerd"
    echo -e "\tUsage: precode -ro"
    echo -e "\tFor example: precode -ro"

    echo -e "-h|--help"
    echo -e "\tDescription: show how to use this script"
    echo -e "\tUsage: precode -h"
    echo -e "\tFor example: precode -h"

    echo -e "How to add a new SP"
    echo -e "\tDescription: show how to how to add a new SP in this script"
    echo -e "\t1. add chipset name in chipset_array=("
    echo -e "\t2. add sp name in sp_array=("
    echo -e "\t3. add sync command in define_sync()"
    echo -e "\t4. add precode_build, precode_image, precode_flash, precode_wiki, precode_meta,precode_sp"
}

define_sync(){
    precode_sync=([xxx]="xxx" \
            [xxx]="xxx" \
            [xx]="xxx")
}

chipset_array=(
xxx
xxx
)

sp_array=(
xxxxxxx
xxx
)

DLPATH="${USERPATH}apss/"
LOG_PATH=".precode_log/"
PRECODE_STEP_FLAG="${LOG_PATH}precode_step.log"
PRECODE_BUILD_FLAG="${LOG_PATH}precode_build.log"
MISC_INFO_FLAG="${LOG_PATH}precode_misc_info.log"
ROOT_DIR=$(pwd)
DATE=$(date +"%Y-%m-%d")
LINT_TOOL="${USERPATH}tools/binary/lint_tools"
REMOTE_IP="10.64.39.81"
REMOTE_USER="bozhang"
SELF_NAME=$0
build_flag=""
sync_flag=""
copy_flag=""
thin_flag=""
tmux_commands=""
fix_manifest=""
fix_manifest_number=0
fix_manifest_commands="echo fix_manifest_commands"
fix_regular=""
fix_regular_number=0
fix_regular_commands="echo fix_regular_commands"
meta_info=""
workspace=""

declare -A precode_build
declare -A precode_wiki
declare -A precode_meta
declare -A precode_sp
declare -A precode_image
declare -A precode_flash
declare -A precode_sync

precode_build=([xxx]="xxx" \
        [xxx]="xxx" \
        [xxx]="xxx" \
        [xxx]="echo TBD ....")

precode_image=([xxx]="xxxx" \
        [xxx]="xxx" \
        [kailua_qtvm]="TBD" \
        [xx]="TBD")
precode_flash=([xxx]="xxxx" \
        [xxx]="xxxx" \
        [kailua_qtvm]="TBD" \
        [xxx]="TBD")
precode_wiki=([xxx]="xxx" \
        [xxx]="xxx" \
        [xxxx]="https://confluence.qualcomm.com/confluence/display/MLP/Kalama+-+VM" \
        [xxx]="TBD ....")
precode_meta=([xxx]="xxx" \
        [xxx]="xxx" \
        [xxx]="TBD ....")
precode_sp=([xxx]="xxx,xxx" \
          [xxx]="xxx,xxx" \
          [xxx]="xxx,xxx")

while [ -n "$1" ]
    do
        case "$1" in
            -a|--sync)
                if [ $# -lt 5 ];then
                    usage
                    exit
                fi
                chipset=$2
                sp=$3
                au_tag=$4
                goal=$5
                sync_flag="1"
                echo "Starting: Target<${chipset}>, SP<${sp}>, AU<${au_tag}>, GOAL<${goal}>"
                shift 5
                ;;
            -fm|--fixmanifest)
                shift
                get_fix manifest $@
                shift ${fix_manifest_number}
                ;;
            -fr|--fixregular)
                shift
                get_fix regular $@
                shift ${fix_regular_number}
                ;;
            -t|--thin)
                thin_flag="1"
                shift
                ;;
            -b|--build)
                build_flag="1"
                shift
                ;;
            -c|--copyimage)
                copy_flag="1"
                shift
                ;;
            -m|--meta)
                shift
                meta_info="$1"
                shift
                ;;
            -bo|--buildonly)
                build_flag="1"
                shift
                parase_variant $@
                build_only
                exit
                ;;
            -co|--copyimageonly)
                shift
                parase_variant $@
                copy_image
                exit
                ;;
            -bco|--buildcopyimageonly)
                shift
                parase_variant $@
                build_copy_image
                exit
                ;;
            -fo|--flashimageonly)
                shift
                parase_variant $@
                flash_image
                exit
                ;;
            -do|--deleteonly)
                shift
                delete_code $@
                exit
                ;; 
            -so|--statusonly)
                show_status $@
                exit
                ;;
            -io|--informationonly)
                show_information $@
                exit
                ;;
            -ko|--killonly)
                kill_tmux
                exit
                ;;
            -ro|--registered)
                show_registered
                exit
                ;;
            -h|--help)
                usage
                exit
                ;;
            *)
                echo -e "\Failed: nerror args!\n"
                exit
                ;;
        esac
    done

define_misc_info
define_fix_py
define_sync
check_param ${chipset} ${sp}
check_tool
path_orign=${DLPATH}${chipset}/${sp}_orign/${au_tag}
path_goal=${DLPATH}${chipset}/${sp}_${goal}/${au_tag}
create_dir
get_tmux_commands
precode_commands
download_post
