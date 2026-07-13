# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run

```bash
# List available schemes
xcodebuild -list

# Build (use EntourageBeta for dev/preprod)
xcodebuild -scheme EntourageBeta -destination "platform=iOS Simulator,id=<UDID>" build

# Get simulator UDIDs
xcrun simctl list devices available
```

Schemes: `Entourage-ios` (prod), `EntourageBeta` (preprod/staging), `EntourageStore` (App Store).  
No test targets exist in this project.

## Architecture

### Navigation
UIKit-only (no SwiftUI at the root level — SwiftUI is used for specific screens embedded via `UIHostingController`).  
`AppState` is the navigation state machine: it switches between the unauthenticated flow (`StoryboardName.language`) and the main authenticated flow (`MainTabbarViewController` with 5 tabs).
We would like to switch the most possible on swift UI 
Screens are either:
- **Full-screen** — subclass `BaseFullScreenNavViewController`
- **Modal pop-up** — subclass `BasePopViewController` (XIB-based with custom chrome)

### Network Layer
All network calls are **callback-based** (no async/await). Pattern:

```swift
// Service layer: static methods with completion handlers
UserService.getDetailsForUser(userId: id) { user, error in ... }

// Services live in: entourage/Network Managers/
// Base HTTP: NetworkManager (singleton)
// Endpoints: entourage/Network Managers/Endpoints.swift
```

Environment (prod vs preprod) is resolved at launch by `EnvironmentConfigurationManager` from `AppConfigurations.plist` based on the bundle ID. API keys come from `ApiKeys.plist` (gitignored — use `ApiKeys.dist.plist` as template).

### Profile (SwiftUI)
The user profile is a SwiftUI screen: `ProfileViewControllerSwiftUI.swift` contains `ProfileView` + `ProfileViewModel` (ObservableObject). It is presented via `UIHostingController`. The UIKit `ProfilFullViewController` is legacy and no longer the primary profile screen.

### Cells
Mixed registration pattern:
- XIB-based: `ui_table_view.register(UINib(nibName: Cell.identifier, bundle: nil), forCellReuseIdentifier: Cell.identifier)`
- Programmatic: `ui_table_view.register(CellClass.self, forCellReuseIdentifier: CellClass.identifier)`

All cells expose `class var identifier: String { return String(describing: self) }`.

### State & Auth
- `UserDefaults.currentUser` — the logged-in `User` (Codable, stored/retrieved via `Extensions_UserDefaults.swift`)
- `UserDefaults.token` — derived from currentUser, appended to every API call as `?token=`
- Phone/password in Keychain via `SimpleKeychain` (`kKeychainPhone`, `kKeychainPassword`)

### Localization
All strings via `"key".localized` (extension on String). French is the primary locale (`fr.lproj/Localizable.strings`).

### Fonts
Two font families used throughout:
- **Quicksand-Bold** — titles, buttons, bold labels
- **NunitoSans-Regular / NunitoSans-Bold** — body text, subtitles

In SwiftUI always use `Font(UIFont(name: "Quicksand-Bold", size: 15) ?? UIFont.systemFont(ofSize: 15))` — `.font(.custom(...))` does not load these registered fonts reliably.

### Ambassador role
Users with `roles` containing `"ambassador"` or `"Animateur Entourage"` get extra UI (checked via `user.isAmbassador()`). The detail endpoint does not always return `roles` — fallback to `UserDefaults.currentUser?.roles` when missing.

## Key Directories

| Path | Contents |
|------|----------|
| `entourage/Scenes/` | All feature screens (22 subfolders) |
| `entourage/Network Managers/` | Services + Endpoints + NetworkManager |
| `entourage/Models/` | Codable structs (User, Event, Neighborhood…) |
| `entourage/Managers/` | EnvironmentConfigurationManager, DeeplinkManager, WebLinkManager… |
| `entourage/Settings/` | Constants, ApplicationTheme (colors/fonts), Analytics keys |
| `entourage/Tools/` | Base controllers, UIKit extensions |
| `entourage/Views/` | Shared cells, MJComponents (MJAlertController, MJNavBackView…) |
| `entourage/Storyboards/` | 24 storyboards, one per feature — names in `StoryboardName` struct |
| `entourage/Assets/*.lproj/` | Localization strings |

## Adding Files to Xcode
New `.swift` files must be added to `entourage.xcodeproj/project.pbxproj` manually (PBXBuildFile + PBXFileReference + group entry + Sources build phase). Script it with Python if adding multiple files.
