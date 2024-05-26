#!/bin/sh

set -x
set -e
set -u

if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root"
    exit 1
fi

R=$(dirname $(readlink -f $0))

export LD_LIBRARY_PATH=$R/lib
$R/bin/OpenHantek
