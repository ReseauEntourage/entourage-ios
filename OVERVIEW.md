# ios (entourage-ios) — overview

> Added by the `entourage_specs` meta-repo. The submodule's own canonical README lives at `README.md` (with `README_GUIDE_VC.md` and `readme.txt` for ancillary notes).

The native iOS client of the LOCAL product. Swift, Xcode, multiple build schemes (production / beta / store), Bitrise-driven CI, Crashlytics dSYM upload integrated into the build pipeline. Distributes on the App Store and to a beta channel via ad-hoc Bitrise builds.

## Interactions

- **Backend**: HTTPS REST against the Rails API at `https://api.entourage.social/api/v1/` (production) and `https://api-preprod.entourage.social/api/v1/` (staging).
- **Firebase**: `GoogleService-Info.plist` (prod) and `GoogleService-Info-social.entourage.ios.beta.plist` (beta) for Crashlytics, push notifications and analytics.
- **AWS S3**: image uploads via `AWSS3` pinned to `~> 2.19.X` (2.20+ removed `AWSS3TransferManager`).
- **Crashlytics**: dSYM uploaded automatically by Bitrise (`dsym-upload-to-crashlytics--no-cocoapods` step) and manually via `./firebase-ios-sdk/Crashlytics/upload-symbols`.
- **Deep linking**: standard iOS URL schemes for SMS-redirect routing.

## Installing / scripts

```bash
# CocoaPods install (Podfile lives in the repo root)
pod install

# Open the workspace
open entourage.xcworkspace

# Build via Xcode using one of the schemes:
#   Entourage-ios       (production)
#   EntourageBeta       (beta)
#   EntourageStore      (App Store)

# Bitrise CI workflows:
#   Entourage-Preprod   — beta ad-hoc build
#   (App Store + production via separate workflows)

# Manual dSYM upload to Crashlytics
./firebase-ios-sdk/Crashlytics/upload-symbols \
  -gsp GoogleService-Info.plist -p ios appDsyms.zip

# Build phase script chmod
chmod +x scripts/upload-symbols
```

`Scripts/` contains the helper scripts wired into Xcode build phases. `bitrise.yml` defines the Bitrise workflows and uses `manage-ios-code-signing@2` for certificates and provisioning profiles.

The repo also contains several `.diff` files (`patch_f.diff`, `patch_models.diff`, `patch_params.diff`, `patch_v.diff`, `patch_vc.diff`) and `patch_v2.swift` / `test_video_modal.swift` — these look like in-flight patches and not part of the canonical build pipeline.

## External libraries

- **Package manager**: CocoaPods (Podfile in repo root).
- **Pinned**: `AWSS3 ~> 2.19.X`.
- **Firebase SDK** (Crashlytics + push) — integrated via Pods and `GoogleService-Info.plist`.
- **Custom fonts**: Montserrat, Nunito Sans, Quicksand (in `Fonts/`).

## Used technologies

- **Language**: Swift.
- **IDE / build**: Xcode 26.2.x (Bitrise stack `osx-xcode-26.2.x`).
- **Dependency manager**: CocoaPods.
- **CI/CD**: Bitrise — code signing via `manage-ios-code-signing@2` (API key based automatic signing).
- **Distribution**: App Store + ad-hoc beta.

## Secrets

- `ApiKeys.plist` (repo root) — bundled into the build, holds API keys used at runtime. Names referenced from Swift code; values not included here.
- `GoogleService-Info.plist` (production Firebase config).
- `GoogleService-Info-social.entourage.ios.beta.plist` (beta Firebase config).
- Code signing certificates and provisioning profiles managed via Bitrise (not stored in the repo).
- Bitrise env vars (Crashlytics tokens, App Store Connect API keys, etc.) referenced from `bitrise.yml`.

There are no `.env` files — all sensitive material is either bundled at build time (`*.plist`) or injected by Bitrise.
