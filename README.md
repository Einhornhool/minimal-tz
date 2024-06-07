# Minimal TrustZone-M Example
*This code is based on the examples provided here: https://devzone.nordicsemi.com/f/nordic-q-a/96093/nrf9160-porting-the-modem-library-to-work-with-bare-metal-application*
*and here https://devzone.nordicsemi.com/f/nordic-q-a/92877/bare-metal-programming-on-the-nrf9160*

This is a minimal bare-metal example of a TrustZone-M application for the nRF9160dk.
It simply turns four LEDs on and off.

This example builds a secure image with three **secure entry functions** and a non-secure image that calls those functions.

An in-depth explanation will be found in a blog post (tbd).

## Requirements
- [Arm GNU toolchain](https://developer.arm.com/Tools%20and%20Software/GNU%20Toolchain)
- [nRF Commandline Tools](https://www.nordicsemi.com/Products/Development-tools/nRF-Command-Line-Tools)

## Usage
1. Clone this repository with `git clone --recurse-submodules https://github.com/Einhornhool/minimal-tz.git`
2. Open the Makefile and set the following paths:
    - `TOOLCHAINPATH` (path to Arm Toolchain)
    - `MERGEHEX` (path to mergehex command)
3. Build and flash with `make all flash`
