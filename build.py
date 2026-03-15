#!/usr/bin/env python3
"""Build script for creating BBC Micro disk images for 'Grime6502-disc'.

This script:
- Disassembles the binaries using control files (see py8dis) into beebasm assembly
- Assembles them back into binaries
- Tokenizes BBC BASIC programs from text files
- Packages everything into an SSD disk image
"""

import os
import subprocess
import sys
from pathlib import Path

from tools import bbc_basic_tokenizer  # For tokenising BASIC programs
from tools import dfsimage             # For writing BBC disk images


# Get the full directory path of this script
script_dir = Path(__file__).resolve().parent


# Helper functions
def hextext_to_bin(src_path: str, dst_path: str) -> None:
    """
    Read a text file containing hexadecimal byte values (space or newline separated)
    and write them back to a binary file.
    Lines may contain comments (starting with '#') or extra whitespace, which are ignored.
    """
    import re

    hex_byte_re = re.compile(r'\b([0-9A-Fa-f]{2})\b')
    with open(src_path, 'r', encoding='utf-8') as fin, open(dst_path, 'wb') as fout:
        for line in fin:
            # drop inline comments
            line = line.split('#', 1)[0]
            for m in hex_byte_re.finditer(line):
                fout.write(bytes([int(m.group(1), 16)]))

def run_subprocess(args: list[str], error_message: str, cwd: Path | None = None) -> bytes:
    """Execute a subprocess and return stdout.

    Args:
        args: Command and arguments to execute.
        error_message: Message to display if the command fails.
        cwd: Working directory for the subprocess.

    Returns:
        The stdout output from the subprocess.
    """
    p = subprocess.run(args, capture_output=True, cwd=cwd)
    s = p.stderr.decode().strip()
    if s:
        print(s)
    
    if p.returncode != 0:
        print(args)
        print(p.stderr.decode().strip())
        print(error_message)
        if p.returncode:
            sys.exit(p.returncode)
    return p.stdout


def disassemble(python_filepath: str, asm_filepath: str) -> None:
    """Run a Python control script to create assembly files.

    Args:
        python_filepath: Relative path to the control script (within 'control' dir).
        asm_filepath: Relative path for the output assembly file (within 'source' dir).
    """
    python_filepath_full = script_dir / 'control' / python_filepath
    asm_filepath_full = script_dir / 'source' / asm_filepath

    args = ['python3', str(python_filepath_full), f'--beebasm', '--output', str(asm_filepath_full)]
    run_subprocess(args, 'disassemble failed', script_dir)


def make_inf(binary_filepath: Path, bbc_bin_filename: str, load_address: int, exec_address: int, locked: str) -> None:
    """Create a .inf metadata file for a BBC Micro binary.

    Args:
        binary_filepath: Path to the binary file.
        bbc_bin_filename: DFS filename (e.g. '$.TEMPEST').
        load_address: Memory address where the file should be loaded.
        exec_address: Memory address to execute from.
        locked: Lock status ('L' for locked, '' for unlocked).
    """
    inf_text = f'{bbc_bin_filename:<12} {load_address:06X} {exec_address:06X} {locked}'
    with open(str(binary_filepath) + '.inf', 'w') as text_file:
        text_file.write(inf_text)


def assemble(asm_filepath: str, binary_filepath: str) -> None:
    """Assemble a source file to a binary.

    Args:
        asm_filepath: Relative path to the assembly source (within 'source' dir).
        binary_filepath: Relative path for the output binary (within 'build/disc' dir).
    """
    asm_filepath_full = script_dir / 'source' / asm_filepath
    binary_filepath_full = script_dir / 'build' / 'disc' / binary_filepath
    asm_filename = asm_filepath_full.stem
    report_filepath = script_dir / 'build' / f'{asm_filename}_report.txt'

    # Assemble
    args = ['beebasm', '-o', str(binary_filepath_full), '-i', str(asm_filepath_full), '-v']

    report = run_subprocess(args, 'assembly failed', script_dir)
    with open(report_filepath, 'wb') as f:
        f.write(report)


def copy_text_to_bbc(source_filepath: Path, destination_filepath: Path) -> None:
    """Copy a text file, converting line endings to BBC Micro format.

    Args:
        source_filepath: Path to the source text file.
        destination_filepath: Path for the output file.
    """
    with open(source_filepath, 'rb') as f:
        content = f.read()

    # Replace host line terminator with BBC Micro line terminator (0x0d)
    with open(destination_filepath, 'wb') as f:
        f.write(content.replace(os.linesep.encode(), b'\x0d'))


def tokenize_basic(source_filepath: Path, destination_filepath: Path) -> None:
    """Tokenize a BBC BASIC source file.

    Args:
        source_filepath: Path to the BASIC source text file.
        destination_filepath: Path for the tokenized output file.
    """
    with open(source_filepath, 'rb') as f:
        tokenized_result = bbc_basic_tokenizer.tokenize_file(f, input_file_contains_escaped_chars=True)
        with open(destination_filepath, 'wb') as file:
            file.write(bytearray(tokenized_result))
        return len(tokenized_result)


def add_file(
    image: dfsimage.Image,
    input_file: Path | str,
    dfs: str,
    load_addr: int,
    exec_addr: int,
    locked: bool = True,
) -> None:
    """Add a file to a DFS disk image.

    Args:
        image: The DFS image to add the file to.
        input_file: Path to the file to add.
        dfs: DFS filename (e.g. '$.TEMPEST').
        load_addr: Memory address where the file should be loaded.
        exec_addr: Memory address to execute from.
        locked: Whether the file should be locked.
    """
    image.import_files(
        os_files=str(input_file),
        dfs_names=dfs,
        ignore_access=True,
        inf_mode=dfsimage.InfMode.NEVER,
        load_addr=load_addr,
        exec_addr=exec_addr,
        locked=locked,
        replace=True,
    )


# Make build/disc directory
(script_dir / 'build' / 'disc').mkdir(parents=True, exist_ok=True)

# Create binary $.!BOOT
destination_filepath = script_dir / 'build' / 'disc' / '$.!BOOT'
#disassemble('$.!BOOT.py', '$.!BOOT_beebasm.asm')
assemble('$.!BOOT_beebasm.asm', '$.!BOOT')
make_inf(destination_filepath, '$.!BOOT', 0x003000, 0x003000, '')

# Create .ssd
with dfsimage.Image.create(str(script_dir / 'Grime6502-disc_new.ssd')) as image:
    image.sides[0].title = 'GRIME6502'
    image.sides[0].opt = 2
    add_file(image, script_dir / 'build' / 'disc' / '$.!BOOT', '$.!BOOT', load_addr=0x003000, exec_addr=0x003000, locked=False)
