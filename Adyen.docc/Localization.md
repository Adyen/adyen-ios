# Localization

Both the Drop-in and the Components offer an option to customize the strings to match your app's use case or tone of voice.

By default, the SDK attempts to use a device's locale for translation of text and formatting of monetary values. If the preferred device locales are not supported, the SDK falls back to the **en-US** locale.

> Note: Localization only picks up locales that are listed in the `CFBundleLocalizations` property of your app's `Info.plist` file.

## Enforcing locale

To enforce a specific locale and formatting of monetary values, regardless of the shopper's device locale, use `LocalizationParameters(enforcedLocale: MY_LOCALE)`. (`MY_LOCALE` should be replaced with your desired locale identifier, e.g., "fr-FR").

## Overriding default formatting of monetary values

To enforce a custom locale for formatting a monetary values, use the `locale` property on `LocalizationParameters`. In case of `enforcedLocale` the value will be used for both localisation and monetary values formatting.

## Overriding strings

You can override strings for each key and locale.

> Important: If you are using multiple Adyen Components or the Drop-in, all usages of that localization key will be updated with the overridden value.

> Tip: If you want to override the value of a key for a specific component, you can use the `localizationParameters` property to specify a custom localization file to get the values from, as described below.

1.  [Add a string catalog to your project](https://developer.apple.com/documentation/xcode/localizing-and-varying-text-with-a-string-catalog#Add-a-string-catalog-to-your-project) or use your existing one.
2.  [Add a language to your project](https://developer.apple.com/documentation/xcode/localizing-and-varying-text-with-a-string-catalog#Add-a-language-to-your-project) if necessary.
3.  Find the key for the string you want to translate in the [list of available strings](https://github.com/Adyen/adyen-ios/blob/develop/Adyen/Assets/Generated/LocalizationKey.swift) and override it for each desired locale.

For example, if you want to override the payment button text to **Subscribe for [AMOUNT]**, add a key `adyen.submitButton.formatted` to your catalog. Then, provide new translation(s).

<details>
  <summary><h3> Using Legacy <code>.strings</code> files</h3></summary>

You can override strings for each key, and for each language and locale using legacy `.strings` files.

1.  In Xcode, [create a new](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/LoadingResources/Strings/Strings.html) or use your existing `Localizable.strings` file. (If you are using `.xcstrings` catalogs, refer to the section above).

    For example, if your app uses English and Spanish, your project folder should have a `Localizable.strings` file for each locale:

    - English: `en-US.lproj/Localizable.strings`
    - Spanish: `es-ES.lproj/Localizable.strings`

2.  Find the key for the string you want to translate in the [list of available strings](https://github.com/Adyen/adyen-ios/blob/develop/Adyen/Assets/Generated/LocalizationKey.swift) and override it for each desired locale.

For example, if you want to override the payment button text to **Subscribe for [AMOUNT]**:

- English, in the `en.lproj/Localizable.strings` file:

  ```strings
  "adyen.submitButton.formatted" = "Subscribe for %@";
  ```

- Spanish, in the `es.lproj/Localizable.strings` file:
  ```strings
  "adyen.submitButton.formatted" = "Suscríbete por %@";
  ```

</details>

### Adding a New Locale

In the same way, you can add new locales that are not supported by the SDK out-of-the-box. Add the necessary `.xcstrings` entries or `.strings` files for the new locale.

#### List of Currently Available Locales

| Language               | Locale code | Fallback |
| :--------------------- | :---------- | :------: |
| Arabic - International | ar          |          |
| Bulgarian              | bg-BG       |          |
| Catalan                | ca-ES       |          |
| Chinese - Simplified   | zh-CN       |          |
| Chinese - Traditional  | zh-TW       |          |
| Croatian               | hr-HR       |          |
| Czech                  | cs-CZ       |          |
| Danish                 | da-DK       |          |
| Dutch                  | nl-NL       |          |
| English - US           | en-US       |    ✱     |
| Estonian               | et-EE       |          |
| Finnish                | fi-FI       |          |
| French                 | fr-FR       |          |
| German                 | de-DE       |          |
| Greek                  | el-GR       |          |
| Hungarian              | hu-HU       |          |
| Icelandic              | is-IS       |          |
| Italian                | it-IT       |          |
| Japanese               | ja-JP       |          |
| Korean                 | ko-KR       |          |
| Latvian                | lv-LV       |          |
| Lithuanian             | lt-LT       |          |
| Norwegian              | no-NO       |          |
| Polish                 | pl-PL       |          |
| Portuguese - Brazil    | pt-BR       |          |
| Portuguese - Portugal  | pt-PT       |          |
| Romanian               | ro-RO       |          |
| Russian                | ru-RU       |          |
| Slovak                 | sk-SK       |          |
| Slovenian              | sl-SI       |          |
| Spanish                | es-ES       |          |
| Swedish                | sv-SE       |          |

### Custom Localization File Name

To use a custom localization file name, key format, or bundle, you can configure `LocalizationParameters`.

| Parameter      | Description                                      | Default value   |
| :------------- | :----------------------------------------------- | :-------------- |
| `bundle`       | Your bundle.                                     | `Bundle.main`   |
| `tableName`    | Your localization file name (without extension). | `"Localizable"` |
| `keySeparator` | The separator for the key for each string.       | `"."`           |

In the following example, the SDK looks for the key `adyen_submitButton_formatted` in the `YOUR_LOCALIZATION_FILE.strings` (or `YOUR_LOCALIZATION_FILE.xcstrings` catalog) file within the **CommonLibrary** bundle.

```swift
let parameters = LocalizationParameters(
    bundle: Bundle(for: MyLibraryClass.self), // Or your specific bundle instance
    tableName: "YOUR_LOCALIZATION_FILE",
    keySeparator: "_"
)
// Assuming 'configuration' is an instance of your Adyen component's configuration
configuration.localizationParameters = parameters // Apply to any Component configuration.
```
