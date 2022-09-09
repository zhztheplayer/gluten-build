# Portable Test Envrionment of Gluten (gluten-te)

Build and run [gluten](https://github.com/oap-project/gluten) and [gluten-it](https://github.com/zhztheplayer/gluten-it) in a portable docker container, from scratch.

# Prerequisites

Only Linux and MacOS are currently supported. Before running the scripts, make sure you have `git` and `docker` installed in your host machine.

# Getting Started

```sh
git clone -b main https://github.com/zhztheplayer/gluten-te.git gluten-te
cd gluten-te
./tpc.sh
```

# Configurations

See the [config file](https://github.com/zhztheplayer/gluten-te/blob/main/defaults.conf). You can modify the file to configure gluten-te, or pass env variables during running the scripts.

# Example Usages

## Example: Build and run on non-default branches of `gluten`, `arrow` and `velox`

```sh
TARGET_GLUTEN_BRANCH=my_branch \
TARGET_ARROW_BRANCH=my_branch \
TARGET_VELOX_BRANCH=my_branch \
./tpc.sh
```

## Example: Build and run behind a http proxy

```sh
HTTP_PROXY_HOST=myproxy.example.com \
HTTP_PROXY_PORT=55555 \
./tpc.sh
```

## Example: Create debug build for all codes, and open a GDB debugger interface during running gluten-it

```sh
DEBUG_BUILD=ON \
RUN_GDB=ON \
./tpc.sh
```
