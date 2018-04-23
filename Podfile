platform :ios, '9.0'

use_frameworks!

def shared_pods
  pod 'AdyenCSE', '~> 1.1'
end

target 'Adyen' do

  shared_pods

  pod 'SwiftLint', '~> 0.25.0'
  pod 'SwiftFormat/CLI', '~> 0.28.6'

  target 'AdyenTests' do
    inherit! :search_paths
  end

end

target 'AdyenUIHost' do

  shared_pods

end
