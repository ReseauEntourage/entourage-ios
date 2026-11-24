#!/usr/bin/env python3
"""Audit d'accessibilité des xib et storyboards (lecture seule).

Usage (depuis LOCAL/ios) :
    python3 Scripts/a11y_audit.py icons    # boutons « icône seule » sans nom vocal
    python3 Scripts/a11y_audit.py small    # boutons à dimension fixe sous 44 pt
    python3 Scripts/a11y_audit.py icons --json

Ne modifie aucun fichier. Les chiffres attendus au 24/11/2026 :
22 boutons icône seule sans nom, 79 boutons fixes sous 44 pt (sur 323).
"""
import json
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent / "entourage"
MIN_SIZE = 44.0


def interface_files():
    return sorted(list(ROOT.rglob("*.xib")) + list(ROOT.rglob("*.storyboard")))


def button_title(btn):
    """Titre visible du bouton (état normal ou configuration), ou ''."""
    for state in btn.iter("state"):
        if state.get("key") == "normal" and state.get("title"):
            return state.get("title")
    for conf in btn.iter("buttonConfiguration"):
        if conf.get("title"):
            return conf.get("title")
    return btn.get("title") or ""


def button_image(btn):
    for state in btn.iter("state"):
        if state.get("key") == "normal" and state.get("image"):
            return state.get("image")
    for state in btn.iter("state"):
        if state.get("key") == "normal" and state.get("backgroundImage"):
            return state.get("backgroundImage")
    for conf in btn.iter("buttonConfiguration"):
        if conf.get("image"):
            return conf.get("image")
    return ""


def has_accessibility_label(btn):
    for acc in btn.iter("accessibility"):
        if acc.get("label"):
            return True
    # clé de libellé posée en attribut d'exécution (voir Extensions_Accessibility.swift)
    for attr in btn.iter("userDefinedRuntimeAttribute"):
        if attr.get("keyPath") in ("a11yKey", "accessibilityLabel"):
            return True
    return False


def outlet_names(root):
    """id de destination -> noms d'outlets qui y mènent."""
    names = {}
    for outlet in root.iter("outlet"):
        dest = outlet.get("destination")
        if dest:
            names.setdefault(dest, []).append(outlet.get("property"))
    return names


def own_fixed_sizes(btn, root):
    """Dimensions fixes (largeur/hauteur) imposées au bouton, en points."""
    sizes = []
    btn_id = btn.get("id")
    for constraint in btn.iter("constraint"):
        if constraint.get("secondItem") or constraint.get("secondAttribute"):
            continue
        attr = constraint.get("firstAttribute")
        if attr in ("width", "height") and constraint.get("constant"):
            sizes.append((attr, float(constraint.get("constant"))))
    for constraint in root.iter("constraint"):
        if constraint.get("firstItem") != btn_id or constraint.get("secondItem"):
            continue
        attr = constraint.get("firstAttribute")
        if attr in ("width", "height") and constraint.get("constant"):
            sizes.append((attr, float(constraint.get("constant"))))
    return sizes


def scan(kind):
    rows = []
    total = 0
    for path in interface_files():
        try:
            root = ET.parse(path).getroot()
        except ET.ParseError:
            continue
        outlets = outlet_names(root)
        for btn in root.iter("button"):
            total += 1
            rel = str(path.relative_to(ROOT.parent))
            row = {
                "file": rel,
                "id": btn.get("id"),
                "customClass": btn.get("customClass") or "",
                "image": button_image(btn),
                "outlets": outlets.get(btn.get("id"), []),
            }
            if kind == "icons":
                if button_image(btn) and not button_title(btn) and not has_accessibility_label(btn):
                    rows.append(row)
            else:
                fixed = [(a, c) for a, c in own_fixed_sizes(btn, root) if c < MIN_SIZE]
                if fixed:
                    row["fixed"] = fixed
                    rows.append(row)
    return rows, total


def swift_files():
    return sorted(p for p in ROOT.rglob("*.swift"))


def swiftui_blocks(lines, start):
    """Texte du bouton SwiftUI qui commence à `start` : accolades équilibrées + modificateurs qui suivent."""
    depth, seen_brace, i = 0, False, start
    while i < len(lines):
        for ch in lines[i]:
            if ch == "{":
                depth += 1
                seen_brace = True
            elif ch == "}":
                depth -= 1
        i += 1
        if seen_brace and depth <= 0:
            nxt = lines[i].strip() if i < len(lines) else ""
            if nxt.startswith("}") or (nxt.startswith(".") and not nxt.startswith("..")):
                continue
            break
    return "\n".join(lines[start:i])


# Candidats de l'heuristique relus à la main et écartés (nommés ailleurs ou pas des boutons).
KNOWN_OK = (
    ("EventCreatePhase3View.swift", "Button(action: action)"),        # compteur +/- : nommé par l'appelant
    ("ActionFormContainerViewController.swift", "formStore.setImage"),  # pas un bouton
    ("NotifInAppCell.swift", "ui_image"),                               # image de notification
    ("SurveyView.swift", "radioButton.setImage"),                       # nommé par NeighborhoodPostCell (question)
    ("MainFilterChipsCell.swift", "btn.setImage"),                      # le chip a un titre (setTitle plus haut)
    ("GMSAutoCompleteVC.swift", "UISearchBar.appearance"),              # apparence globale
)


def is_known_ok(rel, text):
    return any(rel.endswith(f) and frag in text for f, frag in KNOWN_OK)


def scan_code():
    """Candidats « icône seule sans nom » dans le code Swift (heuristique, à relire)."""
    swiftui, uikit = [], []
    for path in swift_files():
        lines = path.read_text(encoding="utf-8", errors="ignore").splitlines()
        rel = str(path.relative_to(ROOT.parent))
        for n, line in enumerate(lines):
            stripped = line.strip()
            if stripped.startswith("//"):
                continue
            if stripped.startswith("Button") and ("{" in stripped or "(" in stripped):
                block = swiftui_blocks(lines, n)
                if "Image(" in block and "Text(" not in block and "Label(" not in block \
                        and "accessibilityLabel" not in block and "accessibilityHidden" not in block \
                        and not is_known_ok(rel, stripped):
                    swiftui.append((rel, n + 1, stripped[:70]))
            if ".setImage(" in stripped and not is_known_ok(rel, stripped):
                window = "\n".join(lines[max(0, n - 12): n + 12])
                if "setTitle(" not in window and "accessibilityLabel" not in window:
                    uikit.append((rel, n + 1, stripped[:70]))
    return swiftui, uikit


REQUIRED_LANGS = ("fr", "en")   # langues des libellés vocaux (décision 1.3 : FR + EN, repli FR)


def defined_keys(lang):
    import re
    path = ROOT / "Assets" / f"{lang}.lproj" / "Localizable.strings"
    return set(re.findall(r'^"([^"]+)"\s*=', path.read_text(encoding="utf-8"), re.M))


def used_keys():
    """Clés `a11y_*` utilisées dans le code Swift et en attribut d'exécution `a11yKey` des xib/storyboards."""
    import re
    used = {}
    for path in swift_files():
        for key in re.findall(r'"(a11y_[a-z0-9_]+)"', path.read_text(encoding="utf-8", errors="ignore")):
            used.setdefault(key, set()).add(str(path.relative_to(ROOT.parent)))
    for path in interface_files():
        for key in re.findall(r'keyPath="a11yKey" value="([^"]+)"', path.read_text(encoding="utf-8", errors="ignore")):
            used.setdefault(key, set()).add(str(path.relative_to(ROOT.parent)))
    return used


def check_keys():
    """Échoue (code 1) si une clé de libellé vocal utilisée manque dans une langue requise."""
    used = used_keys()
    failures = 0
    for lang in REQUIRED_LANGS:
        defined = defined_keys(lang)
        for key, files in sorted(used.items()):
            if key not in defined:
                failures += 1
                print(f"MANQUE [{lang}] {key}  (utilisée dans {', '.join(sorted(files))})")
    print(f"{len(used)} clés a11y_ utilisées, {failures} manquantes ({'/'.join(REQUIRED_LANGS)})")
    return 1 if failures else 0


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    if args and args[0] == "keys":
        return check_keys()
    if args and args[0] == "code":
        swiftui, uikit = scan_code()
        for title, rows in (("SwiftUI", swiftui), ("UIKit", uikit)):
            print(f"== {title}")
            for rel, line, text in rows:
                print(f"{rel}:{line}  {text}")
        print(f"\n{len(swiftui)} SwiftUI, {len(uikit)} UIKit (candidats à relire)")
        return 0
    if not args or args[0] not in ("icons", "small"):
        print(__doc__)
        return 2
    rows, total = scan(args[0])
    if "--json" in sys.argv:
        print(json.dumps(rows, ensure_ascii=False, indent=2))
        return 0
    for row in rows:
        extra = f" fixed={row['fixed']}" if "fixed" in row else ""
        print(f"{row['file']}  id={row['id']}  class={row['customClass'] or '-'}  "
              f"image={row['image'] or '-'}  outlets={','.join(row['outlets']) or '-'}{extra}")
    print(f"\n{len(rows)} boutons sur {total} ({args[0]})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
