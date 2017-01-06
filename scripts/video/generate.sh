#!/bin/bash


FILENAME="set_video.sh"
PRECURSOR="precursor.sh"

CUSTOM_PLACEHOLDER="RES_PLACEHOLDER"
PATCH_FOLDER="patches"

#get current commit
CURRENT_HASH=$(git log --pretty=format:'%H' -n 1)
#get relative path of patch folder
PATCH_PATH=$(git ls-tree --full-name --name-only HEAD ./$PATCH_FOLDER)

#get patch folder contents
PATCHES=$(ls $PATCH_FOLDER | sed -e 's/\s\+/,/g')


echo "#!/bin/bash" > $FILENAME
echo CURRENT_HASH=$CURRENT_HASH >> $FILENAME
echo PATCH_PATH=$PATCH_PATH >> $FILENAME
echo PATCHES=\"$PATCHES\">> $FILENAME
echo CUSTOM_PLACEHOLDER=\"$CUSTOM_PLACEHOLDER\" >> $FILENAME
cat $PRECURSOR >> $FILENAME

chmod +x $FILENAME

