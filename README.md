# Building 'Grime6502-disc'

## Overview
The Python build script `build.py` creates the files and SSD disk image for *Grime6502-disc* on the BBC Micro. It processes source files to produce binary BASIC, text, machine code, and other data files.

## Requirements
* Python 3
* The beebasm assembler
* A recent version of the py8dis disassembler

If each of these tools is callable from the command line, you're ready to go.

## Usage
    python3 build.py

## Directory structure

    build/              intermediate files created during the build
    build/disc/         files destined for the final SSD
    build.py            the main build script
    control/            Python scripts that control disassembly of binary files
    original/           original files being replicated
    readme.md           this file
    source/             source code for each file on the disc
    tools/              Python libraries used by the build process

The `source/` folder contains editable source code for each file on the disc: detokenized BASIC text, plain text, assembly language, and binary data encoded as ASCII hex.

Note that `.asm` files are always overwritten during the build, because the `control/` scripts are expected to be updated iteratively — adding label names and commentary as py8dis disassembles the binary and makes the code easier to understand.

Once the source is sufficiently annotated, the project is either complete, or — if you want to make changes such as improvements or bug fixes — you can remove the `disassemble()` calls from `build.py`, at which point the `.asm` files become regular source files that can be edited freely.

BASIC files are stored as plain 7-bit ASCII text in `source/` and tokenized into binary BASIC programs at build time. Non-printable characters are handled with markup, as are non-standard tokenization schemes used by BASIC compressors, obfuscators, or optimizers (see File formats below). Where a BASIC file also contains binary code or data, the tokenized binary is assembled at the start of an assembly source file that continues with the remaining bytes.

Text files in `source/` have their line endings converted from the host OS convention to BBC Micro carriage returns (ASCII 13) during the build.

Binary files larger than 64 KB are stored as ASCII hex and converted to binary at build time, since most assemblers cannot handle files above this threshold.

---

## File formats

### BASIC
The source/ file contains the text of the BASIC program as it would be typed at the BASIC prompt, with the following exceptions:

| Markup    | Meaning |
| --------- | ------- |
| `\x87`    | Inserts a non-printable byte (e.g. for MODE 7 graphics in a `PRINT` statement) |
| `\{IF}`   | Inserts the token byte for `IF`, even where it would not normally be tokenized |
| `\{"IF"}` | Inserts the ASCII values for `I` and `F`, even where the keyword would normally be tokenized |
| `\\`      | Inserts a single backslash |

### Text
Source files use the host OS's native line endings in place of the BBC Micro's carriage returns (ASCII 13). The build process restores the correct line endings for the final file.

---

## Filenames
BBC Micro filenames can contain characters that are not available on the host os
filesystem. We convert any troublesome characters when storing them on the host 
os and convert back when writing to the SSD.

Table of 'problem' characters for filenames and their replacements:

    | Character | Substitute    |
    | --------- | ------------- | 
    |     /     | #slash        | 
    |     ?     | #question     | 
    |     <     | #less         | 
    |     >     | #greater      | 
    |     \     | #backslash    | 
    |     :     | #colon        |  
    |     *     | #star         | 
    |    \|     | #bar          | 
    |     "     | #quote        | 
    |     #     | ##            |

---
