#!/usr/bin/env python3
"""Ajoute des fichiers Swift existants au projet Xcode (project.pbxproj).

Usage (depuis LOCAL/ios) :
    python3 Scripts/add_to_xcodeproj.py <cible> <fichier.swift> [<fichier.swift> ...]

<cible> : entourage | entourageTests | entourageUITests
Les chemins sont relatifs à LOCAL/ios. Le fichier doit déjà exister sur le disque
et son dossier doit déjà être un groupe du projet. Idempotent : un fichier déjà
référencé n'est pas ajouté une seconde fois.
"""
import random
import re
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
PBXPROJ = REPO / "entourage.xcodeproj" / "project.pbxproj"


def new_id(text):
    while True:
        candidate = "".join(random.choice("0123456789ABCDEF") for _ in range(24))
        if candidate not in text:
            return candidate


def parse_groups(text):
    """id -> {'children': [ids], 'path': str|None}."""
    groups = {}
    pattern = re.compile(
        r"\n\t\t([0-9A-F]{24})(?: /\* [^\n]*? \*/)? = \{\n\t\t\tisa = PBXGroup;\n"
        r"\t\t\tchildren = \(\n(.*?)\t\t\t\);\n(.*?)\t\t\};",
        re.S,
    )
    for match in pattern.finditer(text):
        children = re.findall(r"([0-9A-F]{24}) /\*", match.group(2))
        path = re.search(r"\n?\t\t\tpath = (.*?);", match.group(3))
        groups[match.group(1)] = {
            "children": children,
            "path": path.group(1).strip('"') if path else None,
        }
    return groups


def group_full_paths(text, groups):
    main = re.search(r"mainGroup = ([0-9A-F]{24});", text).group(1)
    result = {}

    def walk(group_id, prefix):
        group = groups[group_id]
        full = prefix if group["path"] is None else (f"{prefix}/{group['path']}" if prefix else group["path"])
        result[full] = group_id
        for child in group["children"]:
            if child in groups:
                walk(child, full)

    walk(main, "")
    return result


def sources_phase_id(text, target):
    section = text.split("/* Begin PBXNativeTarget section */")[1].split("/* End PBXNativeTarget section */")[0]
    for block in re.split(r"\n\t\t[0-9A-F]{24} /\* .*? \*/ = \{\n", section):
        if re.search(rf"\n\t\t\tname = {re.escape(target)};", block):
            match = re.search(r"([0-9A-F]{24}) /\* Sources \*/", block)
            if match:
                return match.group(1)
    raise SystemExit(f"Cible introuvable : {target}")


def add_file(text, target, rel_path):
    path = Path(rel_path)
    if not (REPO / path).exists():
        raise SystemExit(f"Fichier introuvable : {rel_path}")
    name = path.name
    if re.search(rf"path = {re.escape(name)};", text):
        print(f"déjà référencé : {name}")
        return text

    groups = parse_groups(text)
    folder = group_full_paths(text, groups).get(str(path.parent))
    if not folder:
        raise SystemExit(f"Aucun groupe Xcode pour le dossier {path.parent}")

    file_ref, build_file = new_id(text), new_id(text)
    ref_line = (f"\t\t{file_ref} /* {name} */ = {{isa = PBXFileReference; "
                f"lastKnownFileType = sourcecode.swift; path = {name}; sourceTree = \"<group>\"; }};\n")
    build_line = (f"\t\t{build_file} /* {name} in Sources */ = {{isa = PBXBuildFile; "
                  f"fileRef = {file_ref} /* {name} */; }};\n")
    text = text.replace("/* End PBXBuildFile section */", build_line + "/* End PBXBuildFile section */", 1)
    text = text.replace("/* End PBXFileReference section */", ref_line + "/* End PBXFileReference section */", 1)

    # enfant du groupe : avant la parenthèse fermante de ses children
    pattern = re.compile(rf"(\n\t\t{folder}(?: /\* [^\n]*? \*/)? = \{{\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = \(\n.*?)(\t\t\t\);)", re.S)
    text, count = pattern.subn(lambda m: f"{m.group(1)}\t\t\t\t{file_ref} /* {name} */,\n{m.group(2)}", text, count=1)
    assert count == 1, "groupe non modifié"

    phase = sources_phase_id(text, target)
    pattern = re.compile(rf"(\t\t{phase} /\* Sources \*/ = \{{\n\t\t\tisa = PBXSourcesBuildPhase;\n.*?files = \(\n.*?)(\t\t\t\);)", re.S)
    text, count = pattern.subn(lambda m: f"{m.group(1)}\t\t\t\t{build_file} /* {name} in Sources */,\n{m.group(2)}", text, count=1)
    assert count == 1, "phase Sources non modifiée"
    print(f"ajouté : {rel_path} -> {target}")
    return text


def main():
    if len(sys.argv) < 3:
        print(__doc__)
        return 2
    target, files = sys.argv[1], sys.argv[2:]
    text = PBXPROJ.read_text(encoding="utf-8")
    for rel in files:
        text = add_file(text, target, rel)
    PBXPROJ.write_text(text, encoding="utf-8")
    return 0


if __name__ == "__main__":
    sys.exit(main())
