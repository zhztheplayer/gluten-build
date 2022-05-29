#!/bin/bash

set -ex

BASEDIR=$(dirname $0)

source "$BASEDIR/build.sh"

CMD_ARGS="$*"

docker run -i -t $DOCKER_TARGET_IMAGE bash -c "cd /opt/gluten/ && mvn exec:java -pl backends-velox -P backends-velox -Dexec.classpathScope=test -Dexec.mainClass=io.glutenproject.e2e.tpc.h.velox.Cli -Dexec.args=\"$CMD_ARGS\""

