#!/bin/bash

set -ex

BASEDIR=$(dirname $0)

source "$BASEDIR/build.sh"

if [ "$VELOX_SUITE" == "ON" ]
then
  docker run --env GLUTEN_INTEGRATION_TEST_ENABLED=true --env MAVEN_OPTS=-Xmx2G $DOCKER_TARGET_IMAGE bash -c "cd /opt/gluten/ && mvn test -Pbackends-velox -pl backends-velox -Dsuites=io.glutenproject.e2e.tpc.h.velox.VeloxTpchSuite"
fi

if [ "$GLUTEN_CPP_SUITE" == "ON" ]
then
  docker run --env GLUTEN_INTEGRATION_TEST_ENABLED=true --env MAVEN_OPTS=-Xmx2G $DOCKER_TARGET_IMAGE bash -c "cd /opt/gluten/ && mvn test -Pbackends-velox -pl backends-velox -Dsuites=io.glutenproject.e2e.tpc.h.velox.GazelleCppTpchSuite"
fi

# EOF
