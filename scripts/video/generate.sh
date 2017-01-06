#!/bin/bash


CURRENT_HASH=$(git log --pretty=format:'%H' -n 1)
GITHUB_RAW="https://raw.githubusercontent.com/RTAndroid/android_device_brcm_rpi3/$CURRENT_HASH/FILE_PLACEHOLDER"

git ls-tree --full-name --name-only HEAD $FILENAME

echo $GITHUB_RAW
