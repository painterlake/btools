if [ ! -d "${USERPATH}btools/binary/VirtualEnvLocation" ];then
    sudo apt-get install virtualenv \
    && mkdir -p ${USERPATH}btools/binary/VirtualEnvLocation \
    && cd ${USERPATH}btools/binary/VirtualEnvLocation \
    && virtualenv -p /usr/bin/python2.7 venv \
    && source venv/bin/activate \
    && pip install lxml pymssql==2.1.4 GitPython requests python-dateutil elasticsearch semantic-version enum
   
fi
cd ${USERPATH}btools/binary/VirtualEnvLocation
virtualenv -p /usr/bin/python2.7 venv
source venv/bin/activate
cd -
