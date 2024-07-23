#!/bin/zsh

mkdir -p build

cmake -S . -B build \
    -DTOOLCHAINPATH=/usr/bin
make -C build

mergehex -m \
    build/secure/secure.elf \
    build/non-secure/non-secure.elf \
    -o build/merged.hex

nrfjprog --eraseall -f nrf91
nrfjprog --program build/merged.hex -f nrf91 --sectorerase --verify --reset
