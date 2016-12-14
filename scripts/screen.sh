#!/system/bin/sh

while [[ -z $(getprop sys.boot_completed) ]]; do sleep 1; done;
echo "800x480" > /sys/devices/platform/soc/soc:gpu/graphics/fb0/virtual_size
