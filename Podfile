source 'https://github.com/CocoaPods/Specs.git'
source 'git@github.com:yoomoney/cocoa-pod-specs.git'

platform :ios, '10.0'
use_frameworks!

project 'YooKassaPaymentsDemoApp.xcodeproj'
workspace 'YooKassaPayments.xcworkspace'

target 'YooKassaPaymentsDemoApp' do
  pod 'CardIO'
  pod 'SwiftLint'
  pod 'Reveal-SDK', :configurations => ['Debug']

  pod 'YooKassaPayments', :path => './'
  pod 'YooKassaPaymentsApi', '~> 2.11.0'
end

post_install do |installer|
  puts "Turn off build_settings 'Require Only App-Extension-Safe API' on all pods targets"
  puts "Turn on build_settings 'Supress swift warnings' on all pods targets"
  puts "Turn off build_settings 'Documentation comments' on all pods targets"
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['PROVISIONING_PROFILE_SPECIFIER'] = ''
      config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'NO'
      config.build_settings['CLANG_WARN_DOCUMENTATION_COMMENTS'] = 'NO'
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '10.0'
    end
  end
end
