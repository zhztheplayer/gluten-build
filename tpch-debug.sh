#!/bin/bash

set -ex

BASEDIR=$(dirname $0)

source "$BASEDIR/build.sh"

GLUTEN_IT_REPO=${GLUTEN_IT_REPO:-$DEFAULT_GLUTEN_IT_REPO}
GLUTEN_IT_BRANCH=${GLUTEN_IT_BRANCH:-$DEFAULT_GLUTEN_IT_BRANCH}

# Build will result in this image
DOCKER_TARGET_IMAGE_TPCH_DEBUG=${DOCKER_TARGET_IMAGE_TPCH_DEBUG:-$DEFAULT_DOCKER_TARGET_IMAGE_TPCH_DEBUG}

# GDB server bind port
GDB_SERVER_PORT=${GDB_SERVER_PORT:-$DEFAULT_GDB_SERVER_PORT}

# JVM jdwp bind port
JDWP_PORT=${JDWP_PORT:-$DEFAULT_JDWP_PORT}

# Gluten-it commit hash
GLUTEN_IT_COMMIT="$(git ls-remote $GLUTEN_IT_REPO $GLUTEN_IT_BRANCH | awk '{print $1;}')"

if [ -z "$GLUTEN_IT_COMMIT" ]
then
   echo "Unable to parse GLUTEN_IT_COMMIT."
   exit 1
fi

echo "Building on commits:
    Gluten-it commit: $GLUTEN_IT_COMMIT"

EXEC_ARGS=

EXEC_ARGS="$EXEC_ARGS --ulimit nofile=8192:8192"
EXEC_ARGS="$EXEC_ARGS "
EXEC_ARGS="$EXEC_ARGS --build-arg GLUTEN_IT_REPO=$GLUTEN_IT_REPO"
EXEC_ARGS="$EXEC_ARGS "
EXEC_ARGS="$EXEC_ARGS --build-arg GLUTEN_IT_COMMIT=$GLUTEN_IT_COMMIT"
EXEC_ARGS="$EXEC_ARGS "
EXEC_ARGS="$EXEC_ARGS -f dockerfile-tpch"
EXEC_ARGS="$EXEC_ARGS "
EXEC_ARGS="$EXEC_ARGS --target gluten-tpch-debug"
EXEC_ARGS="$EXEC_ARGS "
EXEC_ARGS="$EXEC_ARGS -t $DOCKER_TARGET_IMAGE_TPCH_DEBUG"

EXEC_ARGS="$EXEC_ARGS $BASEDIR"

docker build $EXEC_ARGS

CMD_ARGS="$*"

docker run -i --rm --init --privileged $DOCKER_TARGET_IMAGE_TPCH_DEBUG bash -c "gdbserver :$GDB_SERVER_PORT java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=$JDWP_PORT -ea -Xmx2G -cp /opt/gluten-it/target/gluten-it-1.0-SNAPSHOT-jar-with-dependencies.jar io.glutenproject.integration.tpc.h.Tpch $CMD_ARGS"

# EOF
