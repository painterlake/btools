#!/bin/bash
#
# install tool !
#
# This script is used to install the tool on your ubuntu host:
#   

userpath="/home/bozhang/"
usage(){
    echo -e "\nDescription: install tool"
    echo -e "Usage: ./toolinstall.sh <userpath>(optional)"
    echo -e "For example: ./toolinstall.sh \"/home/bozhang/\"\n"
}

if [ $# -gt 1 ];then
    echo "Failed: error args!"
    usage
    exit
elif [ $# -eq 1 ];then
    userpath="$1"
    if [ "${userpath:0:1}" != "/" ];then
        echo "Failed: must use absolute path, eg: /home/bozhang/"
        exit
    fi
else
    echo using the default instll path: ${userpath}
fi

setup_env(){
    sudo apt install tmux
}

clone_Repository(){
# git clone this Repository
    if [ ! -d "${userpath}btools" ];then
        echo "downloading btools ..."
        mkdir -p ${userpath}
        cd ${userpath}
        git clone https://github.com/painterlake/btools
    fi
}

delete_code(){
    local fd=""
    remove_path="${USERPATH}remove"
    mkdir -p "${remove_path}"
    for fd in $*
    do
        mv "${fd}" "${remove_path}"
    done
    tmux new -s "precode_remove" -d
    tmux send -t "precode_remove" "rm ${remove_path} -rf" ENTER
}

copy_bash_config(){
    # copy bash config
    cp ${userpath}btools/toolmanage/bash_config/.bash_custom ${HOME}/ -f
    echo ". ${HOME}/.bash_custom" >> ${HOME}/.bashrc
    . ${HOME}/.bashrc
    sed '1c export USERPATH=${userpath}' ${HOME}/.bash_custom
}

config_custom_directory(){
    mkdir -p ${userpath}apss
    mkdir -p ${userpath}always_devices
    mkdir -p ${userpath}test
    mkdir -p ${userpath}logs
    mkdir -p ${userpath}devs
    mkdir -p ${userpath}home
    mkdir -p ${userpath}btools/binary/flash_imag
}

keep_binary_fresh(){
    echo -e "\n==============================================================================="
    echo "=   * follow below steps to keep your bins fresh *"
    echo "="                                                                     
    echo "=       1. crontab -e"        
    echo "=       2. 30 3 * * * bash ${userpath}btools/bin_fresh/bin_fresh.sh >/dev/null 2>&1"
    echo "="
    echo -e "===============================================================================\n"
}

setup_env
clone_Repository
copy_bash_config
config_custom_directory
keep_binary_fresh
