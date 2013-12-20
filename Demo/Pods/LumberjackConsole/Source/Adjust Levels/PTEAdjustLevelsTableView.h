//
//  PTEAdjustLevelsTableView.h
//  LumberjackConsole
//
//  Created by Ernesto Rivera on 2013/10/09.
//  Copyright (c) 2013.
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

/**
 A table view used to dynamically adjust log levels.
 
 @note Enabled only when NBULog is present.
 */
@interface PTEAdjustLevelsTableView : UITableView

@end


/**
 An adjust levels' cell.
 */
@interface PTEAdjustLevelsCell : UITableViewCell

/// The name of the log module.
@property (weak, nonatomic) IBOutlet UILabel * nameLabel;

/// The current log level.
@property (weak, nonatomic) IBOutlet UILabel * levelLabel;

/// A stepper to increase/decrease the log level.
@property (weak, nonatomic) IBOutlet UIStepper * levelStepper;

@end

