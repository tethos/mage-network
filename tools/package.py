"""Build a release zip for CurseForge / Wago / GitHub. Pure Python.

    python tools/package.py

Reads the version from MageNetwork/MageNetwork.toc and writes
    dist/MageNetwork-<version>.zip   (contains the MageNetwork/ folder)
    dist/release.json                (metadata used by some addon managers)
"""
import json
import os
import re
import sys
import zipfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ADDON = "MageNetwork"
SRC = os.path.join(ROOT, ADDON)
DIST = os.path.join(ROOT, "dist")
SKIP = {".DS_Store", "Thumbs.db", "desktop.ini"}


def toc_field(name):
    toc = open(os.path.join(SRC, ADDON + ".toc"), encoding="utf-8").read()
    m = re.search(r"^## %s:\s*(.+)$" % re.escape(name), toc, re.M)
    return m.group(1).strip() if m else None


def main():
    version = toc_field("Version")
    interface = toc_field("Interface")
    if not version:
        sys.exit("No '## Version:' in the TOC.")
    os.makedirs(DIST, exist_ok=True)
    name = "%s-%s.zip" % (ADDON, version)
    path = os.path.join(DIST, name)
    count = 0
    with zipfile.ZipFile(path, "w", zipfile.ZIP_DEFLATED) as z:
        for folder, _, files in os.walk(SRC):
            for f in sorted(files):
                if f in SKIP:
                    continue
                full = os.path.join(folder, f)
                arc = os.path.relpath(full, ROOT).replace(os.sep, "/")
                z.write(full, arc)
                count += 1
    meta = {"releases": [{
        "name": ADDON,
        "version": version,
        "filename": name,
        "nolib": False,
        "metadata": [{"flavor": "mainline", "interface": int(interface or 0)}],
    }]}
    with open(os.path.join(DIST, "release.json"), "w", encoding="utf-8") as f:
        json.dump(meta, f, indent=2)
    print("Wrote dist/%s (%d files)" % (name, count))


if __name__ == "__main__":
    main()
