#!/bin/bash

if [ $(whoami) = "root"  ]; then
  echo "Don't run this as root!"
  exit
fi
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
export PATH=$PATH:~/.local/bin

pip install konsave
konsave -i "$SCRIPT_DIR/../arc-kde.knsv"
sleep 1
konsave -a arc-kde
# Will hopefully fix the bug where the theme couldn't load properly
konsave -r arc-kde
konsave -i "$SCRIPT_DIR/../arc-kde.knsv"
konsave -a arc-kde