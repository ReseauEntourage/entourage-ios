#!/usr/bin/env python3
"""Pose `ExpandedHitAreaButton` sur les boutons de xib/storyboard à dimension fixe sous 44 pt.

Usage (depuis LOCAL/ios) :
    python3 Scripts/a11y_expand_hit_area.py            # simulation : liste, n'écrit rien
    python3 Scripts/a11y_expand_hit_area.py --apply    # applique

Ajoute seulement `customClass`, `customModule` et `customModuleProvider` à la balise <button> :
ni contraintes, ni taille visible, ni outlets ne sont touchés. Les boutons qui ont déjà une classe
personnalisée (ex. Checkbox) sont ignorés : ils héritent de ExpandedHitAreaButton dans le code.
Idempotent (relancer ne change rien).
"""
import re
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import a11y_audit as audit  # noqa: E402

CLASS = "ExpandedHitAreaButton"
MODULE = "Ent_Beta"   # valeur déjà utilisée par la grande majorité des xib/storyboards du projet


def main():
    apply = "--apply" in sys.argv
    touched = 0
    for path in audit.interface_files():
        root = ET.parse(path).getroot()
        targets = []
        for btn in root.iter("button"):
            if btn.get("customClass"):
                continue
            if [1 for _a, c in audit.own_fixed_sizes(btn, root) if c < audit.MIN_SIZE]:
                targets.append(btn.get("id"))
        if not targets:
            continue
        text = path.read_bytes().decode("utf-8")
        for button_id in targets:
            pattern = re.compile(rf'(<button\b[^>]*?\bid="{re.escape(button_id)}")([^>]*>)')
            text, n = pattern.subn(rf'\1 customClass="{CLASS}" customModule="{MODULE}" customModuleProvider="target"\2', text, count=1)
            if n != 1:
                raise SystemExit(f"balise introuvable : {path} {button_id}")
            touched += 1
        print(f"{path.relative_to(audit.ROOT.parent)} : {len(targets)} bouton(s)")
        if apply:
            path.write_bytes(text.encode("utf-8"))
    print(f"\n{touched} boutons {'modifiés' if apply else 'à modifier (simulation, relancer avec --apply)'}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
