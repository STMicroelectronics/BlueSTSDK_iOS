//
//  FeatureListTableViewController.m
//  W2STSDKSampleApp
//
//  Created by Giovanni Visentini on 03/08/15.
//  Copyright (c) 2015 STCentralLab. All rights reserved.
//

#import "FeatureListTableViewController.h"

#import <W2STSDK/W2STSDKFeature.h>
#import <W2STSDK/W2STSDKFeatureAutoConfigurable.h>
#import <W2STSDK/W2STSDKFeatureField.h>

#define DEFAULT_MESSAGE @"Click for enable the notification"

@interface FeatureListTableViewController() <W2STSDKFeatureDelegate,
    W2STSDKFeatureAutoConfigurableDelegate>
@end

@implementation FeatureListTableViewController{
    NSArray *mAvailableFeatures;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //TODO REMOVE THE DISABLED FEATURES
    mAvailableFeatures = [self.node getFeatures];
    [self.tableView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    for (W2STSDKFeature *f in mAvailableFeatures){
        [f removeFeatureDelegate:self];
    }
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
