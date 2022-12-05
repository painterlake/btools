#!/bin/bash
#
# binary fresh !
#
# This script is used to keep your binary fresh on below tool:
#   1. lint_tools
#
# You need add this script to your crontab, here is the steps
# 1. crontab -e
# 2. 30 3 * * *  bash <USERPATH>/tools/bin_fresh/bin_fresh.sh >/dev/null 2>&1
# 3. for example: 30 3 * * *  bash /local/mnt2/workspace/bozhang/tools/bin_fresh/bin_fresh.sh >/dev/null 2>&1

USERPATH="/home/bozhang/"
LINT_TOOL="${USERPATH}btools"

if [ -d "${LINT_TOOL}" ];then
    cd ${LINT_TOOL}
    git pull
fi