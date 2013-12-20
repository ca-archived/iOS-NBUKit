#!/bin/sh

#  Strings.sh
#  Generate localizable.strings from source files.
#
#  Created by Ernesto Rivera on 2013/08/14.
#  Copyright (c) 2012-2013 CyberAgent Inc.
#

find ../Source -name "*.m" -print0 | xargs -0 -I file sed 's/NBULocalizedString(@"\(.*\)",\(.*\)@"\(.*\)")/NSLocalizedStringWithDefaultValue(@"\1", nil, nil, @"\3", @"\3")/' file > /tmp/genstrings_tmp
genstrings -u -o ../Resources/en.lproj /tmp/genstrings_tmp
