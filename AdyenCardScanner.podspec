# AdyenCardScanner.podspec
Pod::Spec.new do |s|
  s.name = 'AdyenCardScanner'
  s.version = '5.17.0'  
  s.summary = "Adyen Card Scanner Module for iOS"

  s.source = { :git => 'https://github.com/Adyen/adyen-ios.git', :tag => "#{s.version}" }
  s.source_files = 'AdyenCardScanner/**/*.swift'
  s.framework = 'Foundation'
  s.ios.deployment_target = '13.0'
  s.swift_version = '5.7'
end