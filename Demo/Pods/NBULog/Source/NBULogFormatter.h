//
//  NBULogFormatter.h
//  NBULog
//
//  Created by Ernesto Rivera on 2013/11/12.
//  Copyright (c) 2012-2013 CyberAgent Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <CocoaLumberjack/DispatchQueueLogFormatter.h>

/**
 Default NBULog formatter.
 
 Sample output:
 
        2013-11-12 15:18:38:473 NBULogDemo[09384] I AppDelegate:50 Message from another thread
        2013-11-12 15:18:38:498 NBULogDemo[main] V LogTestsViewController:26 testCLogs
        2013-11-12 15:18:38:498 NBULogDemo[main] I LogTestsViewController:28 Info message from a C function
        2013-11-12 15:18:38:498 NBULogDemo[main] W LogTestsViewController:29 Warning message from a C function
        2013-11-12 15:18:38:498 NBULogDemo[main] E LogTestsViewController:30 Error message from a C function
 */
@interface NBULogFormatter : DispatchQueueLogFormatter

@end

