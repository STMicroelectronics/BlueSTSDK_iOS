/*******************************************************************************
 * COPYRIGHT(c) 2015 STMicroelectronics
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *   1. Redistributions of source code must retain the above copyright notice,
 *      this list of conditions and the following disclaimer.
 *   2. Redistributions in binary form must reproduce the above copyright notice,
 *      this list of conditions and the following disclaimer in the documentation
 *      and/or other materials provided with the distribution.
 *   3. Neither the name of STMicroelectronics nor the names of its contributors
 *      may be used to endorse or promote products derived from this software
 *      without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 ******************************************************************************/

#import "FeatureListTableViewController.h"

#import "ConsoleViewController.h"
#import "SettingsTableViewController.h"

#import <BlueSTSDK/BlueSTSDKFeature.h>
#import <BlueSTSDK/BlueSTSDKFeatureAutoConfigurable.h>
#import <BlueSTSDK/BlueSTSDKFeatureField.h>

#define DEFAULT_MESSAGE @"Click for enable the notification"

#define CANCEL_NAME @"Cancel"
#define SHOW_DEBUG_NAME @"Show console"
#define SHOW_SETTINGS_NAME @"Show settings"
#define OPEN_DEBUG_VIEW_SEGUE_NAME @"showConsoleViewSegue"
#define SHOW_SETTINGS_VIEW_SEGUE_NAME @"showSettingsViewSegue"

@interface FeatureListTableViewController() <BlueSTSDKFeatureDelegate,
BlueSTSDKFeatureAutoConfigurableDelegate,BlueSTSDKNodeStateDelegate>
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
     *  array of BlueSTSDKFeature exported by the node
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
    
    //on the iphone add the cancel button
    if ( UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad ){
        [mAlertController addAction:
         [UIAlertAction actionWithTitle:CANCEL_NAME
                                  style:UIAlertActionStyleCancel
                                handler:nil]];
    }
    
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
    for (BlueSTSDKFeature *f in mAvailableFeatures){
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

#pragma mark - BlueSTSDKFeatureDelegate
/**
 *  callback done when we receive an update from the node
 *
 *  @param feature feature that has new data
 */
- (void)didUpdateFeature:(BlueSTSDKFeature *)feature sample:(BlueSTSDKFeatureSample *)sample{
    //find the cell to update
    NSUInteger index = [mAvailableFeatures indexOfObject:feature];
    NSIndexPath *cellIndex =[NSIndexPath indexPathForRow:index inSection: 0];
    //generate the object description
    NSString *desc = [feature description];
    //update the table with the new description, we have to do a dispathc
    //since the notifications are submited in a cuncurrent queue
    dispatch_async(dispatch_get_main_queue(),^{
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
    
    BlueSTSDKFeature *f = [mAvailableFeatures objectAtIndex:indexPath.row];
    
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
    
    BlueSTSDKFeature *f =(BlueSTSDKFeature*) mAvailableFeatures[indexPath.row];
    
    
    if([self.node isEnableNotification:f]){
        //disable the notification and remove the delegate
        [self.node disableNotification:f];
        if([f isKindOfClass:[BlueSTSDKFeatureAutoConfigurable class]]){
            [((BlueSTSDKFeatureAutoConfigurable*)f) removeFeatureConfigurationDelegate:self];
        }//if
        [f removeFeatureDelegate:self];
        
        [tableView cellForRowAtIndexPath:indexPath].detailTextLabel.text= DEFAULT_MESSAGE;
    }else{
        //register the delegate and start the notificaiton
        if([f isKindOfClass:[BlueSTSDKFeatureAutoConfigurable class]]){
            [((BlueSTSDKFeatureAutoConfigurable*)f) addFeatureConfigurationDelegate:self];
            [((BlueSTSDKFeatureAutoConfigurable*)f) startAutoConfiguration];
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
    BlueSTSDKFeature *f =(BlueSTSDKFeature*) mAvailableFeatures[indexPath.row];
    if([f isKindOfClass:[BlueSTSDKFeatureAutoConfigurable class]]){
        [((BlueSTSDKFeatureAutoConfigurable*)f) startAutoConfiguration];
    }//if
}//accessoryButtonTappedForRowWithIndexPath

#pragma mark - BlueSTSDKFeatureAutoConfigurableDelegate

/**
 *  log that the configuration start
 *
 *  @param feature feature that start the configuration
 */
- (void)didAutoConfigurationStart:(BlueSTSDKFeatureAutoConfigurable *)feature{
    NSLog(@"%@: conf start",feature.name);
}

/**
 *  when feature is configurated we add a checkmark to its row
 *
 *  @param feature feature that send the update
 *  @param status  new feature status
 */
- (void)didAutoConfigurationChange:(BlueSTSDKFeatureAutoConfigurable *)feature status:(int32_t)status{
    NSLog(@"%@: conf change :%d",feature.name,status);
    NSUInteger index = [mAvailableFeatures indexOfObject:feature];
    NSIndexPath *cellIndex =[NSIndexPath indexPathForRow:index inSection: 0];
    dispatch_async(dispatch_get_main_queue(),^{
        [self.tableView beginUpdates];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath: cellIndex];
        if(feature.isConfigured)
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
- (void)didConfigurationFinished:(BlueSTSDKFeatureAutoConfigurable *)feature status:(int32_t)status{
    NSLog(@"%@: conf stop :%d",feature.name,status);
}


/**
 *  if the node disconnect or we lost the connection go back in the previus view
 *
 *  @param node      node that change its state
 *  @param newState  new state
 *  @param prevState old state
 */
- (void) node:(BlueSTSDKNode *)node didChangeState:(BlueSTSDKNodeState)newState prevState:(BlueSTSDKNodeState)prevState{
    
    if(newState == BlueSTSDKNodeStateLost || newState == BlueSTSDKNodeStateUnreachable
       || newState == BlueSTSDKNodeStateDead){
        dispatch_sync(dispatch_get_main_queue(),^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    }//if
    
}

@end
