#!/usr/bin/env python3
"""Prepare Cloudflare Pages assets without Apache or macOS metadata files."""

from pathlib import Path
import shutil
import subprocess
import sys


ROOT = Path(__file__).resolve().parent.parent
DESTINATION = ROOT / ".wrangler/pages"


def main():
    subprocess.run([sys.executable, str(ROOT / "scripts/build.py")], check=True)
    if DESTINATION.exists():
        shutil.rmtree(DESTINATION)
    shutil.copytree(
        ROOT / "dist",
        DESTINATION,
        ignore=shutil.ignore_patterns(".htaccess", ".DS_Store", "._*"),
    )
    print("Prepared Cloudflare Pages assets in .wrangler/pages/.")


if __name__ == "__main__":
    main()
