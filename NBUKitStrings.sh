#!/bin/sh

#  NBUKitStrings.sh
#  
#
#  Created by Ernesto Rivera on 2013/08/14.
#

cd Source
find . -name "*.m" -print0 | xargs -0 genstrings -u -o ../NBUResources.bundle/en.lproj *.m
mv ../NBUResources.bundle/en.lproj/Localizable.strings ../NBUResources.bundle/en.lproj/NBUKit.strings
