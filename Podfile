source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '8.0'
use_frameworks!

target 'YandexCheckoutPaymentsExamplePods' do
    pod 'FunctionalSwift'
    pod 'CardIO'
    pod 'SwiftLint'

    pod 'YandexCheckoutPayments',
        :path => './'

end

post_install do |installer|
    puts "Turn off build_settings 'Require Only App-Extension-Safe API' on all pods targets"
    puts "Turn on build_settings 'Supress swift warnings' on all pods targets"
    puts "Turn off build_settings 'Documentation comments' on all pods targets"
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['PROVISIONING_PROFILE_SPECIFIER'] = ''
            config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'NO'
            config.build_settings['SWIFT_SUPPRESS_WARNINGS'] = 'YES'
            config.build_settings['CLANG_WARN_DOCUMENTATION_COMMENTS'] = 'NO'
        end
    end
end
