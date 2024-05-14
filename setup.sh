#!/usr/bin/env sh

set -e -u

termux-setup-storage

for action in install remove; do
    yes | xargs -a "${0%/*}/packages/${action}" pkg "$action"
done
pkg clean
yes | apt autoremove
