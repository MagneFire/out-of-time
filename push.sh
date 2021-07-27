#!/bin/bash
if [ "$1" == "adb" ]
then
    echo "Pushing files using ADB mode..."
    adb push 099* /usr/share/asteroid-launcher/watchfaces/
    adb push out-of-time-img.gif /usr/share/asteroid-launcher/watchfaces-img/
else
    echo "Pushing files using Developer mode..."
    scp 099* root@192.168.2.15:/usr/share/asteroid-launcher/watchfaces/
    scp out-of-time-img.gif root@192.168.2.15:/usr/share/asteroid-launcher/watchfaces-img/
fi
