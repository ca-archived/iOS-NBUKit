#!/bin/sh

#  CopyNBUKitResources.sh
#  NBUKit
#
#  Created by Ernesto Rivera on 2013/01/17.
#  Copyright (c) 2013 CyberAgent Inc. All rights reserved.

# Copy NBUKit.framework resources to NBUKitResources.bundle
echo "Copy NBUKit.framework resources..."
SOURCE_PATH="${DEPENDENCIES_BUILD_DIR}/NBUKit.framework/Resources/"
if [ ! -d "$SOURCE_PATH" ]; then
    SOURCE_PATH="${TARGET_BUILD_DIR}/NBUKit.framework/Resources/"
fi
echo "From: $SOURCE_PATH"
TARGET_PATH="${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/NBUKitResources.bundle"
echo "To: $TARGET_PATH"
mkdir -p "$TARGET_PATH"
cp -R "$SOURCE_PATH" "$TARGET_PATH"

