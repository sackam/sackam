#!/usr/bin/env python3
"""Generate static pages with shared header/footer using only the standard library."""

import argparse
from pathlib import Path
import re


ROOT = Path(__file__).resolve().parent.parent


def render(template, values):
    return re.sub(r"\{\{(\w+)\}\}", lambda match: values[match[1]], template)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="Check dist without writing")
    args = parser.parse_args()
    partials = {
        name: (ROOT / "src/partials" / f"{name}.html").read_text(encoding="utf-8").rstrip("\n")
        for name in ("header", "footer")
    }
    stale = []
    for source in sorted((ROOT / "src/pages").rglob("*.html")):
        relative = source.relative_to(ROOT / "src/pages")
        japanese = relative.parts[0] == "ja"
        home = "/ja/" if japanese else "/"
        values = {
            "home": home,
            "home_label": "SACKAM WORKS トップ" if japanese else "SACKAM WORKS home",
            "nav_label": "メインナビゲーション" if japanese else "Main navigation",
            "section_base": "" if relative.name == "index.html" else home,
            "other_home": "/" if japanese else "/ja/",
            "other_lang": "en" if japanese else "ja",
            "other_label": "English" if japanese else "日本語",
        }
        components = {name: render(template, values) for name, template in partials.items()}
        page = render(source.read_text(encoding="utf-8"), components)
        destination = ROOT / "dist" / relative
        if args.check:
            if not destination.exists() or destination.read_text(encoding="utf-8") != page:
                stale.append(str(relative))
        else:
            destination.parent.mkdir(parents=True, exist_ok=True)
            destination.write_text(page, encoding="utf-8")
    if stale:
        parser.exit(1, "Outdated dist files: " + ", ".join(stale) + "\nRun python3 scripts/build.py\n")
    print("Static pages are up to date." if args.check else "Generated static pages in dist/.")


if __name__ == "__main__":
    main()
