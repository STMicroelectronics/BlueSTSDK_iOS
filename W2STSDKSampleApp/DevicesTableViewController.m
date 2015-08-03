//
//  DeviceTableViewController.m
//  W2STSDKSampleApp
//
//  Created by Giovanni Visentini on 03/08/15.
//  Copyright (c) 2015 STCentralLab. All rights reserved.
//

#import "DevicesTableViewController.h"

#import "MBProgressHUD.h"

#import <W2STSDK/W2STSDKManager.h>
#import <W2STSDK/W2STSDKNode.h>
#import <W2STSDK/W2STSDKNodeStatusNSLog.h>
#import "DeviceTableViewCell.h"
#import "FeatureListTableViewController.h"

#define DEMO_SEGUE_ID @"OpenDemosView"
//stop the discovery after 8s
#define DISCOVERY_TIMEOUT (10*1000)
#define ERROR_MSG_TIMEOUT (3.0)


@interface DevicesTableViewController () <W2STSDKManagerDelegate,
W2STSDKNodeStateDelegate>

@end

@implementation DevicesTableViewController{
    /**
     *  class used for start/stop the discovery process
     */
    W2STSDKManager *mManager;
    /**
     *  list of discovered nodes
     */
    NSArray *mNodes;
    
    /**
     *  view to show while the iphone is connecting to the node
     */
    MBProgressHUD *networkCheckConnHud;
}

/**
 *  retreive the manager object
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    mManager = [W2STSDKManager sharedInstance];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //close the connection and remove knows nodes
    if(mManager.nodes.count!=0){
        for( W2STSDKNode *node in mManager.nodes){
            if([node isConnected]){
                [node disconnect];
            }
        }
        [mManager resetDiscovery]; // remove know nodes
        [self.tableView reloadData];
    }
}

/**
 *  start the discovery process, when the view is shown,
 *  we close the connection with all the previous discovered nodes
 *
 */
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    assert(mManager != nil);
    [mManager addDelegate:self];
    
    
    //if some node are already discovered show it, and we disconnect
    [mManager discoveryStart:DISCOVERY_TIMEOUT];
    [self setNavigationDiscoveryButton];
    
}


/**
 *  when the view change we stop the discovering process
 *
 *  @param animated <#animated description#>
 */
- (void)viewWillDisappear:(BOOL)animated {
    assert(mManager != nil);
    [mManager removeDelegate:self];
    [mManager discoveryStop];
    [super viewWillDisappear:animated];
}

/**
 *  function called each time the user click in the uibarbutton,
 * it change the status of the discovery
 */
-(void) manageDiscoveryButton {
    if([mManager isDiscovering]){
        [mManager discoveryStop];
    }else{
        //remove old data
        [mManager resetDiscovery];
        [self.tableView reloadData];
        //start to discovery new data
        [mManager discoveryStart:DISCOVERY_TIMEOUT];
    }
}

/**
 *  add the view a bar button for enable/disable the discovery the button will
 * have a search icon if the manager is NOT searching for new nodes, or an X othewise
 */
-(void)setNavigationDiscoveryButton {
    if(mManager.isDiscovering) {
        self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc ] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                       target:self
                                                       action:@selector(manageDiscoveryButton)];
    }else{
        self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc ] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                       target:self
                                                       action:@selector(manageDiscoveryButton)];
    }//if-else
}


#pragma mark - W2STSDKManagerDelegate

/**
 * change the button state when the manager start/stop a discovery
 */
-(void)manager:(W2STSDKManager *)manager  didChangeDiscovery:(BOOL)enable {
    dispatch_sync(dispatch_get_main_queue(),^{
        [self setNavigationDiscoveryButton];
    });
}

/**
 *  when a new node is discover reload the table
 */
-(void)manager:(W2STSDKManager *)manager didDiscoverNode:(W2STSDKNode *)node{
    dispatch_sync(dispatch_get_main_queue(),^{
        [self.tableView reloadData];
        
    });
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    mNodes = [mManager nodes];
    return mNodes.count;
}

/*
 *
 * build a castom row for the device,the icon depends from the board type
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellTableIdentifier = @"DeviceTableViewCell";
    DeviceTableViewCell *cell = (DeviceTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellTableIdentifier];
    
    if (cell == nil) {
        cell = [[DeviceTableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:cellTableIdentifier];
    }
    
    //get node index row
    W2STSDKNode *node = mNodes[indexPath.row];
    cell.boardName.text = node.name;
    //AR show the protocol version and a star if not supported
    //cell.boardName.text = [NSString stringWithFormat:([node isSupported] ? @"%@ 0x%0.2X" : @"%@ 0x%0.2X *"), node.name, node.protocolVersion];
    cell.boardDetails.text = (node.address == nil) ? node.tag : node.address;
    switch(node.type){
        case W2STSDKNodeTypeNucleo:
            cell.boardImage.image = [UIImage imageNamed:@"board_nucleo.png"];
            break;
        case W2STSDKNodeTypeL1_Discovery:
        case W2STSDKNodeTypeWeSU:
            cell.boardImage.image = [UIImage imageNamed:@"board_wesu.png"];
            break;
        case W2STSDKNodeTypeGeneric:
        default:
            cell.boardImage.image = [UIImage imageNamed:@"board_generic.png"];
            break;
    }
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    W2STSDKNode *node = mNodes[indexPath.row];
    [node addNodeStatusDelegate:self];
    [self showConnectionProgress:node];
}

#pragma mark - W2STSDKNodeStatusDelegate

/*
 *when the node complete the connection hide the view and do the segue for the demo
 */
- (void) node:(W2STSDKNode *)node didChangeState:(W2STSDKNodeState)newState
    prevState:(W2STSDKNodeState)prevState{
    if(newState == W2STSDKNodeStateConnected)
        dispatch_sync(dispatch_get_main_queue(),^{
            [networkCheckConnHud hide:true];
            networkCheckConnHud=nil;
            [self performSegueWithIdentifier:DEMO_SEGUE_ID sender:self];
        });
    else if (newState == W2STSDKNodeStateDead || newState == W2STSDKNodeStateUnreachable){
        NSString *str = [NSString stringWithFormat:@"Cannot connect with the device: %@", node.name ];
        dispatch_sync(dispatch_get_main_queue(),^{
            [networkCheckConnHud hide:true];
            networkCheckConnHud=nil;
            networkCheckConnHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            networkCheckConnHud.mode=MBProgressHUDModeText;
            networkCheckConnHud.labelText=str;
            [networkCheckConnHud show:YES];
            [networkCheckConnHud hide:true afterDelay:ERROR_MSG_TIMEOUT];
        });
    }//if-else
}

/**
 *  display the activity indicator view while we wait that the connection is done
 *
 *  @param node node selecte by the user
 */
- (void)showConnectionProgress:(W2STSDKNode *)node {
    if (!node.isConnected) { //we have to connect to the node
        
        networkCheckConnHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        networkCheckConnHud.mode = MBProgressHUDModeIndeterminate;
        networkCheckConnHud.removeFromSuperViewOnHide = YES;
        networkCheckConnHud.labelText = @"Connecting";
        
        [networkCheckConnHud show:YES];
        [node connect];
    }
}

/*
 * set the node to the demo view
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (segue) {
        [super prepareForSegue:segue sender:sender];
        if ([[segue identifier] isEqualToString:DEMO_SEGUE_ID]) {
            NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
            W2STSDKNode *node = mNodes[indexPath.row];
            ((FeatureListTableViewController *)[segue destinationViewController]).node=node;
           
        }
    }
}


@end