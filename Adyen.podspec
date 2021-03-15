Pod::Spec.new do |s|
  s.name = 'Adyen'
  s.version = '4.0.0-beta.1'
  s.summary = "Adyen Components for iOS"
  s.description = <<-DESC
    Adyen Components for iOS allows you to accept in-app payments by providing you with the building blocks you need to create a checkout experience.
  DESC

  s.homepage = 'https://adyen.com'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.author = { 'Adyen' => 'support@adyen.com' }
  s.source = { :git => 'https://github.com/Adyen/adyen-ios.git', :tag => "#{s.version}" }
  s.platform = :ios
  s.ios.deployment_target = '11.0'
  s.swift_version = '5.1'
  s.frameworks = 'Foundation'
  s.default_subspecs = 'Core', 'Components', 'Actions', 'Card', 'Encryption', 'DropIn'
  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64', 'SWIFT_SUPPRESS_WARNINGS' => 'YES' }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }

  s.subspec 'DropIn' do |plugin|
    plugin.source_files = 'AdyenDropIn/**/*.swift'
    plugin.dependency 'Adyen/Core'
    plugin.dependency 'Adyen/Actions'
    plugin.dependency 'Adyen/Card'
    plugin.dependency 'Adyen/Encryption'
    plugin.dependency 'Adyen/Components'
  end

  # Payment Methods
  s.subspec 'WeChatPay' do |plugin|
    plugin.source_files = 'AdyenWeChatPay/**/*.swift', 'AdyenWeChatPay/WeChatSDK/*.h'
    plugin.private_header_files = 'AdyenWeChatPay/WeChatSDK/*.h'
    plugin.vendored_libraries = 'AdyenWeChatPay/WeChatSDK/libWeChatSDK.a'
    plugin.xcconfig = { 'SWIFT_INCLUDE_PATHS' => '${PODS_TARGET_SRCROOT}/AdyenWeChatPay/WeChatSDK', 'OTHER_LDFLAGS' => '-ObjC -all_load' }
    plugin.preserve_paths = 'AdyenWeChatPay/WeChatSDK/module.modulemap'
    plugin.dependency 'Adyen/Core'
    plugin.dependency 'Adyen/Actions'
    plugin.libraries = 'z', 'stdc++', 'sqlite3.0'
    plugin.frameworks = 'SystemConfiguration', 'CoreTelephony', 'CFNetwork', 'CoreGraphics', 'Security'
  end

  s.subspec 'Card' do |plugin|
    plugin.dependency 'Adyen/Core'
    plugin.dependency 'Adyen/Encryption'
    plugin.source_files = 'AdyenCard/**/*.swift'
    plugin.exclude_files = 'AdyenCard/**/BundleSPMExtension.swift'
    plugin.resource_bundles = {
        'AdyenCard' => [
            'AdyenCard/Assets/**/*.strings',
            'AdyenCard/Assets/**/*.xcassets'
        ]
    }
  end

  s.subspec 'Components' do |plugin|
    plugin.dependency 'Adyen/Core'
    plugin.source_files = 'AdyenComponents/**/*.swift'
  end


  s.subspec 'Actions' do |plugin|
    plugin.dependency 'Adyen/Core'
    plugin.dependency 'Adyen3DS2', '2.2.1'
    plugin.source_files = 'AdyenActions/**/*.swift'
    plugin.exclude_files = 'AdyenActions/**/BundleSPMExtension.swift'
    plugin.resource_bundles = {
        'Adyen' => [
            'Adyen/Assets/**/*.xcassets'
        ]
    }
  end

  s.subspec 'Encryption' do |plugin|
    plugin.source_files = 'AdyenEncryption/**/*.swift'
  end

  s.subspec 'SwiftUI' do |plugin|
    plugin.source_files = 'AdyenSwiftUI/**/*.swift'
  end

  s.subspec 'Core' do |plugin|
    plugin.source_files = 'Adyen/**/*.swift'
    plugin.exclude_files = 'Adyen/**/BundleSPMExtension.swift'
    plugin.resource_bundles = {
        'Adyen' => [
            'Adyen/Assets/**/*.strings',
            'Adyen/Assets/**/*.xcassets'
        ]
    }
  end

end
