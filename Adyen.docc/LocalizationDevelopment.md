# Localization guide for internal development

All translations are stored in the [internal translations repository](https://gitlab.is.adyen.com/adyen/streams/checkout/translations/-/tree/master/iOS), including keys management. Please refer to it for more information on how to add/update translations and add new keys.

## Translation update process

To update translations and regenerate localization keys from the internal translation repository, run the translation update script:

```bash
./Scripts/update_translations.sh
```

This script:
- Fetches the latest translations from the internal translations repository
- Processes them with `StringsGenerator.swift` script
- Generates typed Swift constants for localization keys and puts them into `LocalizationKey.swift`
