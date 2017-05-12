Pod::Spec.new do |s|
  s.name = "Adyen"
  s.version = "1.1.1"
  s.summary = "Adyen SDK for iOS"
  s.description = <<-DESC
    With Adyen SDK you can dynamically list all relevant payment methods for a specific transaction, so your shoppers can always pay with the method of their choice. The methods are listed based on the shopper's country, the transaction currency and amount.
  DESC
  s.license = "LICENSE"
  s.authors = { "Adyen" => "support@adyen.com" }
  s.homepage = "https://adyen.com"
  s.requires_arc = true
  s.source = { :git => 'https://github.com/Adyen/adyen-ios.git', :tag => "#{s.version}" }
  s.platform = :ios

  s.dependency 'AdyenCSE', '~> 1.0.4'

  s.ios.deployment_target = '9.0'
  s.ios.vendored_framework = [ 'Adyen/Adyen.framework' ]
  s.ios.frameworks = [ 'Foundation' ]
end
