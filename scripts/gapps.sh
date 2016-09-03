#!/bin/bash

#
# Copyright (C) 2016 RTAndroid Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#
# OpenGApps installation script for Raspberry Pi 3
# Author: Igor Kalkov
# https://github.com/RTAndroid/android_device_brcm_rpi3/blob/aosp-n/scripts/gapps.sh
#

TIMESTAMP="20160827"
PACKAGE=""

SHOW_HELP=false
ADB_ADDRESS=""

ARCHITECTURE="none"

# ------------------------------------------------
# Helping functions
# ------------------------------------------------

show_help()
{
cat << EOF
USAGE:
  $0 [-h] -i IP -a ARCH
OPTIONS:
  -a  Architecture of the device [x86] [x86_64] [arm] [arm64]
  -h  Show help
  -i  IP address for ADB
EOF
}

reboot_device()
{
    adb reboot bootloader > /dev/null &
    sleep 10
}

is_booted()
{
    [[ "$(adb shell getprop sys.boot_completed | tr -d '\r')" == 1 ]]
}

wait_for_adb()
{
    while true; do
        sleep 1
        adb kill-server > /dev/null
        sleep 1
        adb connect $ADB_ADDRESS > /dev/null
        sleep 1
        if is_booted; then
            break
        fi
    done
}

prepare_device()
{
    echo " * Checking available devices..."
    ping -c 1 $ADB_ADDRESS > /dev/null 2>&1
    reachable="$?"
    if [ "$reachable" -ne "0" ]; then
        echo "ERR: no device with address $ADB_ADDRESS found"
        echo ""
        show_help
        exit 1
    fi

    echo " * Enabling root access..."
    wait_for_adb
    adb root

    echo " * Remounting system partition..."
    wait_for_adb
    adb remount
}

prepare_gapps()
{
    mkdir -p gapps

    if [ ! -d "gapps/pkg" ]; then
        echo " * Downloading OpenGApps package..."
        echo ""
        wget https://github.com/opengapps/$ARCHITECTURE/releases/download/$TIMESTAMP/$PACKAGE -O gapps/$PACKAGE
    fi

    if [ ! -f "gapps/$PACKAGE" ]; then
        echo "ERR: package download failed!"
    fi

    if [ ! -d "gapps/pkg" ]; then
        echo " * Unzipping package..."
        echo ""
        unzip "gapps/$PACKAGE" -d "gapps/pkg"
        echo ""
    fi

    if [ ! -d "gapps/pkg" ]; then
        echo "ERR: unzipping the package failed!"
        exit 1
    fi
}

create_partition()
{
    echo " * Extracting supplied packages..."
    rm -rf gapps/tmp > /dev/null 2>&1
    mkdir -p gapps/tmp
    find . -name "*.tar.xz" -exec tar -xf {} -C gapps/tmp/ \;

    echo " * Creating local system partition..."
    rm -rf gapps/sys > /dev/null 2>&1
    mkdir -p gapps/sys
    for dir in gapps/tmp/*/
    do
      pkg=${dir%*/}
      dpi=$(ls -1 $pkg | head -1)

      echo "  - including $pkg/$dpi"
      rsync -aq $pkg/$dpi/ gapps/sys/
    done

    # no leftovers
    rm -rf gapps/tmp
}

install_package()
{
    echo " * Removing old package installer..."
    adb shell "rm -rf system/priv-app/PackageInstaller"

    echo " * Pushing system files..."
    adb push gapps/sys /system

    echo " * Enforcing a reboot, please be patient..."
    wait_for_adb
    reboot_device

    echo " * Waiting for ADB..."
    wait_for_adb

    echo " * Applying correct permissions..."
    adb shell "pm grant com.google.android.gms android.permission.ACCESS_COARSE_LOCATION"
    adb shell "pm grant com.google.android.gms android.permission.ACCESS_FINE_LOCATION"
}

# ------------------------------------------------
# Script entry point
# ------------------------------------------------

# save the passed options
while getopts ":i:a:h" flag; do
case $flag in
    "i") ADB_ADDRESS="$OPTARG" ;;
    "a") ARCHITECTURE="$OPTARG" ;;
    "h") SHOW_HELP=true ;;
    *)
         echo ""
         echo "ERR: invalid option (-$flag $OPTARG)"
         echo ""
         show_help
         exit 1
esac
done

if [ "$ARCHITECTURE" != "x86" -a "$ARCHITECTURE" != "x86_64" -a "$ARCHITECTURE" != "arm" -a "$ARCHITECTURE" != "arm64" ]; then
    echo "wrong arch $ARCHITECTURE";
    show_help
    exit 1
fi

if [[ "$SHOW_HELP" = true ]]; then
    show_help
    exit 1
fi

PACKAGE="open_gapps-$ARCHITECTURE-7.0-pico-$TIMESTAMP.zip"
echo "GApps installation script for RPi/x86"
echo "Used package: $PACKAGE"
echo "ADB IP address: $ADB_ADDRESS"
echo ""

prepare_device
prepare_gapps
create_partition
install_package

echo " * Waiting for ADB..."
wait_for_adb

echo "All done. The device will reboot once again."
reboot_device
adb kill-server
