FROM    debian:jessie

# Build variables
ENV     FILEBEAT_VERSION 5.4.0
ENV     FILEBEAT_URL https://download.elastic.co/beats/filebeat/filebeat-${FILEBEAT_VERSION}-x86_64.tar.gz

# Environment variables
ENV     FILEBEAT_HOME /opt/filebeat-${FILEBEAT_VERSION}-x86_64
ENV     PATH $PATH:${FILEBEAT_HOME}

WORKDIR /opt/

RUN     apk add --update python curl && \
        wget "https://circle-artifacts.com/gh/andyshinn/alpine-pkg-glibc/6/artifacts/0/home/ubuntu/alpine-pkg-glibc/packages/x86_64/glibc-2.21-r2.apk" \
             "https://circle-artifacts.com/gh/andyshinn/alpine-pkg-glibc/6/artifacts/0/home/ubuntu/alpine-pkg-glibc/packages/x86_64/glibc-bin-2.21-r2.apk" && \
        apk add --allow-untrusted glibc-2.21-r2.apk glibc-bin-2.21-r2.apk && \
        /usr/glibc/usr/bin/ldconfig /lib /usr/glibc/usr/lib

RUN     curl -sL ${FILEBEAT_URL} | tar xz -C .
ADD     filebeat.yml ${FILEBEAT_HOME}/
ADD     docker-entrypoint.sh    /entrypoint.sh
RUN     chmod +x /entrypoint.sh

ENTRYPOINT  ["/entrypoint.sh"]
CMD         ["start"]
