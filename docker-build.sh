#!/usr/bin/env bash

set -e

REPO_NAME="oizom"
PACKAGE_VERSION="latest"
DOCKER_IMAGE_USER="oizom"
APPLICATION="spark-"

while [[ $# -gt 0 ]]; do
    opt="$1"
    shift;
    current_arg="$1"
    if [[ "$current_arg" =~ ^-{1,2}.* ]]; then
        echo "WARNING: You may have left an argument blank. Double check your command." 
    fi
    case "$opt" in
    "-v"|"--version"    ) PACKAGE_VERSION="$1"; shift;;
    "-r"|"--repo"       ) REPO_NAME="$1"; shift;;
    "-i"|"--image"      ) DOCKER_IMAGE_USER="$1"; shift;;
    "-u"|"--username"   ) DOCKER_USER="$1"; shift;;
    "-p"|"--password"   ) DOCKER_PASSWORD="$1"; shift;;
    *                   ) echo "ERROR: Invalid option: \""$opt"\"" >&2
                            exit 1;;
    esac
done

echo "$REPO_NAME:$APPLICATION$PACKAGE_VERSION"
# echo "DOCKER_USER=$DOCKER_USER"
# echo "DOCKER_PASSWORD=$DOCKER_PASSWORD"
# echo "DOCKER_IMAGE_USER=$DOCKER_IMAGE_USER"

if [ -z "${DOCKER_USER}" ]; then
    printf "Docker Hub Username:"
    read -r DOCKER_USER
fi

if [ -z "${DOCKER_PASSWORD}" ]; then
    printf "Docker Hub Password:"
    read -s DOCKER_PASSWORD
fi

if [ ! -z  $DOCKER_USER ] && [ ! -z  $DOCKER_PASSWORD ]; then
    docker logout
	docker login --username $DOCKER_USER --password $DOCKER_PASSWORD
    docker rmi $DOCKER_IMAGE_USER/$REPO_NAME:$APPLICATION$PACKAGE_VERSION || docker images
    docker build -t $DOCKER_IMAGE_USER/$REPO_NAME:$APPLICATION$PACKAGE_VERSION .
	
	echo "Pushing $DOCKER_IMAGE_USER/$REPO_NAME:$APPLICATION$PACKAGE_VERSION"
	docker push $DOCKER_IMAGE_USER/$REPO_NAME:$APPLICATION$PACKAGE_VERSION

    docker logout
fi