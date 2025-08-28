#!/bin/bash
set -e
echo "# Clone the translations repo"
git clone --progress --verbose https://gitlab.is.adyen.com/adyen/streams/checkout/translations.git ./translations

# Get into the iOS translation folder
cd translations/iOS

echo ""
echo "# Run the StringsGenerator on the project dir"
swift StringsGenerator.swift ../../

# Back to root
cd ../../

echo ""
echo "# Remove temporary files"
rm -rf ./translations

echo ""
echo "# Generating localization keys"
./Scripts/generate_localization_keys.swift ./Adyen/Assets/en-US.lproj/Localizable.strings ./Adyen/Assets/Generated/LocalizationKey.swift
