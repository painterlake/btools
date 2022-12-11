
#!/bin/bash
#
#   This script will Improve the efficiency of multipass usage
#   1. multipassl:multipass list
#   2. multipassa:multipass shell name
#   3. multipassk: multipass stop name1, name2,...
#

multipass_install(){
    cat ${USERPATH}btools/multipass/multipass_install.txt
}

multipass_ls(){
    sudo multipass list
}

multipass_attach(){
    if [ $# -ne 1 ];then
        echo "Failed: too session name"
        return
    fi
    sudo multipass shell  $1
}

multipass_new(){
    if [ $# -ne 2 ];then
        echo "Failed: too session name"
        return
    fi
    sudo multipass launch $1 --name $2 --mem 2G --disk 10G --cpus 2
}

multipass_kill(){
    if [ $# -lt 1 ];then
        echo "Failed: too less name"
        return
    fi
    for name in $@
    do
    sudo  multipass stop $name
    done
}

ret=$(which multipass)
if [ -z "$ret" ];then
    echo -e "\nFailed: please install multipass !!!\n"
    multipass_install
fi

while [ -n "$1" ]
    do
        case "$1" in
            -l|--ls)
                multipass_ls
                exit
                ;;
            -n|--new)
                shift
                multipass_new $@
                exit
                ;;
            -a|--attach)
                shift
                multipass_attach $@
                exit
                ;;
            -k|--killl)
                shift
                multipass_kill $@
                exit
                ;;
            *)
                echo -e "\nFailed: nerror args!\n"
                exit
                ;;
        esac
    done