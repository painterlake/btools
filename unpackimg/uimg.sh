if [ ! -d "${USERPATH}btools/binary/unpackimg" ];then
    mkdir -p ${USERPATH}btools/binary/ \
    && cd ${USERPATH}btools/binary/ \
    && wget https://forum.xda-developers.com/attachments/aik-linux-v3-8-all-tar-gz.5300923/ \
    && mv index.html AIK-Linux-v3.8-ALL.tar.gz \
    && tar -xzvf AIK-Linux-v3.8-ALL.tar.gz \
    && rm AIK-Linux-v3.8-ALL.tar.gz \
    && mv AIK-Linux unpackimg
fi
cd ${USERPATH}btools/binary/unpackimg