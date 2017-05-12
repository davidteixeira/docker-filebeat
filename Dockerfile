FROM debian:stretch

MAINTAINER David Teixeira

# Build variables
ENV FILEBEAT_VERSION 5.4.0
ENV FILEBEAT_SHA1=545fbb229c958f2379b17efe3825bf0c30e3039b

# Environment variables

USER root

RUN set -x && \
  apt-get update && \
  apt-get install -y wget python curl && \
  wget https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-${FILEBEAT_VERSION}-linux-x86_64.tar.gz -O /opt/filebeat.tar.gz && \
  cd /opt && \
  echo "${FILEBEAT_SHA1}  filebeat.tar.gz" | sha1sum -c - && \
  tar xzvf filebeat.tar.gz && \
  cd filebeat-* && \
  cp filebeat /bin && \
  cd /opt && \
  rm -rf filebeat* && \
  apt-get purge -y wget && \
  apt-get autoremove -y && \
  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY filebeat.yml /
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
# CMD [ "filebeat", "-e" ]
CMD [ "start" ]
