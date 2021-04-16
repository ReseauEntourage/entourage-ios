source 'https://github.com/CocoaPods/Specs.git'

inhibit_all_warnings!
use_frameworks!
platform :ios, '9.0'

def sharedPods
    platform :ios, '9.0'

    pod 'AFNetworking', '~> 4.0'
    pod 'SWRevealViewController', '2.3.0'
    pod 'IQKeyboardManager', '~> 6.5'
    pod 'SVProgressHUD', '~> 2.2'
    pod 'SimpleKeychain', '~> 0.7'
    pod 'AWSS3', '~> 2.19.0'
    pod 'JVFloatLabeledTextField', '~> 1.2'
    pod 'libPhoneNumber-iOS'
    pod 'kingpin', '0.3.1'
    pod 'Firebase/Analytics', '~> 6.34'
    pod 'Firebase/Messaging', '~> 6.34'
    pod 'Firebase/InAppMessaging', '~> 6.34'
    pod 'Firebase/Crashlytics', '~> 6.34'
    pod 'SnapKit', '~> 4.0.0'
    pod 'GooglePlaces', '~> 3.8.0'
    pod 'GoogleMaps', '~> 3.8'
    pod 'TTTAttributedLabel'
end

target "entourage" do
    sharedPods
end

target "UnitTests" do
    sharedPods
end
