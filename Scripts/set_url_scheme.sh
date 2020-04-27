#!/bin/bash

INFO_PLIST="${1:-entourage/entourage-Info.plist}"

InfoPlist() {
  /usr/libexec/PlistBuddy -c "$(echo $@)" $INFO_PLIST
}

ConfigPlist() {
  /usr/libexec/PlistBuddy -c "$(echo $@)" AppConfigurations.plist
}

# for each url scheme defined in Info.plist
for i in {0..10}; do
  # read the scheme's bundle name
  infoItemBundle=$(InfoPlist Print CFBundleURLTypes:${i}:CFBundleURLName)
  # if it's ours
  if [[ $infoItemBundle == social.entourage.entourageios* ]]; then
    # read the scheme we want from AppConfigurations.plist
    configScheme=$(ConfigPlist Print ${PRODUCT_BUNDLE_IDENTIFIER}:URLScheme)
    # write it in Info.plist at this position
    InfoPlist Set CFBundleURLTypes:${i}:CFBundleURLSchemes:0 $configScheme
    # stop searching
    break
  fi
done
