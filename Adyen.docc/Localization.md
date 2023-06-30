# Localization

1. In Xcode create new "Strings File" with the name `Localizable`.
    - If you are using multiple localizations, make sure you check them all in for the `Localizations.string` in "File Inspector".
    - For each localization, your iOS project will have a corresponding file. For example: `it-IT.lproj/Localizable.string`.
3. Override all necessary strings with desired values for all your localizations. The list of available strings can be found [here](https://github.com/Adyen/adyen-ios/blob/develop/Adyen/Assets/Generated/LocalizationKey.swift).

## Custom localization

In case your want to use different localization file name, different key format or different bundle - use `LocalizationParameters`.
In example below, the SDK will look for key `adyen_submitButton_formatted` in `Translation.string` file in a bundle `customBundle`. 

```swift
let parameters = LocalizationParameters(bundle: customBundle,
                                        tableName: "Translation",
                                        keySeparator: "_")
configuration.localizationParameters = parameters // Any component
```
