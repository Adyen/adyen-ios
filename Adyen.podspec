Pod::Spec.new do |s|
  s.name = 'Adyen'
  s.version = '3.5.0'
  s.summary = "Adyen Components for iOS"
  s.description = <<-DESC
    Adyen Components for iOS allows you to accept in-app payments by providing you with the building blocks you need to create a checkout experience.
  DESC

  s.homepage = 'https://adyen.com'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.author = { 'Adyen' => 'support@adyen.com' }
  s.source = { :git => 'https://github.com/Adyen/adyen-ios.git', :tag => "#{s.version}" }
  s.platform = :ios
  s.ios.deployment_target = '10.0'
  s.swift_version = '5.0'
  s.frameworks = 'Foundation'
  s.default_subspecs = 'Core', 'Card', 'DropIn'

  s.subspec 'Core' do |plugin|
    plugin.source_files = 'Adyen/**/*.swift'
    plugin.resource_bundles = {
        'Adyen' => [
            'Adyen/Assets/**/*.strings'
        ]
    }
  end

  s.subspec 'DropIn' do |plugin|
    plugin.source_files = 'AdyenDropIn/**/*.swift'
    plugin.dependency 'Adyen/Core'
    plugin.dependency 'Adyen/Card'
  end

  # Payment Methods
  s.subspec 'WeChatPay' do |plugin|
    plugin.source_files = 'AdyenWeChatPay/**/*.swift', 'AdyenWeChatPay/WeChatSDK/*.h'
    plugin.private_header_files = 'AdyenWeChatPay/WeChatSDK/*.h'
    plugin.vendored_libraries = 'AdyenWeChatPay/WeChatSDK/libWeChatSDK.a'
    plugin.xcconfig = { 'SWIFT_INCLUDE_PATHS' => '${PODS_TARGET_SRCROOT}/AdyenWeChatPay/WeChatSDK', 'OTHER_LDFLAGS' => '-ObjC -all_load' }
    plugin.preserve_paths = 'AdyenWeChatPay/WeChatSDK/module.modulemap'
    plugin.dependency 'Adyen/Core'
    plugin.libraries = 'z', 'stdc++', 'sqlite3.0'
    plugin.frameworks = 'SystemConfiguration', 'CoreTelephony', 'CFNetwork', 'CoreGraphics', 'Security'
  end

  s.subspec 'Card' do |plugin|
    plugin.dependency 'Adyen/Core'
    plugin.dependency 'Adyen3DS2', '>= 2.1.0-rc.5'
    plugin.source_files = 'AdyenCard/**/*.swift', 'AdyenCard/Utilities/AdyenCSE/*.{h,m}', 'AdyenCard/Utilities/*.{h,m}'
    plugin.private_header_files = 'AdyenCard/Utilities/AdyenCSE/*.h'
  end

end
