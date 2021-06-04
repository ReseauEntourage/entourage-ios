source 'https://github.com/CocoaPods/Specs.git'

inhibit_all_warnings!
use_frameworks!
platform :ios, '11.0'

def sharedPods
    platform :ios, '11.0'

    pod 'AFNetworking', '~> 4.0'
    pod 'IQKeyboardManager', '~> 6.5'
    pod 'SVProgressHUD', '~> 2.2'
    pod 'SimpleKeychain', '~> 0.7'
    pod 'AWSS3', '~> 2.19.0'
    pod 'kingpin', '0.3.1'
    pod 'Firebase/Analytics', '~> 8.0.0'
    pod 'Firebase/Messaging', '~> 8.0.0'
    pod 'Firebase/Crashlytics', '~> 8.0.0'
    pod 'SnapKit', '~> 4.0.0'
    pod 'GooglePlaces', '~> 4.2.0'
    pod 'TTTAttributedLabel'
end

target "entourage" do
    sharedPods
end

target "UnitTests" do
    sharedPods
end
