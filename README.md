# Entourage - iOS application

[![bitrise](https://www.bitrise.io/app/cf17a1bd21f42797/status.svg?token=3wwkQuohTyC-rDiW7aXVeA)](https://www.bitrise.io/app/cf17a1bd21f42797)

Our goal is to create a local social network on smartphones to help the HOMELESS people fight their loneliness thru collaborative actions with neighbours.


## Getting Started

...

## Upload Symbols to Firebase

Crashlytics requires you to upload debug symbols.
You can use a run script build phase for Xcode to automatically upload debug symbols post-build. Find the run script here:
${BUILD_DIR%Build/*}/SourcePackages/checkouts/firebase-ios-sdk/Crashlytics/run

Another option for uploading symbols is to use the [upload-symbols](https://github.com/firebase/firebase-ios-sdk/raw/master/Crashlytics/upload-symbols) script. Place the script in a subdirectory of your project file (for example scripts/upload-symbols), then make sure that the script is executable:
chmod +x scripts/upload-symbols
This script can be used to manually upload dSYM files. For usage notes and additional instructions for the script, run upload-symbols without any parameters.

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
