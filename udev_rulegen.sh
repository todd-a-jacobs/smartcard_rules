#!/bin/bash

# Name:
#     udev_rulegen.sh
# Purpose:
#     Generate udev rules for a user-selected device.
# Author:
#     Copyright 2011 Todd A. Jacobs
# Homepage:
#     http://github.com/CodeGnome/smartcard_rules/

set -e

MODE=0660
GROUP=pcscd

make_rule () {
    [ $# -eq 2 ] || return 1
    local str
    str='ATTR{idVendor}=="%s", ATTR{idProduct}=="%s", MODE="%s", GROUP="%s"\n'
    printf "$str" $1 $2 $MODE $GROUP
}

ask_device () {
  local devices id desc PS3
  declare -a devices
  while read; do
    devices[${#devices[*]}]="$REPLY"
  done < <( /usr/sbin/lsusb | /usr/bin/cut -d' ' -f6- )
  PS3='Select your smartcard reader (q = quit): '
  select device in "${devices[@]}"; do
    [[ $REPLY == q ]] && exit
    id="${devices[$(($REPLY-1))]}"
    desc="${id#* }"
    id="${id/ */}"
    echo "# $desc"
    make_rule ${id/:/ } || return 1
    break
  done
}

ask_device || exit 1
