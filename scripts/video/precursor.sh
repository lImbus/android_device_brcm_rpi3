


if [ $# -le 1 ]
  then
    echo "Please provide the needed patchfile and the sdcard mountpoint"
    echo "$0 MOUNTPOINT {$PATCHES}"
    exit 1
fi

MOUNTPOINT=$1
PATCHFILE=$2

#create download link
GITHUB_RAW="https://raw.githubusercontent.com/RTAndroid/android_device_brcm_rpi3/$CURRENT_HASH/$PATCH_PATH/$PATCHFILE"

PATCH=$(curl -f $GITHUB_RAW)
STATUS=$?

if [ $PATCHFILE="custom" ]
  then 
     if [ $# -le 2 ]
       then
         echo "Please provide the custom resolution in the form of"
         echo "$0 MOUNTPOINT custom WIDTHxHEIGHT"
         exit 1
     fi
     RESOLUTION=$3
     echo CUSTOM_PLACEHOLDER=$CUSTOM_PLACEHOLDER
     PATCH=${PATCH//$CUSTOM_PLACEHOLDER=/$RESOLUTION}
fi

echo $PATCH
if [ $STATUS -eq 0 ]
  then
    echo "patching filesystem"
    echo $PATCH | patch MOUNTPOINT
  else
    echo "Download failed. Valid patchfile chosen?"
    exit 1
fi

