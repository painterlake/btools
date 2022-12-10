cd ${USERPATH}btools
VERSION="Version information: "
OTHER=$1
cp ~/.bash_custom ${USERPATH}btools/toolmanage/bash_config -f

git add --all
git commit -m "${VERSION} <${OTHER}>"
git push origin master