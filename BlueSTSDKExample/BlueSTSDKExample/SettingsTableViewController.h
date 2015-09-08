//
//  SettingsTableViewController.h
//  BlueSTSDKExample
//
//  Created by Giovanni Visentini on 03/08/15.
//  Copyright (c) 2015 STCentralLab. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <BlueSTSDK/BlueSTSDKConfigControl.h>


@interface SettingsTableViewController : UITableViewController
    @property (retain) BlueSTSDKConfigControl *configControl;
@end
