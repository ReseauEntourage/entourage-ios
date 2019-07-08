#!/bin/sh

INFO_PLIST="${1:-entourage/entourage-Info.plist}"

buildNumber=${BITRISE_BUILD_NUMBER:-buildNumberNotSet}
exec `/usr/libexec/PlistBuddy -c "Set CFBundleVersion $buildNumber" $INFO_PLIST`
echo $buildNumber
