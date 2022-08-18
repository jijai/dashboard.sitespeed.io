#!/bin/bash

# We use the autobuild to always test our new functionality. But YOU should not do that!
# Instead use the latest tagged version as the next row
DOCKER_CONTAINER=sitespeedio/sitespeed.io:25.7.3

DOCKER_SETUP="--cap-add=NET_ADMIN --network dashboardsitespeedio_backend --shm-size=2g --rm -v /config:/config -v "$(pwd)":/sitespeed.io -v /etc/localtime:/etc/localtime:ro -e MAX_OLD_SPACE_SIZE=3072 "
DESKTOP_BROWSERS_DOCKER=(chrome firefox)
EMULATED_MOBILE_BROWSERS=(chrome)

# We loop through the desktop directory

for file in testsLC/docker/desktop/*.{txt,js} ; do
    for browser in "${DESKTOP_BROWSERS_DOCKER[@]}" ; do
        FILENAME=$(basename -- "$file")
        FILENAME_WITHOUT_EXTENSION="${FILENAME%.*}"
        CONFIG_FILE="configLC/$FILENAME_WITHOUT_EXTENSION.json"
        [[ -f "$CONFIG_FILE" ]] && echo "Using config file $CONFIG_FILE" || echo "Missing config file $CONFIG_FILE"
        docker run $DOCKER_SETUP $DOCKER_CONTAINER --config $CONFIG_FILE -b $browser $file
        control
    done
done

# We loop through the emulatedMobile directory

for file in testsLC/docker/emulatedMobile/*.{txt,js} ; do
    for browser in "${EMULATED_MOBILE_BROWSERS[@]}" ; do
        FILENAME=$(basename -- "$file")
        FILENAME_WITHOUT_EXTENSION="${FILENAME%.*}"
        CONFIG_FILE="configLC/$FILENAME_WITHOUT_EXTENSION.json"
        [[ -f "$CONFIG_FILE" ]] && echo "Using config file $CONFIG_FILE" || echo "Missing config file $CONFIG_FILE"
        docker run $DOCKER_SETUP $DOCKER_CONTAINER --config $CONFIG_FILE -b $browser $file
        control
    done
done

# Remove the current container so we fetch the latest autobuild the next time
# If you run a stable version (as YOU should), you don't need to remove the container,
# instead make sure you remove all volumes (of data)
# docker volume prune -f
# docker system prune --all --volumes -f
sleep 20
