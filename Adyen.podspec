Pod::Spec.new do |s|
  s.name = 'Adyen'
  s.version = '4.12.0'
  s.summary = "Adyen Components for iOS"
  s.description = <<-DESC
    Adyen Components for iOS allows you to accept in-app payments by providing you with the building blocks you need to create a checkout experience.
  DESC

  s.homepage = 'https://adyen.com'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.author = { 'Adyen' => 'support@adyen.com' }
  s.source = { :git => 'https://github.com/Adyen/adyen-ios.git', :tag => "#{s.version}" }
  s.platform = :ios
  s.ios.deployment_target = '12.0'
  s.swift_version = '5.7'
  s.frameworks = 'Foundation'
  s.default_subspecs = 'Core', 'Components', 'Actions', 'Card', 'Encryption', 'DropIn'
  s.pod_target_xcconfig = {'SWIFT_SUPPRESS_WARNINGS' => 'YES' }

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
    plugin.source_files = 'AdyenWeChatPay/**/*.swift'
    plugin.dependency 'Adyen/Core'
    plugin.dependency 'Adyen/Actions'
    plugin.dependency 'AdyenWeChatPayInternal', '2.1.0'
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
    plugin.dependency 'Adyen/Encryption'
    plugin.source_files = 'AdyenComponents/**/*.swift'
  end


  s.subspec 'Actions' do |plugin|
    plugin.dependency 'Adyen/Core'
    plugin.dependency 'Adyen3DS2', '2.4.1'
    plugin.source_files = 'AdyenActions/**/*.swift'
    plugin.exclude_files = 'AdyenActions/**/BundleSPMExtension.swift'
    plugin.resource_bundles = {
        'AdyenActions' => [
            'AdyenActions/Assets/**/*.xcassets'
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
    plugin.dependency 'AdyenNetworking', '1.0.0'
    plugin.resource_bundles = {
        'Adyen' => [
            'Adyen/Assets/**/*.strings',
            'Adyen/Assets/**/*.xcassets',
            'PrivacyInfo.xcprivacy'
        ]
    }
  end

end
