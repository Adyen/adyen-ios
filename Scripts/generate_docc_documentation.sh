#!/bin/bash

set -e

# Since Jazzy doesn't support generating a single set of documentation
# for multiple modules, we use a temporary Xcode project with CocoaPods.
# CocoaPods turns the different modules into a single module, which
# can then be processed by Jazzy.

PROJECT_NAME=TempProject
FRAMEWORK_NAME=Adyen
FINAL_DOC_PATH=Docc_archive

rm -rf $PROJECT_NAME

mkdir -p $PROJECT_NAME $FINAL_DOC_PATH && cd $PROJECT_NAME

# Create a new Xcode project.
swift package init
swift package generate-xcodeproj

# Create a Podfile with our pod as dependency.
echo "
platform :ios, '11.0'# Move Documentation to build folder

target '$PROJECT_NAME' do
  use_frameworks!

  pod 'Adyen', :path => '../'
  pod 'Adyen/SwiftUI', :path => '../'
  pod 'Adyen/Session', :path => '../'
end

# post_install do |installer|
#     installer.pods_project.targets.each do |target|
#       if target.name == \"Adyen\"
#         source_files = target.resources_build_phase.files
#         source_files.each do |fileref|
#           puts(fileref.file_ref.path)
#           if fileref.file_ref.path.include? \"Adyen.docc\"
#             puts(\"Adyen.docc Found\")
#             # build_phase = target.frameworks_build_phase
#             # build_phase.add_file_reference(fileref)
#           end
#         end
#         # folderReference = installer.pods_project.add_file_reference(\"$(pwd)/../Adyen.docc)\", installer.pods_project.pod_group(\"Actions\"), true)
#         # target.source_build_phase.add_file_reference(btsdata, true)
#       end
#     end
# end
" >> Podfile

# Install the pods.
pod install

# Run Jazzy from the Pods folder.
cd Pods
xcodebuild docbuild -project Pods.xcodeproj \
 -scheme Adyen DEVELOPMENT_TEAM=B2NYSS5932 \
 -destination="generic/platform=iOS" \
 -configuration Release

cd ../../

rm -rf $FINAL_DOC_PATH/$FRAMEWORK_NAME.doccarchive

mv $PROJECT_NAME/build/Release-maccatalyst/Adyen/$FRAMEWORK_NAME.doccarchive $FINAL_DOC_PATH/$FRAMEWORK_NAME.doccarchive

$(xcrun --find docc) process-archive \
transform-for-static-hosting $FINAL_DOC_PATH/$FRAMEWORK_NAME.doccarchive \
--output-path docs \
--hosting-base-path adyen.github.io/adyen-ios/

# Clean up.
rm -rf $PROJECT_NAME
