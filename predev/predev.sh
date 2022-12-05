#!/bin/bash
#
#   This script will improve the efficiency of debugging
#

usage(){
    echo -e "-c|--collectinfo"
    echo -e "\tDescription: collect device infomation,such as serial boot logs,cdt,dts,defconfig,build info,adb dmesg,adb logcat,/firmware info,subsystem info"
    echo -e "\tUsage: predev -c"
    echo -e "\tFor example: predev -c"

    echo -e "-h|--help"
    echo -e "\tDescription: show how to use this script"
    echo -e "\tUsage: prelog -h"
    echo -e "\tFor example: prelog -h"
}

ADB_STATUS="adb"
FASTBOOT_STATUS="fastboot"
devices_status=""
CURRENT_PATH=$(pwd)
DEV_PATH="${USERPATH}devs/"
LOG_PATH="${USERPATH}logs/"
SERIAL_LOGS="serial-boot.log"
cd $DEV_PATH

get_devices_status(){
    local status=""

    status=$(fastboot devices)
    status=$(fastboot devices)
    if [ -n "$status" ];then
        devices_status=$FASTBOOT_STATUS
    fi

    status=$(adb devices)
    status=$(adb devices)
    if [ "$status" != "List of devices attached" ];then
        devices_status=$ADB_STATUS
    fi

    if [ -z $devices_status ];then
        echo "Failed: No adb devices or fastboot devces"
        devices_status=$ADB_STATUS
        exit
    fi
}

wait_for_devices(){
    local time_counter=0
    local adb_status=""
    local fastboot_status=""

    adb_status=$(adb devices)
    fastboot_status=$(fastboot devices)
    while [ "$adb_status" = "List of devices attached" ] && [ -z "$fastboot_status" ] && [ $time_counter -lt 45 ]
    do
        time_counter=$((time_counter+1))
        sleep 2
        adb_status=$(adb devices)
        fastboot_status=$(fastboot devices)
    done
    if [ "$adb_status" != "List of devices attached" ];then
        echo "adb is online"
        devices_status=$ADB_STATUS
    elif [ -n "$fastboot_status" ];then
        devices_status=$FASTBOOT_STATUS
        echo "fastboot is online"
    else
        echo "Warning: 90s passed, devices is not on adb or fastboot "
        devices_status=""
    fi
}

get_serial_boot_logs(){
    session_name_boot="serial_log"
    tmux new -s "${session_name_boot}" -d
    tmux send -t "${session_name_boot}" "cd ${USERPATH}logs && ${USERPATH}tools/prelog/prelog.sh" ENTER
    tmux attach -t "${session_name_boot}"
    
    $devices_status reboot
    wait_for_devices
    tmux kill-session -t ${session_name_boot}
    if [ -n "$devices_status" ];then
        cp ${LOG_PATH}latest.log ${DEV_PATH}${SERIAL_LOGS}
        echo "Success: get serial boot logs!"
    else
        echo "Failed: get serial boot logs!"
    fi
}

get_cdt(){
    cdt=$(grep -rn "CDT Version" ${SERIAL_LOGS})
    echo $cdt > cdt.log
    echo "Success: get cdt !"
}

get_dts(){
    wait_for_devices
    bash ${USERPATH}tools/dts/dts.sh -p
}

get_defconfig(){
    adb root
    name=$(adb shell cat /sys/devices/soc0/machine)
    adb shell zcat /proc/config.gz > $name.defconfig
}

get_build_info(){
    adb root
    adb pull /vendor/firmware_mnt/verinfo/ver_info.txt build-info.txt
}

get_dmesg(){
    adb root
    adb shell dmesg > dmesg.log
}

get_logcat(){
    adb root
    adb shell logcat -b all -d > logcat.log
}

get_firmware_info(){
    adb root
    adb shell ls /vendor/firmware_mnt/image/ > firmware.log
}

get_firmware_info(){
    adb root
    adb shell ls /vendor/firmware_mnt/image/ > firmware.log
}

get_subsystem_info(){
    adb root
    adb shell cat /sys/class/remoteproc/remoteproc*/name  > subsystem-info.log
    adb shell cat /sys/class/remoteproc/remoteproc*/state >> subsystem-info.log
}

get_mount_info(){
    adb root
    adb shell mount  > mount.log
}

# 1. serial boot logs
# 2. cdt
# 3. dts
# 4. defconfig
# 5. build info
# 6. adb dmesg
# 7. adb logcat
# 8. /firmware info
# 9. subsystem info
# 10. mount info
collect_info(){
    get_devices_status
    get_serial_boot_logs
    get_cdt
    get_dts
    get_defconfig
    get_build_info
    get_dmesg
    get_logcat
    get_firmware_info
    get_subsystem_info
    get_mount_info
}

while [ -n "$1" ]
    do
        case "$1" in
            -c|--collectinfo)
                shift
                collect_info $@
                return
                ;;
            -h|--help)
                usage
                return
                ;;
            *)
                echo -e "\nFailed: error args!\n"
                exit
                ;;
        esac
    done
