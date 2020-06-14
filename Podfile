source 'https://github.com/CocoaPods/Specs.git'

inhibit_all_warnings!
use_frameworks!
platform :ios, '9.0'

def sharedPods
    platform :ios, '9.0'

    pod 'AFNetworking'
    pod 'SWRevealViewController', '2.3.0'
    pod 'MBProgressHUD', '0.8'
    pod 'IQKeyboardManager'
    pod 'SVProgressHUD'
    pod 'SimpleKeychain', '~> 0.7'
    pod 'AWSS3', '~> 2.4'
    pod 'Fabric'
    pod 'Crashlytics', '~>  3.9'
    pod 'JVFloatLabeledTextField'
    pod 'libPhoneNumber-iOS'
    pod 'Mixpanel'
    pod 'kingpin', '0.3.1'
    pod 'FBSDKCoreKit'
    pod 'Firebase/Analytics'
    pod 'Firebase/Messaging'
    pod 'Firebase/InAppMessaging'
    pod 'SnapKit', '~> 4.0.0'
    pod 'GooglePlaces'
    pod 'GoogleMaps'
    pod 'SDWebImage'
    pod 'TTTAttributedLabel'
    pod 'SwiftLint'
end

target "entourage" do
    sharedPods
end

target "pfp" do
    sharedPods
end

target "UnitTests" do
    sharedPods
end
