#!/bin/sh

#  NBUKitStrings.sh
#  
#
#  Created by Ernesto Rivera on 2013/08/14.
#

cd Source
find . -name "*.m" -print0 | xargs -0 genstrings -u -o ../NBUKitResources.bundle/en.lproj *.m
mv ../NBUKitResources.bundle/en.lproj/Localizable.strings ../NBUKitResources.bundle/en.lproj/NBUKit.strings
