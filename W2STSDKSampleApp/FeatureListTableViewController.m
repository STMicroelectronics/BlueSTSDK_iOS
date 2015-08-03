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
    W2STSDKFeatureAutoConfigurableDelegate>
@end

@implementation FeatureListTableViewController{
    UIAlertAction *mActionDebug;
    UIAlertAction *mActionSettings;
    UIAlertController *mAlertController;

    NSArray *mAvailableFeatures;
    
}

-(void)viewDidLoad{
    [super viewDidLoad];
    mAlertController = [UIAlertController
                        alertControllerWithTitle:nil message:nil
                        preferredStyle:UIAlertControllerStyleActionSheet];
    
    mActionDebug = [UIAlertAction   actionWithTitle:SHOW_DEBUG_NAME
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *action) {
                                                [self performSegueWithIdentifier:OPEN_DEBUG_VIEW_SEGUE_NAME
                                                                          sender:mActionDebug];
                                            }];
    mActionSettings = [UIAlertAction   actionWithTitle:SHOW_SETTINGS_NAME
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action) {
                                                   [self performSegueWithIdentifier:SHOW_SETTINGS_VIEW_SEGUE_NAME
                                                                             sender:mActionSettings];
                                               }];
    
    
    [mAlertController addAction:mActionDebug];
    [mAlertController addAction:mActionSettings];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //TODO REMOVE THE DISABLED FEATURES
    mAvailableFeatures = [self.node getFeatures];
    mActionDebug.enabled = (self.node.debugConsole!=nil);
    mActionSettings.enabled = (self.node.configControl!=nil);

    [self.tableView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    for (W2STSDKFeature *f in mAvailableFeatures){
        [f removeFeatureDelegate:self];
    }
}

-(IBAction)showPopupMenu:(UIBarButtonItem *)sender {
    
    UIPopoverPresentationController *popPresenter = [mAlertController
                                                     popoverPresentationController];
    popPresenter.barButtonItem=sender;
    popPresenter.sourceView=self.view;
    [self presentViewController:mAlertController animated:YES completion:nil];
    
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:OPEN_DEBUG_VIEW_SEGUE_NAME]){
        ConsoleViewController *dest = (ConsoleViewController*) [segue destinationViewController];
        dest.debugInterface = self.node.debugConsole;
    }//if
    else if([segue.identifier isEqualToString:SHOW_SETTINGS_VIEW_SEGUE_NAME]){
        SettingsTableViewController *dest = (SettingsTableViewController*)[segue destinationViewController];
        dest.configControl = self.node.configControl;
    }//if
}

#pragma mark - W2STSDKFeatureDelegate

- (void)didUpdateFeature:(W2STSDKFeature *)feature{
    NSUInteger index = [mAvailableFeatures indexOfObject:feature];
    NSIndexPath *cellIndex =[NSIndexPath indexPathForRow:index inSection: 0];
    NSString *desc = [feature description];
    dispatch_sync(dispatch_get_main_queue(),^{
        [self.tableView beginUpdates];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath: cellIndex];
        cell.detailTextLabel.text = desc;
        //[_featureTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:cellIndex] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return mAvailableFeatures.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NodeFeature" forIndexPath:indexPath];
    
    W2STSDKFeature *f = [mAvailableFeatures objectAtIndex:indexPath.row];
    
    cell.textLabel.text =f.name;
    cell.detailTextLabel.text= DEFAULT_MESSAGE;
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    W2STSDKFeature *f =(W2STSDKFeature*) mAvailableFeatures[indexPath.row];
    [f addFeatureDelegate:self];
    if([f isKindOfClass:[W2STSDKFeatureAutoConfigurable class]]){
        [((W2STSDKFeatureAutoConfigurable*)f) addFeatureConfigurationDelegate:self];
    }
    if([self.node isEnableNotification:f]){
        [self.node disableNotification:f];
        [tableView cellForRowAtIndexPath:indexPath].detailTextLabel.text= DEFAULT_MESSAGE;
    }else{
        if([f isKindOfClass:[W2STSDKFeatureAutoConfigurable class]]){
            [((W2STSDKFeatureAutoConfigurable*)f) startAutoConfiguration];
        }
        [self.node enableNotification:f];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    W2STSDKFeature *f =(W2STSDKFeature*) mAvailableFeatures[indexPath.row];
    if([f isKindOfClass:[W2STSDKFeatureAutoConfigurable class]]){
        [((W2STSDKFeatureAutoConfigurable*)f) startAutoConfiguration];
    }
}


- (void)didAutoConfigurationStart:(W2STSDKFeatureAutoConfigurable *)feature{
    NSLog(@"%@: conf start",feature.name);
}
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

- (void)didConfigurationFinished:(W2STSDKFeatureAutoConfigurable *)feature status:(int32_t)status{
    NSLog(@"%@: conf stop :%d",feature.name,status);
}

-(void) debug:(W2STSDKDebug*)debug didStdOutReceived:(NSString*) msg{
    NSLog(@"stdOut: %@",msg);
}
-(void) debug:(W2STSDKDebug*)debug didStdErrReceived:(NSString*) msg{
    NSLog(@"stdErr: %@",msg);
}
-(void) debug:(W2STSDKDebug*)debug didStdInSend:(NSString*) msg error:(NSError*)error{
    if(error!=nil)
        NSLog(@"stdIn: %@ error: %@",msg,[error localizedDescription]);
    else
        NSLog(@"stdIn: %@",msg);
}


@end
