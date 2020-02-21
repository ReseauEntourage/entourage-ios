#!/bin/sh

INFO_PLIST="${1:-entourage/entourage-Info.plist}"

PlistBuddy() {
  /usr/libexec/PlistBuddy -c "$(echo $@)" $INFO_PLIST
}

buildNumber=${BITRISE_BUILD_NUMBER:-buildNumberNotSet}
marketingVersion=$(PlistBuddy Print CFBundleShortVersionString)
PlistBuddy Set CFBundleVersion $buildNumber
PlistBuddy Set CFBundleShortVersionString $marketingVersion.$buildNumber
