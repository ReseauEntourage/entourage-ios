# Entourage - iOS application

[![bitrise](https://www.bitrise.io/app/cf17a1bd21f42797/status.svg?token=3wwkQuohTyC-rDiW7aXVeA)](https://www.bitrise.io/app/cf17a1bd21f42797)

Our goal is to create a local social network on smartphones to help the HOMELESS people fight their loneliness thru collaborative actions with neighbours.


## Getting Started

...

## Configuration — ApiKeys.plist

Sensitive keys are stored in `ApiKeys.plist` (gitignored). Copy the template and fill in the values:

```bash
cp ApiKeys.dist.plist ApiKeys.plist
```

| Key | Description |
|-----|-------------|
| `ApiKey` | API key identifying the app version against the backend |
| `HmacSecret` | Shared secret for HMAC-SHA256 request signing (anti-bot, see below) |

### HmacSecret — HMAC request signing

`HmacSecret` protects the account creation endpoint (`POST /api/v1/users`) against bots.
The app signs each request with `HMAC-SHA256(secret, "POST\n/api/v1/users\n{timestamp}\n{phone}")` and sends the result in the `X-Request-Signature` header.

- **Leave empty** in development: the backend skips verification when the secret is not configured.
- **Set in CI** (Bitrise env var `HMAC_SECRET_IOS`) before the release build; the Bitrise workflow injects it into `ApiKeys.plist`.
- The same secret must be set as `HMAC_SECRET_IOS` on the backend (Heroku config vars).

## Upload Symbols to Firebase

Crashlytics requires you to upload debug symbols.
You can use a run script build phase for Xcode to automatically upload debug symbols post-build. Find the run script here:
${BUILD_DIR%Build/*}/SourcePackages/checkouts/firebase-ios-sdk/Crashlytics/run

Another option for uploading symbols is to use the [upload-symbols](https://github.com/firebase/firebase-ios-sdk/raw/master/Crashlytics/upload-symbols) script. Place the script in a subdirectory of your project file (for example scripts/upload-symbols), then make sure that the script is executable:
chmod +x scripts/upload-symbols
This script can be used to manually upload dSYM files. For usage notes and additional instructions for the script, run upload-symbols without any parameters.

Commands:
> git clone https://github.com/firebase/firebase-ios-sdk.git
> ./firebase-ios-sdk/Crashlytics/upload-symbols -gsp GoogleService-Info.plist -p ios appDsyms7.9.2.zip

## Pod dependencies
AWSS3: stuck to 2.19.X because:
> AWS SDK for iOS 2.20.0
> Breaking Changes
> Removed deprecated clients AWS Mobile SDK for iOS has removed these deprecated clients (PR #3281):
> AWSS3TransferManager - Use Amplify Storage for uploads and downloads with Amazon S3.

## Authors

* **François Pellissier** - *Coordination* - [FrPellissier](https://github.com/FrPellissier)

See also the list of [contributors](https://github.com/ReseauEntourage/entourage-ios/graphs/contributors) who participated in this project.

## Acknowledgments

* Thanks to Jean-Marc and all the team @ [Entourage](https://www.entourage.social)
