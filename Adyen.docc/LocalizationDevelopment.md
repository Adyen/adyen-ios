# Localization guide for internal development

This document contains information for Adyen developers working on the SDK localization system.

## Translation Update Process

The SDK includes scripts to update translations and regenerate localization keys from our internal translation repository:

1. Run the translation update script:
   ```bash
   ./Scripts/update_translations.sh
   ```
   
   This script:
   - Fetches the latest translations from the internal translations repository
   - Processes them with `StringsGenerator` script
   - Generates typed Swift constants for localization keys

More information can be found in the [transaltions repository](https://gitlab.is.adyen.com/adyen/streams/checkout/translations/-/tree/master/iOS) itself.
