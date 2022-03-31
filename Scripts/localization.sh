#!/bin/sh

echo "##################################################"
echo "################ LOCALIZATION JOB ##################"
echo "##################################################\n\n"

echo "---------------- CLONING TRANSLATIONS REPO ----------------\n"

git clone --progress --verbose git@gitlab.is.adyen.com:adyen/streams/checkout/translations.git $SRCROOT/translations

echo "\n\n---------------- GENERATING LOCALIZATION KEYS ----------------\n"

cd translations/iOS
swift StringsGenerator.swift $PROJECT_DIR

echo "\n\n---------------- REMOVING TRANSLATIONS REPO ----------------\n"

rm -r $SRCROOT/translations
