#!/bin/bash
#
# 1. 自动检测未锁定的设备，如果有多个则列出给用户选择，如果只有一个则直接使用。
# 2. 默人加载 /etc/minicom/minirc.${dev} 的配置文件。
# 3. 自动保存 log 到 / tmp 目录，退出时，询问是否要保存到另外的目录。
#

log_start(){
    local ports_USB ports_ACM ports datename dev devs dev_count

    ports_USB=$(ls /dev/ttyUSB* 2>/tmp/null | xargs -I {} basename {})
    ports_ACM=$(ls /dev/ttyACM* 2>/tmp/null | xargs -I {} basename {})
    ports="$ports_USB $ports_ACM"

    #check lock
    devs=""
    dev_count=0
    for dev in ${ports}; do
        ! ls /run/lock/*"${dev}"* &>/dev/null && {
            devs+="${dev} "
            ((dev_count++))
        }
    done
    [ -z "$devs" ] && echo "No Unlock Devices" && return 0

    datename=$(date +%Y%m%d-%H%M%S)
    if [ $dev_count -eq 1 ]; then
        dev=$devs
    else
        #select dev to open
        echo "Please select one device: (Ctrl+C to abort)"
        select dev in $devs; do
            if [ "$dev" ]; then
                echo "You select the '$dev'"
                break
            else
                echo "Invaild selection"
            fi
        done
    fi

    out="${LOG_DIR}/$(basename ${dev}).$datename.log"
    ln -sf "${out}" "${LOG_DIR}/latest.log"

    minicom -D /dev/$dev -C "${out}" "$@"

    if [ -n "$rename_flag" ];then
        [ -f "${out}" ] && {
            echo log : "${out}"
                read -p "Enter file name > " keep_file_name

                [ x"$keep_file_name" = x"" ] && keep_file_name="$(basename "${out}")_back"

                mkdir -p "$LOG_DIR"
                cp "${out}" "${LOG_DIR}/$keep_file_name"
                echo "saved in $LOG_DIR/$keep_file_name"

        }
    fi

    if [ -n "$view_flag" ];then
        vim "${out}"
    fi
}

log_view(){
    [ ! -f "${LOG_DIR}/latest.log" ] && echo "Failed: no logs" && exit
    vim "${LOG_DIR}/latest.log"
}

log_clean(){
    set -x
    rm ${LOG_DIR}/* -rf
}

usage(){
    echo -e "Full usage: prelog -r -v"
    echo -e "For example: prelog -r -v\n"
    echo -e "Sub usage:"

    echo -e "-r|--rename"
    echo -e "\tDescription: save as the log file"
    echo -e "\tUsage: prelog -r"
    echo -e "\tFor example: prelog -r"

    echo -e "-v|--view"
    echo -e "\tDescription: view the log file after start minicom"
    echo -e "\tUsage: prelog -vo"
    echo -e "\tFor example: prelog -vo"

    echo -e "-vo|--viewonly"
    echo -e "\tDescription: view saved latest log at any time"
    echo -e "\tUsage: prelog -vo"
    echo -e "\tFor example: prelog -vo"

    echo -e "-co|--clean"
    echo -e "\tDescription: clean all saved logs at any time"
    echo -e "\tUsage: prelog -co"
    echo -e "\tFor example: prelog -co"

    echo -e "-h|--help"
    echo -e "\tDescription: show how to use this script"
    echo -e "\tUsage: prelog -h"
    echo -e "\tFor example: prelog -h"
}

prepare(){
    local minicom
    minicom=$(which minicom)
    if [ -z "${minicom}" ];then
        echo "Failed: please setup minicom firstly"
        echo "refering to https://blog.csdn.net/houxiaoni01/article/details/124173845"
    fi
}

LOG_DIR="${USERPATH}logs"
rename_flag=""
view_flag=""

while [ -n "$1" ]
    do
        case "$1" in
            -r|--rename)
                shift
                rename_flag="1"
                ;;
            -v|--view)
                shift
                view_flag="1"
                ;;
            -vo|--viewonly)
                shift
                log_view $@
                exit
                ;;
            -co|--cleanonly)
                shift
                log_clean
                exit
                ;;
            -h|--help)
                usage
                exit
                ;;
            *)
                echo -e "\nFailed: error args!\n"
                exit
                ;;
        esac
    done

log_start
