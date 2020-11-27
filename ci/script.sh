#!/usr/bin/env bash

set -euxo pipefail

if [ -n "${TARGET:-}" ]; then
    cargo check --target $TARGET

    if [[ $TARGET == riscv* ]]; then
        if [ -n "${RUSTC_LINKER:-}" ]; then
            PATH="$PATH:$PWD/gcc/bin"
            TARGET_UNDERSCORES=${TARGET//-/_}
            TARGET_UPPERCASE=${TARGET_UNDERSCORES^^}
            export CARGO_TARGET_${TARGET_UPPERCASE}_LINKER=${RUSTC_LINKER}
        fi

        cargo build --target $TARGET --examples
    fi

    if [ $TRAVIS_RUST_VERSION = nightly ]; then
        cargo check --target $TARGET --features inline-asm
    fi
fi

if [ -n "${CHECK_BLOBS:-}" ]; then
    PATH="$PATH:$PWD/gcc/bin"
    ./check-blobs.sh
fi

if [ -n "${RUSTFMT:-}" ]; then
    echo $PATH
    which cargo
    which rustup
    which rustc
    ls -l $HOME/.cargo/bin
    ls -l /home/travis/.cargo/bin
    export PATH="$PATH:$HOME/.cargo/bin"
    cargo fmt -- --check
fi
