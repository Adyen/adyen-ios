# Localization

1. In Xcode create a new "Strings File" with the name `Localizable`.
    - If you are supporting multiple languages, make sure you check them all in for the `Localizable.string` under "Localization" in the "File Inspector".
    - For each locale, your iOS project will have a corresponding file. For example: `it-IT.lproj/Localizable.string`.
2. Override all necessary strings with desired values for all your localizations. The list of available strings can be found [here](https://github.com/Adyen/adyen-ios/blob/develop/Adyen/Assets/Generated/LocalizationKey.swift).

## Custom localization

In case your want to use a different localization file name, different key format or a different bundle - use `LocalizationParameters` to specify these values.
In example below, the SDK will look for key `adyen_submitButton_formatted` in `Translation.string` file in a bundle `customBundle`. 

```swift
let parameters = LocalizationParameters(bundle: customBundle,
                                        tableName: "Translation",
                                        keySeparator: "_")
configuration.localizationParameters = parameters // Any component
```
