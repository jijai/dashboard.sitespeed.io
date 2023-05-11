#!/bin/bash
cd "$(dirname "$0")"

# We use the autobuild to always test our new functionality. But YOU should not do that!
# Instead use the latest tagged version as the next row
DOCKER_CONTAINER=sitespeedio/sitespeed.io:27.3.0-plus1

DOCKER_SETUP="--cap-add=NET_ADMIN --network dashboardsitespeedio_backend --shm-size=4g --rm -v /config:/config -v "$(pwd)":/sitespeed.io -v /etc/localtime:/etc/localtime:ro -e MAX_OLD_SPACE_SIZE=3072 "
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

docker run $DOCKER_SETUP $DOCKER_CONTAINER --config configLC/mobile_lacroix_article.json -b chrome https://www.la-croix.com/Quatre-morts-blesses-avalanche-Alpes-francaises-2023-04-09-1301262714
docker run $DOCKER_SETUP $DOCKER_CONTAINER --config configLC/mobile_marianne_article.json -b chrome https://www.marianne.net/societe/laicite-et-religions/menaces-de-cathos-radicaux-la-justice-ouvre-une-enquete-apres-lannulation-du-concert-de-bilal-hassani
docker run $DOCKER_SETUP $DOCKER_CONTAINER --config configLC/mobile_humanite_article.json -b chrome https://www.humanite.fr/politique/fabien-roussel-nous-voulons-etre-un-parti-pleinement-feministe-790186
# docker run $DOCKER_SETUP $DOCKER_CONTAINER --config configLC/mobile_lequipe_article.json -b chrome https://www.lequipe.fr/Cyclisme-sur-route/Actualites/Mathieu-van-der-poel-remporte-paris-roubaix-en-solitaire/1390610
#docker run $DOCKER_SETUP $DOCKER_CONTAINER --config configLC/mobile_lemonde_article.json -b chrome https://www.lemonde.fr/economie/article/2021/12/16/jean-pierre-farandou-pdg-de-la-sncf-sur-les-salaires-le-laisser-faire-d-aujourd-hui-nous-le-paierons-demain_6106284_3234.html 

# Remove the current container so we fetch the latest autobuild the next time
# If you run a stable version (as YOU should), you don't need to remove the container,
# instead make sure you remove all volumes (of data)
# docker volume prune -f
# docker system prune --all --volumes -f
sleep 20
