# AdyenCardScanner.podspec
Pod::Spec.new do |s|
  s.name = 'AdyenCardScanner'
  s.version = '1.0.2'  
  s.summary = "Adyen Card Scanner Module for iOS"

  s.homepage = 'https://adyen.com'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.author = { 'Adyen' => 'support@adyen.com' }

  s.source = { :git => 'https://github.com/Adyen/adyen-ios.git', :tag => '5.20.0' }
  s.source_files = 'AdyenCardScanner/**/*.swift'
  s.framework = 'Foundation'
  s.ios.deployment_target = '16.0'
  s.swift_version = '5.9'

  s.pod_target_xcconfig = { 
    'DEFINES_MODULE' => 'YES',
    'PRODUCT_MODULE_NAME' => 'AdyenCardScanner',
    'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES'
  }
end
