//
//  FeatureListTableViewController.m
//  W2STSDKSampleApp
//
//  Created by Giovanni Visentini on 03/08/15.
//  Copyright (c) 2015 STCentralLab. All rights reserved.
//

#import "FeatureListTableViewController.h"

#import "ConsoleViewController.h"
#import "SettingsTableViewController.h"

#import <W2STSDK/W2STSDKFeature.h>
#import <W2STSDK/W2STSDKFeatureAutoConfigurable.h>
#import <W2STSDK/W2STSDKFeatureField.h>

#define DEFAULT_MESSAGE @"Click for enable the notification"

#define SHOW_DEBUG_NAME @"Show console"
#define SHOW_SETTINGS_NAME @"Show settings"
#define OPEN_DEBUG_VIEW_SEGUE_NAME @"showConsoleViewSegue"
#define SHOW_SETTINGS_VIEW_SEGUE_NAME @"showSettingsViewSegue"

@interface FeatureListTableViewController() <W2STSDKFeatureDelegate,
W2STSDKFeatureAutoConfigurableDelegate,W2STSDKNodeStateDelegate>
@end

@implementation FeatureListTableViewController{
    /**
     *  action used for show the console view
     */
    UIAlertAction *mActionConsole;
    
    /**
     *  action used for show the settings view
     */
    UIAlertAction *mActionSettings;
    
    /**
     *  alert show as a menu when the user click on the bar button item
     */
    UIAlertController *mAlertController;
    
    /**
     *  array of W2STSDKFeature exported by the node
     */
    NSArray *mAvailableFeatures;
}


-(void)viewDidLoad{
    [super viewDidLoad];
    mAlertController = [UIAlertController
                        alertControllerWithTitle:nil message:nil
                        preferredStyle:UIAlertControllerStyleActionSheet];


    //when trigger start a segue that open the console view
    mActionConsole = [UIAlertAction actionWithTitle:SHOW_DEBUG_NAME
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *action) {
                                                [self performSegueWithIdentifier:OPEN_DEBUG_VIEW_SEGUE_NAME
                                                                          sender:mActionConsole];
                                            }];
    
    //when trigger start a segue that open the settings view
    mActionSettings = [UIAlertAction actionWithTitle:SHOW_SETTINGS_NAME
                                               style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction *action) {
                                                 [self performSegueWithIdentifier:SHOW_SETTINGS_VIEW_SEGUE_NAME
                                                                           sender:mActionSettings];
                                             }];
    
    
    [mAlertController addAction:mActionConsole];
    [mAlertController addAction:mActionSettings];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    mAvailableFeatures = [self.node getFeatures];
    
    //enable the action only if the service is available
    mActionConsole.enabled = (self.node.debugConsole!=nil);
    mActionSettings.enabled = (self.node.configControl!=nil);
    
    //notify change in the node status for move to the previous view if there is
    //some error during the transmission
    [self.node addNodeStatusDelegate:self];
    
    //fill the table
    [self.tableView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //remove the listener
    [self.node removeNodeStatusDelegate:self];
    
    //stop the notification and remove the listener
    for (W2STSDKFeature *f in mAvailableFeatures){
        if([self.node isEnableNotification:f]){
            [self.node disableNotification:f];
            [f removeFeatureDelegate:self];
        }//if
    }//for
}

/**
 *  show the menu for go to the console or settings view
 *
 *  @param sender bar button clicked
 */
-(IBAction)showPopupMenu:(UIBarButtonItem *)sender {
    
    UIPopoverPresentationController *popPresenter = [mAlertController
                                                     popoverPresentationController];
    popPresenter.barButtonItem=sender;
    popPresenter.sourceView=self.view;
    [self presentViewController:mAlertController animated:YES completion:nil];
    
}

#pragma mark - Navigation

/**
 *  pass the correct service to the debug/settings view
 *
 *  @param segue  current segue
 *  @param sender not used
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:OPEN_DEBUG_VIEW_SEGUE_NAME]){
        ConsoleViewController *dest = (ConsoleViewController*) [segue destinationViewController];
        dest.debugInterface = self.node.debugConsole;
    }else if([segue.identifier isEqualToString:SHOW_SETTINGS_VIEW_SEGUE_NAME]){
        SettingsTableViewController *dest = (SettingsTableViewController*)[segue destinationViewController];
        dest.configControl = self.node.configControl;
    }//if-else
}

#pragma mark - W2STSDKFeatureDelegate
/**
 *  callback done when we receive an update from the node
 *
 *  @param feature feature that has new data
 */
- (void)didUpdateFeature:(W2STSDKFeature *)feature{
    //find the cell to update
    NSUInteger index = [mAvailableFeatures indexOfObject:feature];
    NSIndexPath *cellIndex =[NSIndexPath indexPathForRow:index inSection: 0];
    //generate the object description
    NSString *desc = [feature description];
    //update the table with the new description, we have to do a dispathc
    //since the notifications are submited in a cuncurrent queue
    dispatch_sync(dispatch_get_main_queue(),^{
        [self.tableView beginUpdates];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath: cellIndex];
        cell.detailTextLabel.text = desc;
        [self.tableView endUpdates];
    });
}

#pragma mark - Table view data source
//one colum
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

// one row for each feature
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return mAvailableFeatures.count;
}


/**
 *  build a  table cell for each feature. It is a simple cell where the title is
 * the feature name and the details are the feature data
 *
 *  @param tableView selected table
 *  @param indexPath selected colum/row
 *
 *  @return cell that will be show in that table at that position
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NodeFeature" forIndexPath:indexPath];
    
    W2STSDKFeature *f = [mAvailableFeatures objectAtIndex:indexPath.row];
    
    cell.textLabel.text =f.name;
    cell.detailTextLabel.text= DEFAULT_MESSAGE;
    
    return cell;
}

/**
 *  enable/disable the notificaiton when the user select a table row
 *
 *  @param tableView selected table
 *  @param indexPath selected colum/row
 */
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    W2STSDKFeature *f =(W2STSDKFeature*) mAvailableFeatures[indexPath.row];
    
    
    if([self.node isEnableNotification:f]){
        //disable the notification and remove the delegate
        [self.node disableNotification:f];
        if([f isKindOfClass:[W2STSDKFeatureAutoConfigurable class]]){
            [((W2STSDKFeatureAutoConfigurable*)f) removeFeatureConfigurationDelegate:self];
        }//if
        [f removeFeatureDelegate:self];
        
        [tableView cellForRowAtIndexPath:indexPath].detailTextLabel.text= DEFAULT_MESSAGE;
    }else{
        //register the delegate and start the notificaiton
        if([f isKindOfClass:[W2STSDKFeatureAutoConfigurable class]]){
            [((W2STSDKFeatureAutoConfigurable*)f) addFeatureConfigurationDelegate:self];
            [((W2STSDKFeatureAutoConfigurable*)f) startAutoConfiguration];
        }
        [f addFeatureDelegate:self];
        [self.node enableNotification:f];
    }//if-else
    
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}//didSelectRowAtIndexPath

/**
 *  if the user click on the mark we restart the auto configuration process
 *
 *  @param tableView selected table
 *  @param indexPath selected cell
 */
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    W2STSDKFeature *f =(W2STSDKFeature*) mAvailableFeatures[indexPath.row];
    if([f isKindOfClass:[W2STSDKFeatureAutoConfigurable class]]){
        [((W2STSDKFeatureAutoConfigurable*)f) startAutoConfiguration];
    }//if
}//accessoryButtonTappedForRowWithIndexPath

#pragma mark - W2STSDKFeatureAutoConfigurableDelegate

/**
 *  log that the configuration start
 *
 *  @param feature feature that start the configuration
 */
- (void)didAutoConfigurationStart:(W2STSDKFeatureAutoConfigurable *)feature{
    NSLog(@"%@: conf start",feature.name);
}

/**
 *  when feature is configurated we add a checkmark to its row
 *
 *  @param feature feature that send the update
 *  @param status  new feature status
 */
- (void)didAutoConfigurationChange:(W2STSDKFeatureAutoConfigurable *)feature status:(int32_t)status{
    NSLog(@"%@: conf change :%d",feature.name,status);
    NSUInteger index = [mAvailableFeatures indexOfObject:feature];
    NSIndexPath *cellIndex =[NSIndexPath indexPathForRow:index inSection: 0];
    dispatch_async(dispatch_get_main_queue(),^{
        [self.tableView beginUpdates];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath: cellIndex];
        if(feature.isConfigurated)
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        else
            cell.accessoryType = UITableViewCellAccessoryNone;
        [self.tableView endUpdates];
    });
}

/**
 *  log that the configuration start
 *
 *  @param feature feature that start the configuration
 */
- (void)didConfigurationFinished:(W2STSDKFeatureAutoConfigurable *)feature status:(int32_t)status{
    NSLog(@"%@: conf stop :%d",feature.name,status);
}


/**
 *  if the node disconnect or we lost the connection go back in the previus view
 *
 *  @param node      node that change its state
 *  @param newState  new state
 *  @param prevState old state
 */
- (void) node:(W2STSDKNode *)node didChangeState:(W2STSDKNodeState)newState prevState:(W2STSDKNodeState)prevState{
    
    if(newState == W2STSDKNodeStateLost || newState == W2STSDKNodeStateUnreachable
       || newState == W2STSDKNodeStateDead){
        dispatch_sync(dispatch_get_main_queue(),^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    }//if
    
}

@end
