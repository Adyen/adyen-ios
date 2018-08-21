## WeChat Pay In-App

###  Register an App ID on WeChat Platform
For proccessing WeChat payments you first need to register an App ID on WeChat Platform. You can find a step by step guide [here](https://github.com/Adyen/adyen-ios/wiki/Register-WeChat-App-Id).

### App Integration
##### Add AdyenWeChatPay framework to your project:

**Option 1. Cocoapods**
1. Add `pod 'Adyen/WeChatPay'` on your `Podfile`.
2. Run `pod install`.

**Option 2. Carthage**
1. Run `carthage update`.
2. Link `AdyenWeChatPay.framework` to your target. 

##### Add your App ID to URL scheme:
1. Go to `Targets > Info > URL type > URL Scheme`.
2. Add a new `URL Scheme` :
- For identifier set `weixin`
- For URL Schemes set your App Id.

##### Register `weixin` in your  `URL types`:
1. Go to your `Info.plist`
2. Add `weixin` to `LSApplicationQueriesSchemes` 
