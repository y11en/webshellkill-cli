FROM alpine

ENV LANG=zh_CN.UTF-8 \
    LC_ALL=zh_CN.UTF-8 \
    DISPLAY=:99

COPY docker-items/d99net.reg /tmp/d99net.reg
COPY docker-items/override.reg /tmp/override.reg
COPY docker-items/run-xvfb /usr/local/bin/run-xvfb

RUN echo "x86" > /etc/apk/arch && \
    chmod +x /usr/local/bin/run-xvfb && \
	apk add --no-cache wine xvfb wget unzip ncurses-libs cabextract

RUN	WINEARCH=win32 wine wineboot && \
    wine regedit.exe /s /tmp/d99net.reg && \
    wine regedit.exe /s /tmp/override.reg && \
    mkdir /tmp/mdac && \
    wget https://download.microsoft.com/download/4/a/a/4aafff19-9d21-4d35-ae81-02c48dcbbbff/MDAC_TYP.EXE -O /tmp/mdac/mdac.exe && \
    cd /tmp/mdac && cabextract mdac.exe && cabextract *.cab && rm -rf *.cab && cp * /root/.wine/drive_c/windows/system32/ && \
    # for unknown reason `regsvr32` run under Dockerfile and /bin/sh will make different results...
    # So that i directly copied ``system.reg``
    rm -rf /tmp/mdac && cd /

ENV WEBSHELLKILL_URL=http://d99net.net/down/WebShellKill_V2.0.9.zip \
    VERSION_DLL=https://github.com/zsxsoft/webshellkill-cli/releases/download/0.0.2/Version.dll \
    DISPLAY=:99

COPY docker-items/run.sh /usr/local/bin/webshellkill
# This system.reg is generated by 
# cd /tmp/mdac && for i in *.dll; do wine regsvr32 "c:\\windows\\system32\\$i"; echo $i; done
COPY docker-items/system.reg /root/.wine/system.reg

RUN wget $WEBSHELLKILL_URL -O /root/webshellkill.zip && \
	wget $VERSION_DLL -O /root/version.dll && \
    echo 'Unzipping WebShellKill ...' && \
    cd /root && LC_ALL=zh_CN.UTF-8 unzip /root/webshellkill.zip && \
    rm /root/webshellkill.zip && \
    chmod +x /usr/local/bin/webshellkill

ENTRYPOINT ["webshellkill"]