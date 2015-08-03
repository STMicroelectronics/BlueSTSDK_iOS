//
//  SettingsTableViewController.h
//  W2STSDKSampleApp
//
//  Created by Giovanni Visentini on 03/08/15.
//  Copyright (c) 2015 STCentralLab. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <W2STSDK/W2STSDKConfigControl.h>


@interface SettingsTableViewController : UITableViewController
    @property (retain) W2STSDKConfigControl *configControl;
@end
