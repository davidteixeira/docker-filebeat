#!/bin/sh
set -e

if [ "$1" = 'start' ]; then

  CONTAINERS_FOLDER=/tmp/containers
  NAMED_PIPE=/tmp/pipe

  setConfiguration() {
    KEY=$1
    VALUE=$2
    sed -i "s/{{$KEY}}/$VALUE/g" /filebeat.yml
  }

  getRunningContainers() {
		echo "getRunningContainers"
		curl --no-buffer -s -XGET --unix-socket /tmp/docker.sock http:/containers/json
#     curl --no-buffer -s -XGET --unix-socket /tmp/docker.sock http:/containers/json | python -c "
# import json, sys
# containers=json.loads(sys.stdin.readline())
# for container in containers:
#   print(container)
# "
  }

  getContainerName() {
		echo "getContainerName"
    curl --no-buffer -s -XGET --unix-socket /tmp/docker.sock http:/containers/$1/json | python -c "
import json, sys
container=json.loads(sys.stdin.readline())
print(container)
" | sed 's;/;;'
  }

  createContainerFile() {
    touch "$CONTAINERS_FOLDER/$1"
  }

  removeContainerFile() {
    rm "$CONTAINERS_FOLDER/$1"
  }

  collectContainerLogs() {
    local CONTAINER=$1
    echo "Processing $CONTAINER..."
    createContainerFile $CONTAINER
    CONTAINER_NAME=`getContainerName $CONTAINER`
    curl -s --no-buffer -XGET --unix-socket /tmp/docker.sock "http:/containers/$CONTAINER/logs?stderr=1&stdout=1&tail=1&follow=1"
    echo "Disconnected from $CONTAINER."
    removeContainerFile $CONTAINER
  }

  if [ -n "${ELASTICSEARCH_HOST+1}" ]; then
    setConfiguration "ELASTICSEARCH_HOST" "$ELASTICSEARCH_HOST"
  else
    echo "ELASTICSEARCH_HOST is needed"
    exit 1
  fi

  if [ -n "${ELASTICSEARCH_PORT+1}" ]; then
    setConfiguration "ELASTICSEARCH_PORT" "$ELASTICSEARCH_PORT"
  else
    echo "ELASTICSEARCH_PORT is needed"
    exit 1
  fi

  if [ -n "${SHIPPER_NAME+1}" ]; then
    setConfiguration "SHIPPER_NAME" "$SHIPPER_NAME"
  else
    setConfiguration "SHIPPER_NAME" "`hostname`"
  fi

  rm -rf "$CONTAINERS_FOLDER"
  rm -rf "$NAMED_PIPE"
  mkdir "$CONTAINERS_FOLDER"
  mkfifo -m a=rw "$NAMED_PIPE"

  echo "Initializing Filebeat..."
  cat $NAMED_PIPE | filebeat -e -v &

  while true; do
    CONTAINERS=`getRunningContainers`
		echo "$CONTAINERS"
    for CONTAINER in $CONTAINERS; do
      if ! ls $CONTAINERS_FOLDER | grep -q $CONTAINER; then
        collectContainerLogs $CONTAINER &
      fi
    done
    sleep 5
  done

else
  exec "$@"
fi
