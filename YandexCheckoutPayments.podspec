Pod::Spec.new do |s|
  s.name      = 'YandexCheckoutPayments'
  s.version   = '3.7.1'
  s.homepage  = 'https://github.com/yandex-money/yandex-checkout-payments-swift'
  s.license   = {
    :type => "MIT",
    :file => "LICENSE"
  }
  s.authors = 'Yandex Checkout'
  s.summary = 'Yandex Checkout Payments'

  s.source = {
    :git => 'https://github.com/yandex-money/yandex-checkout-payments-swift.git',
    :tag => s.version.to_s
  }

  s.ios.deployment_target = '10.0'
  s.swift_version = '5.0'

  s.ios.source_files  = 'YandexCheckoutPayments/**/*.{h,swift}', 'YandexCheckoutPayments/*.{h,swift}'
  s.ios.resources = [
    'YandexCheckoutPayments/Public/Resources/*.xcassets',
    'YandexCheckoutPayments/Public/Resources/**/*.plist',
    'YandexCheckoutPayments/Public/Resources/**/*.json',
    'YandexCheckoutPayments/Public/Resources/*.lproj/*.strings'
  ]

  s.ios.framework  = 'UIKit'
  s.ios.framework  = 'PassKit'
  s.ios.library = 'z'
  s.ios.vendored_frameworks = [
    'Frameworks/TMXProfiling.framework',
    'Frameworks/TMXProfilingConnections.framework',
    'Frameworks/MoneyAuth.xcframework',
  ]

  s.pod_target_xcconfig = {
    'OTHER_LDFLAGS' => '-framework "TMXProfiling"',
    'FRAMEWORK_SEARCH_PATHS' => '"${PODS_ROOT}/../Frameworks"'
  }

  s.ios.dependency 'FunctionalSwift', '~> 1.1.0'
  s.ios.dependency 'When', '~> 4.0.0'

  s.ios.dependency 'YandexMoneyCoreApi', '~> 1.8.0'
  s.ios.dependency 'YandexCheckoutPaymentsApi', '~> 2.1.0'
  s.ios.dependency 'YandexCheckoutWalletApi', '~> 2.1.0'
  s.ios.dependency 'YandexMobileMetrica/Dynamic', '~> 3.7.0'
end
