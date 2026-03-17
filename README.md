# Building 'Grime6502'

## Overview
The Python build script `build.py` creates the files and SSD disk image for *Grime6502* on the BBC Micro.

This is a recovery project and improved version of Grime6502 for the BBC Micro. The original is available in 
binary from https://www.chibiakumas.com/6502/grime6502.php . The original is a quickly put together remake of 
a DOS game.

Only the binary and a few files of source are available at https://www.chibiakumas.com/6502/grime6502.php
so the source here was disassembled from the binary, and then labelled using the final video walkthrough of 
the code at https://www.youtube.com/watch?v=71-iRVYH6aY for reference.

The code has now been expanded to allow keyboard controls as well as joysticks, and fixes were made to the 
initialisation, the sound, and the joystick code. Some optimisations were also made to rendering font 
characters and sprites.

## Requirements
* The beebasm assembler

## Usage
    python3 build.py

## Directory structure

    build/              intermediate files created during the build
    build/disc/         files destined for the final SSD
    build.py            the build script
    original/           original files being replicated
    readme.md           this file
    source/             source code for each file on the disc
    tools/              Python libraries used by the build process
