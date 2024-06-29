#!/usr/bin/env sh

set -e -u

main() {
    setup_storage
    setup_packages
    setup_busybox
    setup_ssh
    setup_gpg
    setup_python
    setup_snowflake_proxy
}

setup_storage() {
    termux-setup-storage
}

setup_packages() {
    for action in install remove; do
        yes | xargs -a "${0%/*}/packages/${action}" pkg "$action"
    done
    pkg clean
    yes | apt autoremove
}

# https://gist.github.com/vv403/7ed8159a8f426e7711db147936f18048
setup_dotfiles() {
    curl --remote-name https://gist.githubusercontent.com/vv403/8ae6e050d2bf6d0dab8da80527f16065/raw/5ea34fff795f2c6b7548800080280a601fe8e713/dotfiles.sh
    chmod +x dotfiles.sh
    ./dotfiles.sh init
    rm dotfiles.sh
}

setup_busybox() {
    mkdir -p ~/.local/bin/
    busybox --install -s ~/.local/bin/
}

setup_ssh() {
    tar -xvf "${HOME}/storage/downloads/ssh.tar.gz"
}

setup_gpg() {
    curl https://github.com/web-flow.gpg | gpg --import
}

setup_python() {
    # https://github.com/termux/termux-packages/issues/20039#issuecomment-2096494418
    _file="$(find $PREFIX/lib/python3.11 -name "_sysconfigdata*.py")"
    rm -rf $PREFIX/lib/python3.11/__pycache__
    cp $_file "$_file".backup
    sed -i 's|-fno-openmp-implicit-rpath||g' "$_file"

    SODIUM_INSTALL=system python -m pip install --requirement "${0%/*}/requirements.txt" --user
}

setup_snowflake_proxy() {
    git clone https://gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/snowflake.git "${HOME}/snowflake/"
    go build -C "${HOME}/snowflake/proxy"
    ln -s "${HOME}/snowflake/proxy/proxy" "${HOME}/.local/bin/snowflake-proxy"
}

main "$@"
