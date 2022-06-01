#!/bin/bash

set -ex

BASEDIR=$(dirname $0)

source "$BASEDIR/defaults.conf"

# The target branches
TARGET_VELOX_REPO=${TARGET_VELOX_REPO:-$DEFAULT_VELOX_REPO}
TARGET_VELOX_BRANCH=${TARGET_VELOX_BRANCH:-$DEFAULT_VELOX_BRANCH}
TARGET_ARROW_REPO=${TARGET_ARROW_REPO:-$DEFAULT_ARROW_REPO}
TARGET_ARROW_BRANCH=${TARGET_ARROW_BRANCH:-$DEFAULT_ARROW_BRANCH}
TARGET_GLUTEN_REPO=${TARGET_GLUTEN_REPO:-$DEFAULT_GLUTEN_REPO}
TARGET_GLUTEN_BRANCH=${TARGET_GLUTEN_BRANCH:-$DEFAULT_GLUTEN_BRANCH}

# The branches used to prepare dependencies
CACHE_VELOX_REPO=${CACHE_VELOX_REPO:-$DEFAULT_VELOX_REPO}
CACHE_VELOX_BRANCH=${CACHE_VELOX_BRANCH:-$DEFAULT_VELOX_BRANCH}
CACHE_ARROW_REPO=${CACHE_ARROW_REPO:-$DEFAULT_ARROW_REPO}
CACHE_ARROW_BRANCH=${CACHE_ARROW_BRANCH:-$DEFAULT_ARROW_BRANCH}
CACHE_GLUTEN_REPO=${CACHE_GLUTEN_REPO:-$DEFAULT_GLUTEN_REPO}
CACHE_GLUTEN_BRANCH=${CACHE_GLUTEN_BRANCH:-$DEFAULT_GLUTEN_BRANCH}

# Create debug build
DEBUG_BUILD=${DEBUG_BUILD:-$DEFAULT_DEBUG_BUILD}

# Http proxy
HTTP_PROXY_HOST=${HTTP_PROXY_HOST:-$DEFAULT_HTTP_PROXY_HOST}
HTTP_PROXY_PORT=${HTTP_PROXY_PORT:-$DEFAULT_HTTP_PROXY_PORT}

# If on, use maven mirror settings for PRC's network environment
USE_ALI_MAVEN_MIRROR=${USE_ALI_MAVEN_MIRROR:-$DEFAULT_USE_ALI_MAVEN_MIRROR}

# Set timezone name
TIMEZONE=${TIMEZONE:-$DEFAULT_TIMEZONE}

# Build will result in this image
DOCKER_TARGET_IMAGE_BASE=${DOCKER_TARGET_IMAGE_BASE:-$DEFAULT_DOCKER_TARGET_IMAGE_BASE}

# Docker cache image used to speed-up builds
DOCKER_CACHE_IMAGE=${DOCKER_CACHE_IMAGE:-$DEFAULT_DOCKER_CACHE_IMAGE}

##

BASEDIR=$(dirname $0)

TARGET_VELOX_COMMIT="$(git ls-remote $TARGET_VELOX_REPO $TARGET_VELOX_BRANCH | awk '{print $1;}')"
TARGET_ARROW_COMMIT="$(git ls-remote $TARGET_ARROW_REPO $TARGET_ARROW_BRANCH | awk '{print $1;}')"
TARGET_GLUTEN_COMMIT="$(git ls-remote $TARGET_GLUTEN_REPO $TARGET_GLUTEN_BRANCH | awk '{print $1;}')"

if [ -z "$TARGET_VELOX_COMMIT" ]
then
   echo "Unable to parse TARGET_VELOX_COMMIT."
   exit 1
fi

if [ -z "$TARGET_ARROW_COMMIT" ]
then
   echo "Unable to parse TARGET_ARROW_COMMIT."
   exit 1
fi

if [ -z "$TARGET_GLUTEN_COMMIT" ]
then
   echo "Unable to parse TARGET_GLUTEN_COMMIT."
   exit 1
fi

if [ "$USE_ALI_MAVEN_MIRROR" == "ON" ]
then
   MAVEN_MIRROR_URL='https://maven.aliyun.com/repository/public'
else
   MAVEN_MIRROR_URL=
fi

echo "Building on commits:
    Velox commit: $TARGET_VELOX_COMMIT
    Arrow commit: $TARGET_ARROW_COMMIT
    Gluten commit: $TARGET_GLUTEN_COMMIT"

##

EXEC_ARGS=

EXEC_ARGS="$EXEC_ARGS --ulimit nofile=8192:8192"
EXEC_ARGS="$EXEC_ARGS "
EXEC_ARGS="$EXEC_ARGS --build-arg TIMEZONE=$TIMEZONE"
EXEC_ARGS="$EXEC_ARGS "
EXEC_ARGS="$EXEC_ARGS --build-arg MAVEN_MIRROR_URL=$MAVEN_MIRROR_URL"
EXEC_ARGS="$EXEC_ARGS "
EXEC_ARGS="$EXEC_ARGS --build-arg TARGET_VELOX_REPO=$TARGET_VELOX_REPO"
EXEC_ARGS="$EXEC_ARGS "
EXEC_ARGS="$EXEC_ARGS --build-arg TARGET_VELOX_COMMIT=$TARGET_VELOX_COMMIT"
EXEC_ARGS="$EXEC_ARGS "
EXEC_ARGS="$EXEC_ARGS --build-arg TARGET_ARROW_REPO=$TARGET_ARROW_REPO"
EXEC_ARGS="$EXEC_ARGS "
EXEC_ARGS="$EXEC_ARGS --build-arg TARGET_ARROW_COMMIT=$TARGET_ARROW_COMMIT"
EXEC_ARGS="$EXEC_ARGS "
EXEC_ARGS="$EXEC_ARGS --build-arg TARGET_GLUTEN_REPO=$TARGET_GLUTEN_REPO"
EXEC_ARGS="$EXEC_ARGS "
EXEC_ARGS="$EXEC_ARGS --build-arg TARGET_GLUTEN_COMMIT=$TARGET_GLUTEN_COMMIT"
EXEC_ARGS="$EXEC_ARGS "
EXEC_ARGS="$EXEC_ARGS --build-arg CACHE_VELOX_REPO=$CACHE_VELOX_REPO"
EXEC_ARGS="$EXEC_ARGS "
EXEC_ARGS="$EXEC_ARGS --build-arg CACHE_VELOX_BRANCH=$CACHE_VELOX_BRANCH"
EXEC_ARGS="$EXEC_ARGS "
EXEC_ARGS="$EXEC_ARGS --build-arg CACHE_ARROW_REPO=$CACHE_ARROW_REPO"
EXEC_ARGS="$EXEC_ARGS "
EXEC_ARGS="$EXEC_ARGS --build-arg CACHE_ARROW_BRANCH=$CACHE_ARROW_BRANCH"
EXEC_ARGS="$EXEC_ARGS "
EXEC_ARGS="$EXEC_ARGS --build-arg CACHE_GLUTEN_REPO=$CACHE_GLUTEN_REPO"
EXEC_ARGS="$EXEC_ARGS "
EXEC_ARGS="$EXEC_ARGS --build-arg CACHE_GLUTEN_BRANCH=$CACHE_GLUTEN_BRANCH"
EXEC_ARGS="$EXEC_ARGS "
EXEC_ARGS="$EXEC_ARGS --build-arg DEBUG_BUILD=$DEBUG_BUILD"
EXEC_ARGS="$EXEC_ARGS "
EXEC_ARGS="$EXEC_ARGS --build-arg HTTP_PROXY_HOST=$HTTP_PROXY_HOST"
EXEC_ARGS="$EXEC_ARGS "
EXEC_ARGS="$EXEC_ARGS --build-arg HTTP_PROXY_PORT=$HTTP_PROXY_PORT"
EXEC_ARGS="$EXEC_ARGS "
EXEC_ARGS="$EXEC_ARGS -f dockerfile-build"
EXEC_ARGS="$EXEC_ARGS "
EXEC_ARGS="$EXEC_ARGS --target gluten-base"
EXEC_ARGS="$EXEC_ARGS "
EXEC_ARGS="$EXEC_ARGS -t $DOCKER_TARGET_IMAGE_BASE"

if [ -n "$DOCKER_CACHE_IMAGE" ]
then
  EXEC_ARGS="$EXEC_ARGS "
  EXEC_ARGS="$EXEC_ARGS --cache-from $DOCKER_CACHE_IMAGE"
fi

EXEC_ARGS="$EXEC_ARGS $BASEDIR"

docker build $EXEC_ARGS

# EOF
