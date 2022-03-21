#! /usr/bin/env python

import sys
import argparse

v = sys.version_info
parser = argparse.ArgumentParser(description="Get canonical name.")
parser.add_argument(
    "name",
    type=str,
    nargs="?",
    default="",
    help="package name",
)
parser.add_argument(
    "-v",
    "--version",
    default="0.0.0",
    help="package version",
)
parser.add_argument(
    "-n",
    "--build-number",
    default="0",
    help="build number",
)
parser.add_argument(
    "-e",
    "--extension",
    default="tar.bz2",
    help="package extension",
)
args = parser.parse_args()

print(f"{args.name}-{args.version}-py{v.major}{v.minor}_{args.build_number}.{args.extension}")

