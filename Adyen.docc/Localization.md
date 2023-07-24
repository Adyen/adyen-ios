# Localization

By default, the SDK attempts to use a device's locale for translation of text and formatting of monetary values. If the preferred device's locales are not supported, the SDK falls back to the **en-US** locale.
Localization only picks up locales that are listed in the `CFBundleLocalizations` property of your app's `Info.plist` file.

## Overriding default formatting of monetary values 

To enforce your own formatting for monetary values, use the `locale` property on `LocalizationParameters`.

## Overriding a string 

You can override strings for each key, and for each language and locale. 

1. In Xcode, [create a new](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/LoadingResources/Strings/Strings.html) or use your existing `Localizable.strings` file.

For example, if your app uses English and Spanish, your project folder should have a `Localizable.strings` file for each locale:

- English: `en-US.lproj/Localizable.string`

- Spanish: `es-ES.lproj/Localizable.string`

2. Find the key for the string you want to translate in the [list of available strings](https://github.com/Adyen/adyen-ios/blob/develop/Adyen/Assets/Generated/LocalizationKey.swift) and override it for each desired locale:

For example, if you want to override the payment button text to **Subscribe for [AMOUNT]**.

- English, in the `en-US.lproj/Localizable.string` file:
~~~
"adyen.submitButton.formatted" = "Subscribe for %@";
~~~

- Spanish, in the `es-ES.lproj/Localizable.string` file:
~~~
"adyen.submitButton.formatted" = "Suscríbete por %@";
~~~

### Custom localization file name

To use a custom localization file name, key format, or bundle, you must configure `LocalizationParameters`.

|Parameter | Description | Default value |
| --- | --- | --- |
|`bundle`| Your bundle. | `Bundle.main` |
|`tableName` | Your localization file name. | `Localizable.strings` |
|`keySeparator` | The separator for the key for each string. | `"."` |

In the following example, the SDK looks for the key `adyen_submitButton_formatted` in the `YOUR_LOCALIZATION_FILE.strings` file in **CommonLibrary** bundle. 

~~~~swift
let parameters = LocalizationParameters(bundle: Bundle(for: MyCommonLibraryClass.type),
                                        tableName: "YOUR_LOCALIZATION_FILE",
                                        keySeparator: "_")
configuration.localizationParameters = parameters // Any Component.
~~~~

## Enforcing locale

To enforce a specific locale and formatting of monetary values no matter which locale the shopper's device uses, use `LocalizationParameters(enforcedLocale: MY_LOCALE)`.

List of currently avaialble locales:

| Language | Locale code | Fallback |
| --- | --- | :---: |
| Arabic - International | ar | |
| Chinese - Simplified | zh-CN | |
| Chinese - Traditional | zh-TW | |
| Croatian | hr-HR | |
| Czech | cs-CZ | |
| Danish | da-DK | |
| Dutch | nl-NL | |
| English - US | en-US | ✱ |
| Finnish | fi-FI | |
| French | fr-FR | |
| German | de-DE | |
| Greek | el-GR | |
| Hungarian | hu-HU | |
| Italian | it-IT | |
| Japanese | ja-JP | |
| Korean | ko-KR | |
| Norwegian | no-NO | |
| Polish | pl-PL | |
| Portuguese - Brazil | pt-BR | |
| Portuguese - Portugal | pt-PT | |
| Romanian | ro-RO | |
| Russian | ru-RU | |
| Slovak | sk-SK | |
| Slovenian | sl-SI | |
| Spanish | es-ES | |
| Swedish | sv-SE | |
