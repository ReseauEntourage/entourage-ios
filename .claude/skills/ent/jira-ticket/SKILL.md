---
name: jira-ticket
description: Traite un ticket Jira de bout en bout sur entourage-ios — analyse, enrichissement produit/technique, implémentation, build, commit et passage en "To Merge". Se déclenche uniquement sur invocation explicite (/jira-ticket).
disable-model-invocation: true
argument-hint: [numéro-ticket]
allowed-tools: Bash(git add *), Bash(git commit *), Bash(git status *), Bash(git diff *), Bash(git log *), Bash(xcodebuild *), Bash(xcrun simctl *)
---

Tu vas traiter le ticket Jira $ARGUMENTS sur le repo entourage-ios.

## Étape 1 — Récupération

Récupère le ticket via l'outil MCP Jira (`mcp__jira__jira_get_issue` avec `$ARGUMENTS`) :
titre, description, critères d'acceptation, commentaires. Si le ticket référence des
maquettes ou pièces jointes utiles, note-le mais ne bloque pas dessus.

## Étape 2 — Analyse du code existant

Explore le projet pour comprendre ce qui existe déjà en lien avec le ticket. Points de
repère spécifiques à ce repo (voir [CLAUDE.md](CLAUDE.md)) :

- **Écran concerné** : cherche dans `entourage/Scenes/<Feature>/` (22 sous-dossiers, un
  par feature) et le storyboard associé dans `entourage/Storyboards/` (nom déclaré dans
  `StoryboardName`).
- **Nature de l'écran** : plein écran (`BaseFullScreenNavViewController`) ou pop-up
  modale (`BasePopViewController`, XIB) ? Le profil (`ProfileViewControllerSwiftUI.swift`)
  est le seul écran principal en SwiftUI aujourd'hui — regarde s'il existe déjà un
  équivalent SwiftUI avant de repartir sur de l'UIKit.
- **Appels réseau** : cherche le service correspondant dans
  `entourage/Network Managers/` (pattern callback-based, pas d'async/await) et
  l'endpoint dans `Endpoints.swift`.
- **Modèles** : `entourage/Models/` pour les structs `Codable` concernées.
- **Localisation** : les clés existantes dans `entourage/Assets/*.lproj/Localizable.strings`
  (français = locale de référence).
- **État/Auth** : si le ticket touche à l'utilisateur courant, `UserDefaults.currentUser`
  / `UserDefaults.token`, et le cas particulier du rôle ambassadeur
  (`user.isAmbassador()`, avec fallback sur `UserDefaults.currentUser?.roles` si
  l'endpoint de détail ne renvoie pas `roles`).

Identifie précisément : fichiers à toucher, état actuel de l'implémentation,
dépendances, et si un nouveau fichier Swift sera nécessaire (implique une modification
manuelle de `project.pbxproj`, voir Étape 4).

## Étape 3 — Enrichissement du ticket

Rédige une version enrichie de la description :
- **Angle produit** : cas limites, impacts UX non mentionnés, questions ouvertes.
- **Angle technique** : fichiers/composants identifiés à l'étape 2, écran UIKit vs
  SwiftUI, risques (ex. pbxproj à éditer à la main, endpoint qui ne renvoie pas tous les
  champs), points d'attention.

RÈGLE STRICTE : tu n'ajoutes JAMAIS de nouvelle fonctionnalité ni de changement de
périmètre. Tu précises et documentes ce qui est déjà spécifié, tu n'inventes rien.
Si un point te semble ambigu, signale-le comme question plutôt que de trancher.

Poste cette version enrichie en commentaire sur le ticket via
`mcp__jira__jira_add_comment` (ne remplace pas la description originale).

## Étape 4 — Implémentation

Fais le travail décrit dans le ticket, dans le respect strict des specs d'origine, en
suivant les conventions du repo :

- Écrans neufs : privilégie SwiftUI quand c'est raisonnable (préférence affirmée dans
  CLAUDE.md), sinon respecte le pattern UIKit existant (`BaseFullScreenNavViewController`
  / `BasePopViewController`).
- Réseau : ajoute la méthode côté service (`entourage/Network Managers/`) avec un
  completion handler, pas d'async/await ; déclare l'endpoint dans `Endpoints.swift`.
- Cellules : respecte le pattern de registration déjà utilisé dans le fichier concerné
  (XIB via `UINib` ou programmatique), et expose `identifier`.
- Fonts : `Quicksand-Bold` pour titres/boutons, `NunitoSans-Regular`/`NunitoSans-Bold`
  pour le corps de texte. En SwiftUI, utilise
  `Font(UIFont(name: "Quicksand-Bold", size: ...) ?? UIFont.systemFont(ofSize: ...))`,
  jamais `.font(.custom(...))`.
- Localisation : ajoute les clés dans tous les `.lproj/Localizable.strings` concernés,
  pas seulement `fr.lproj`.
- **Si tu crées un nouveau fichier `.swift`** : ajoute-le manuellement dans
  `entourage.xcodeproj/project.pbxproj` (PBXBuildFile + PBXFileReference + entrée de
  groupe + Sources build phase). Utilise un script Python si plusieurs fichiers sont
  ajoutés d'un coup.

Il n'y a pas de cible de test dans ce projet. Vérifie donc que ça compile avec :

```bash
xcodebuild -scheme EntourageBeta -destination "platform=iOS Simulator,id=<UDID>" build
```

(récupère un UDID valide via `xcrun simctl list devices available` si besoin). Un build
qui échoue bloque le passage à l'étape suivante.

## Étape 5 — Commit

Commit les changements avec un message qui suit le style du repo (conventional commits
en français, clé du ticket entre parenthèses en fin de première ligne), par exemple :

```
fix(scope): corrige le comportement X (EN-1234)
```

Regarde `git log --oneline -10` pour coller au style récent avant de choisir le
`scope`. Ne push jamais.

## Étape 6 — Transition

Récupère les transitions disponibles avec `mcp__jira__jira_get_transitions`, puis passe
le ticket au statut "To Merge" via `mcp__jira__jira_transition_issue`. Si ce statut
n'existe pas dans les transitions disponibles depuis l'état courant, signale-le plutôt
que de forcer un autre statut.
