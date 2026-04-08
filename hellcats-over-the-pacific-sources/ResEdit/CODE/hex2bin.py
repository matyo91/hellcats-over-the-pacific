#!/usr/bin/env python3

# this tools helps convert CODE raw export to binary that can be read in ghidra

import argparse
import pathlib
import re
import binascii
import sys


def main():
    parser = argparse.ArgumentParser(
        description="Convert a hex dump file to a raw binary file"
    )
    parser.add_argument(
        "input",
        type=pathlib.Path,
        help="Path to the input file containing hexadecimal data",
    )
    parser.add_argument(
        "-o",
        "--output",
        type=pathlib.Path,
        help="Path to the output binary file (default: <input>.bin)",
    )

    args = parser.parse_args()

    if not args.input.exists():
        print(f"Error: input file does not exist: {args.input}", file=sys.stderr)
        sys.exit(1)

    # Read input
    text = args.input.read_text(errors="ignore")

    # Keep only hex chars
    hex_data = re.sub(r"[^0-9A-Fa-f]", "", text)

    if len(hex_data) % 2 != 0:
        print("Error: odd number of hex characters after cleanup", file=sys.stderr)
        sys.exit(1)

    # Convert
    try:
        binary = binascii.unhexlify(hex_data)
    except binascii.Error as e:
        print(f"Error while decoding hex: {e}", file=sys.stderr)
        sys.exit(1)

    # Output path
    output = args.output or args.input.with_suffix(args.input.suffix + ".bin")

    output.write_bytes(binary)

    print(f"OK: wrote {len(binary)} bytes to {output}")


if __name__ == "__main__":
    main()
