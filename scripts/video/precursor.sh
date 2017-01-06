


if [ $# -eq 0 ]
  then
    echo "Please provide the needed patchfile"
    echo "$0 {$PATCHES}"
    exit 1
fi

PATCHFILE=$1

#create download link
GITHUB_RAW="https://raw.githubusercontent.com/RTAndroid/android_device_brcm_rpi3/$CURRENT_HASH/$PATCH_PATH/\$PATCHFILE"

PATCH=$(curl -sf $GITHUB_RAW)

if [ $? -eq 0 ]
  then
    echo "patching filesystem"
    echo $PATCH | patch
  else
    exit 1
fi

