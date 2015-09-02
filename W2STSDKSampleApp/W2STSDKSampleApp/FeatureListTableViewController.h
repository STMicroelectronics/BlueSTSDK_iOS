//
//  FeatureListTableViewController.h
//  W2STSDKSampleApp
//
//  Created by Giovanni Visentini on 03/08/15.
//  Copyright (c) 2015 STCentralLab. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <W2STSDK/W2STSDKNode.h>

/**
 *  This view will show a list of available feature and will enable the 
 * notification when a user click on it.
 * <p>
 * for the feature of type AutoConfigurable it will also trigger the configuration
 * process and show a mark when the process is complete
 * </p>
 */
@interface FeatureListTableViewController : UITableViewController

/**
 *  node that will send the information
 */
@property (retain) W2STSDKNode *node;

/**
 *  callback call when the user click the bar button item
 *
 *  @param sender buttun that generate the event
 */
- (IBAction)showPopupMenu:(UIBarButtonItem *)sender;

@end
