#!/bin/bash

# This file is part of Espruino, a JavaScript interpreter for Microcontrollers
#
# Copyright (C) 2017 Gordon Williams <gw@pur3.co.uk>
# wilberforce (Rhys Williams)
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# -----------------------------------------------------------------------------
# Setup toolchain and libraries for build targets, installs if missing
# set env vars for builds
# For use in:
#    Travis
#    Firmware builds
#    Docker
#  
# -----------------------------------------------------------------------------

if [ $# -eq 0 ]
then
  echo "USAGE:"
  echo "source scripts/provision.sh {ARCH}"
  return 0
fi

ARCH=$1

if [ $ARCH = "ESP32" ]; then
    echo ESP32
    if [ ! -d "app" ]; then
        echo installing app folder
        curl -Ls https://github.com/espruino/EspruinoBuildTools/raw/master/esp32/deploy/app.tgz | tar xfz -
    fi
    if [ ! -d "esp-idf" ]; then
        echo installing esp-idf folder
        curl -Ls https://github.com/espruino/EspruinoBuildTools/raw/master/esp32/deploy/esp-idf.tgz | tar xfz -
    fi
    if hash xtensa-esp32-elf-gcc 2>/dev/null; then
        echo installing xtensa-esp32-elf-gcc
        curl -Ls https://dl.espressif.com/dl/xtensa-esp32-elf-linux64-1.22.0-61-gab8375a-5.2.0.tar.gz | tar xfz -
        export PATH=$PATH:`pwd`/xtensa-esp32-elf/bin/
    fi
    export ESP_IDF_PATH=`pwd`/esp-idf
    export ESP_APP_TEMPLATE_PATH=`pwd`/app
    return 1
elif [ $ARCH = "ESP8266" ]; then
    echo ESP8266
    if [ ! -d "esp_iot_sdk_v2.0.0.p1" ]; then
        echo esp_iot_sdk_v2.0.0.p1
        curl -Ls http://s3.voneicken.com/esp_iot_sdk_v2.0.0.p1.tgx | tar Jxf -
    fi
    if hash xtensa-lx106-elf-gcc 2>/dev/null; then
        echo installing xtensa-lx106-elf-gcc
        curl -Ls http://s3.voneicken.com/xtensa-lx106-elf-20160330.tgx | tar Jxf -
    fi
    export ESP8266_SDK_ROOT=`pwd`/esp_iot_sdk_v2.0.0.p1
    export PATH=$PATH:`pwd`/xtensa-lx106-elf/bin/
    return 1
elif [ $ARCH = "LINUX" ]; then
    echo LINUX
    return 1
else
    # defaulting to ARM
    echo ARM
    #GCC-ARM_OK=$(dpkg-query -W --showformat='${Status}\n' gcc-arm-embedded|grep "install ok installed")
    #echo Checking for gcc-arm-embedded: $PKG_OK
    #if [ "" == "$CC-ARM_OK" ]; then
    # not sure if these sudos will work out ?
    if hash arm-none-eabi-gcc 2>/dev/null; then
        echo installing gcc-arm-embedded
        sudo add-apt-repository -y ppa:team-gcc-arm-embedded/ppa
        sudo apt-get update
        sudo apt-get --force-yes --yes install libsdl1.2-dev gcc-arm-embedded
    fi
    return 1
fi
