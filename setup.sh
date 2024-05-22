#!/usr/bin/env sh

set -e -u

termux-setup-storage

for action in install remove; do
    yes | xargs -a "${0%/*}/packages/${action}" pkg "$action"
done
pkg clean
yes | apt autoremove

mkdir -p ~/.local/bin/
busybox --install -s ~/.local/bin/

tar -xvf "${HOME}/storage/downloads/ssh.tar.gz"

curl https://github.com/web-flow.gpg | gpg --import

python -m pip install --requirement "${0%/*}/requirements.txt" --user

# https://github.com/termux/termux-packages/issues/20039#issuecomment-2096494418
_file="$(find $PREFIX/lib/python3.11 -name "_sysconfigdata*.py")"
rm -rf $PREFIX/lib/python3.11/__pycache__
cp $_file "$_file".backup
sed -i 's|-fno-openmp-implicit-rpath||g' "$_file"
