# ``AdyenTwint``

This module is used for supporting the Twint payment method through the native Twint SDK via the `TwintComponent`. In order to support Twint payments via the native flow, make sure to include this module in your application.

## Overview

The flow for Twint via the native SDK starts with the `TwintComponent`. After pressing the button on the component, `TwintComponent` makes a `/payments` call with `subtype: sdk` and trigger the flow with retrieving the code through `ActionComponent`.

Your app will show the app chooser if you have installed more than one Twint app on your device, otherwise it will redirect to the single Twint app which is installed on your device or show error in case no apps installed.

After the payment is processed in the Twint app, Twint app will return back to your app via the `redirectURL` you need to provide to the component with payment result. If the payment is successful then `/paymentDetails` is made with `paymentData` otherwise error is shown.

### Drop-in
For Twint app flow configure the `actionComponent` with a returnUrl scheme
```
dropInConfig.actionComponent.twint = .init(callbackAppScheme: yourReturnURLScheme)
```

Set your `AdyenSession` instance as Drop-in's delegate to let it handle the flow.
```
dropIn.delegate = self.session
```

### Components
Create a `TwintPaymentMethod` instance from your payment methods list.
```
let paymentMethod = paymentMethods.paymentMethod(ofType: TwintPaymentMethod.self)
```

Create the the `TwintComponent` with the `paymentMethod` and the `configuration`.
```
let component = TwintComponent(paymentMethod: paymentMethod, context: adyenContext, configuration: configuration)
```

Set your `AdyenSession` instance as the delegate to let it handle the flow.
```
component.delegate = self.adyenSession
```

Your app must configure a `callbackAppScheme` so that it is reopened once the payment is done.

```
componentConfig.actionComponent.twint = .init(callbackAppScheme: yourReturnURLScheme)
```

### Note:

1. Your app should call the `RedirectComponent` in the `AppDelegate` by adding below method.

```
func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
    RedirectComponent.applicationDidOpen(from: url)
    return true
}
```

2. Your app needs to register all apps that will be opened by your app.To do
this, the following entries need to be added to the your App’s Info.plist file. If this is not done, then TWINT SDK does not find any installed TWINT app.

```
<key>LSApplicationQueriesSchemes</key>
<array>
<string>twint-issuer1</string>
<string>twint-issuer2</string>
<string>twint-issuer3</string>
<string>twint-issuer4</string>
<string>twint-issuer5</string>
<string>twint-issuer6</string>
<string>twint-issuer7</string>
<string>twint-issuer8</string>
<string>twint-issuer9</string>
<string>twint-issuer10</string>
<string>twint-issuer11</string>
<string>twint-issuer12</string>
<string>twint-issuer13</string>
<string>twint-issuer14</string>
<string>twint-issuer15</string>
<string>twint-issuer16</string>
<string>twint-issuer17</string>
<string>twint-issuer18</string>
<string>twint-issuer19</string>
<string>twint-issuer20</string>
<string>twint-issuer21</string>
<string>twint-issuer22</string>
<string>twint-issuer23</string>
<string>twint-issuer24</string>
<string>twint-issuer25</string>
<string>twint-issuer26</string>
<string>twint-issuer27</string>
<string>twint-issuer28</string>
<string>twint-issuer29</string>
<string>twint-issuer30</string>
<string>twint-issuer31</string>
<string>twint-issuer32</string>
<string>twint-issuer33</string>
<string>twint-issuer34</string>
<string>twint-issuer35</string>
<string>twint-issuer36</string>
<string>twint-issuer37</string>
<string>twint-issuer38</string>
<string>twint-issuer39</string>
<string>twint-issuer40</string>
<string>twint-issuer41</string>
<string>twint-issuer42</string>
<string>twint-issuer43</string>
<string>twint-issuer44</string>
<string>twint-issuer45</string>
<string>twint-issuer46</string>
<string>twint-issuer47</string>
<string>twint-issuer48</string>
<string>twint-issuer49</string>
<string>twint-issuer50</string>
</array>
```
