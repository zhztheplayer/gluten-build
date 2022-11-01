#!/bin/bash

set -ex

BASEDIR=$(dirname $0)

source "$BASEDIR/buildenv.sh"

## Debug build flags

# Create debug build
DEBUG_BUILD=${DEBUG_BUILD:-$DEFAULT_DEBUG_BUILD}

if [ -n $JDK_DEBUG_BUILD ]
then
  echo "Do not set JDK_DEBUG_BUILD manually!"
fi

if [ -n $VELOX_DEBUG_BUILD ]
then
  echo "Do not set VELOX_DEBUG_BUILD manually!"
fi

if [ -n $ARROW_DEBUG_BUILD ]
then
  echo "Do not set ARROW_DEBUG_BUILD manually!"
fi

if [ -n $GLUTEN_DEBUG_BUILD ]
then
  echo "Do not set GLUTEN_DEBUG_BUILD manually!"
fi

if [ "$DEBUG_BUILD" == "ON" ]
then
  # JDK_DEBUG_BUILD=ON
  VELOX_DEBUG_BUILD=ON
  ARROW_DEBUG_BUILD=ON
  GLUTEN_DEBUG_BUILD=ON
fi

# The target branches
TARGET_GLUTEN_REPO=${TARGET_GLUTEN_REPO:-$DEFAULT_GLUTEN_REPO}
TARGET_GLUTEN_BRANCH=${TARGET_GLUTEN_BRANCH:-$DEFAULT_GLUTEN_BRANCH}

# The branches used to prepare dependencies
CACHE_GLUTEN_REPO=${CACHE_GLUTEN_REPO:-$DEFAULT_GLUTEN_REPO}
CACHE_GLUTEN_BRANCH=${CACHE_GLUTEN_BRANCH:-$DEFAULT_GLUTEN_BRANCH}

# Backend type
BACKEND_TYPE=${BACKEND_TYPE:-$DEFAULT_BACKEND_TYPE}

if [ "$BACKEND_TYPE" == "velox" ]
then
  EXTRA_MAVEN_OPTIONS="-Pspark-3.2 \
                       -Pbackends-velox \
                       -Dbuild_protobuf=OFF \
                       -Dbuild_cpp=ON \
                       -Dbuild_arrow=ON \
                       -Dbuild_velox=ON \
                       -Dbuild_velox_from_source=ON \
                       -Dbuild_gazelle_cpp=OFF \
                       -DskipTests \
                       -Dscalastyle.skip=true \
                       -Dcheckstyle.skip=true \
                       -Denable_ep_cache=ON"
elif [ "$BACKEND_TYPE" == "gazelle-cpp" ]
then
  EXTRA_MAVEN_OPTIONS="-Pspark-3.2 \
                       -Pbackends-gazelle \
                       -Dbuild_protobuf=ON \
                       -Dbuild_cpp=ON \
                       -Dbuild_arrow=ON \
                       -Dbuild_velox=OFF \
                       -Dbuild_velox_from_source=OFF \
                       -Dbuild_gazelle_cpp=ON \
                       -DskipTests \
                       -Dscalastyle.skip=true \
                       -Dcheckstyle.skip=true \
                       -Denable_ep_cache=ON"
else
  echo "Unrecognizable backend type: $BACKEND_TYPE"
  exit 1
fi

# Build will result in this image
DOCKER_TARGET_IMAGE_BUILD=${DOCKER_TARGET_IMAGE_BUILD:-$DEFAULT_DOCKER_TARGET_IMAGE_BUILD}

## Fetch target commit

TARGET_GLUTEN_COMMIT="$(git ls-remote $TARGET_GLUTEN_REPO $TARGET_GLUTEN_BRANCH | awk '{print $1;}')"

if [ -z "$TARGET_GLUTEN_COMMIT" ]
then
  echo "Unable to parse TARGET_GLUTEN_COMMIT."
  exit 1
fi

##

BUILD_DOCKER_BUILD_ARGS=

BUILD_DOCKER_BUILD_ARGS="$BUILD_DOCKER_BUILD_ARGS --ulimit nofile=8192:8192"
BUILD_DOCKER_BUILD_ARGS="$BUILD_DOCKER_BUILD_ARGS --build-arg JDK_DEBUG_BUILD=$JDK_DEBUG_BUILD"
BUILD_DOCKER_BUILD_ARGS="$BUILD_DOCKER_BUILD_ARGS --build-arg VELOX_DEBUG_BUILD=$VELOX_DEBUG_BUILD"
BUILD_DOCKER_BUILD_ARGS="$BUILD_DOCKER_BUILD_ARGS --build-arg ARROW_DEBUG_BUILD=$ARROW_DEBUG_BUILD"
BUILD_DOCKER_BUILD_ARGS="$BUILD_DOCKER_BUILD_ARGS --build-arg GLUTEN_DEBUG_BUILD=$GLUTEN_DEBUG_BUILD"
BUILD_DOCKER_BUILD_ARGS="$BUILD_DOCKER_BUILD_ARGS --build-arg TARGET_GLUTEN_REPO=$TARGET_GLUTEN_REPO"
BUILD_DOCKER_BUILD_ARGS="$BUILD_DOCKER_BUILD_ARGS --build-arg TARGET_GLUTEN_COMMIT=$TARGET_GLUTEN_COMMIT"
BUILD_DOCKER_BUILD_ARGS="$BUILD_DOCKER_BUILD_ARGS --build-arg CACHE_GLUTEN_REPO=$CACHE_GLUTEN_REPO"
BUILD_DOCKER_BUILD_ARGS="$BUILD_DOCKER_BUILD_ARGS --build-arg CACHE_GLUTEN_BRANCH=$CACHE_GLUTEN_BRANCH"
BUILD_DOCKER_BUILD_ARGS="$BUILD_DOCKER_BUILD_ARGS --build-arg 'EXTRA_MAVEN_OPTIONS=$EXTRA_MAVEN_OPTIONS'"
BUILD_DOCKER_BUILD_ARGS="$BUILD_DOCKER_BUILD_ARGS -f $BASEDIR/dockerfile-build"
BUILD_DOCKER_BUILD_ARGS="$BUILD_DOCKER_BUILD_ARGS --target gluten-build"
BUILD_DOCKER_BUILD_ARGS="$BUILD_DOCKER_BUILD_ARGS -t $DOCKER_TARGET_IMAGE_BUILD"

if [ -n "$DOCKER_CACHE_IMAGE" ]
then
  BUILD_DOCKER_BUILD_ARGS="$BUILD_DOCKER_BUILD_ARGS --cache-from $DOCKER_CACHE_IMAGE"
fi

BUILD_DOCKER_BUILD_ARGS="$BUILD_DOCKER_BUILD_ARGS $BASEDIR"

docker build $BUILD_DOCKER_BUILD_ARGS

# EOF
