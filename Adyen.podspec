Pod::Spec.new do |s|
  s.name = 'Adyen'
  s.version = '2.7.3'
  s.summary = "Adyen SDK for iOS"
  s.description = <<-DESC
    With Adyen SDK you can dynamically list all relevant payment methods for a specific transaction, so your shoppers can always pay with the method of their choice. The methods are listed based on the shopper's country, the transaction currency and amount.
  DESC

  s.homepage = 'https://adyen.com'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.author = { 'Adyen' => 'support@adyen.com' }
  s.source = { :git => 'https://github.com/Adyen/adyen-ios.git', :tag => "#{s.version}" }
  s.platform = :ios
  s.ios.deployment_target = '10.3'
  s.swift_version = '4.2'
  s.frameworks = 'Foundation'
  s.default_subspecs = 'Core', 'Card', 'SEPA'

  s.subspec 'Core' do |plugin|
    plugin.source_files = 'Adyen/**/*.swift'
    plugin.dependency 'AdyenInternal', "#{s.version}"
  end

  # Payment Methods
  s.subspec 'ApplePay' do |plugin|
    plugin.source_files = 'AdyenApplePay/**/*.swift'
    plugin.dependency 'Adyen/Core'
  end

  s.subspec 'Card' do |plugin|
    plugin.xcconfig = { 'SWIFT_INCLUDE_PATHS' => '${PODS_TARGET_SRCROOT}/AdyenCard/AdyenCSE' }
    plugin.preserve_paths = 'AdyenCard/AdyenCSE/module.modulemap'
    plugin.dependency 'Adyen/Core'
    plugin.dependency 'Adyen3DS2'
    plugin.source_files = 'AdyenCard/**/*.swift', 'AdyenCard/AdyenCSE/*.{h,m}'
    plugin.private_header_files = 'AdyenCard/AdyenCSE/*.h'
  end

  s.subspec 'SEPA' do |plugin|
    plugin.source_files = 'AdyenSEPA/**/*.swift'
    plugin.dependency 'Adyen/Core'
  end

  s.subspec 'WeChatPay' do |plugin|
    plugin.source_files = 'AdyenWeChatPay/**/*.swift', 'AdyenWeChatPay/WeChatSDK/*.h'
    plugin.preserve_paths = 'AdyenWeChatPay/WeChatSDK/module.modulemap'
    plugin.dependency 'Adyen/Core'
    plugin.xcconfig = { 'SWIFT_INCLUDE_PATHS' => '${PODS_TARGET_SRCROOT}/AdyenWeChatPay/WeChatSDK' }
    plugin.private_header_files = 'AdyenWeChatPay/WeChatSDK/*.h'
    plugin.vendored_libraries = 'AdyenWeChatPay/WeChatSDK/libWeChatSDK.a'
    plugin.libraries = 'z', 'stdc++', 'sqlite3.0'
    plugin.frameworks = 'SystemConfiguration', 'CoreTelephony'
  end

  s.subspec 'OpenInvoice' do |plugin|
    plugin.source_files = 'AdyenOpenInvoice/**/*.swift'
    plugin.dependency 'Adyen/Core'
  end

end
