Pod::Spec.new do |s|
  s.name = 'Adyen'
  s.version = '3.1.1'
  s.summary = "Adyen Components for iOS"
  s.description = <<-DESC
    Adyen Components for iOS allows you to accept in-app payments by providing you with the building blocks you need to create a checkout experience.
  DESC

  s.homepage = 'https://adyen.com'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.author = { 'Adyen' => 'support@adyen.com' }
  s.source = { :git => 'https://github.com/Adyen/adyen-ios.git', :tag => "#{s.version}" }
  s.platform = :ios
  s.ios.deployment_target = '10.3'
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
  s.subspec 'Card' do |plugin|
    plugin.dependency 'Adyen/Core'
    plugin.dependency 'Adyen3DS2'
    plugin.source_files = 'AdyenCard/**/*.swift', 'AdyenCard/Utilities/AdyenCSE/*.{h,m}', 'AdyenCard/Utilities/*.{h,m}'
    plugin.private_header_files = 'AdyenCard/Utilities/AdyenCSE/*.h'
  end

end
