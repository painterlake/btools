#!/bin/bash
#
# 1. 利用dtx_diff把device上dts反编译出来。
#

pull_dts(){
    adb root
    sleep 2
    name=$(adb shell cat /proc/device-tree/model)
    name=${name:28}.dts
    name=${name/ /-}
    name=${name/_/-}
    if [ ! -d device-tree ];then
        adb pull /proc/device-tree/
    fi
    bash ${USERPATH}tools/dts/dtx_diff device-tree > ${name}
}

usage(){
    echo -e "-p|--pull"
    echo -e "\tDescription: adb pull devicetree from devices"
    echo -e "\tUsage: dts -p"
    echo -e "\tFor example: dts -p"

    echo -e "-h|--help"
    echo -e "\tDescription: show how to use this script"
    echo -e "\tUsage: dts -h"
    echo -e "\tFor example: dts -h"
}

while [ -n "$1" ]
    do
        case "$1" in
            -p|--pull)
                pull_dts
                exit
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
