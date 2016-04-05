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

#import "DevicesTableViewController.h"

#import "MBProgressHUD.h"

#import <BlueSTSDK/BlueSTSDKManager.h>
#import <BlueSTSDK/BlueSTSDKNode.h>
#import <BlueSTSDK/BlueSTSDKNodeStatusNSLog.h>
#import "DeviceTableViewCell.h"
#import "FeatureListTableViewController.h"

#define DEMO_SEGUE_ID @"OpenDemosView"
//stop the discovery after 10	s
#define DISCOVERY_TIMEOUT (10*1000)
#define ERROR_MSG_TIMEOUT (3.0)


@interface DevicesTableViewController () <BlueSTSDKManagerDelegate,
BlueSTSDKNodeStateDelegate>

@end

@implementation DevicesTableViewController{
    /**
     *  class used for start/stop the discovery process
     */
    BlueSTSDKManager *mManager;
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
    mManager = [BlueSTSDKManager sharedInstance];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //close the connection and remove knows nodes
    if(mManager.nodes.count!=0){
        for( BlueSTSDKNode *node in mManager.nodes){
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
 */
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    assert(mManager != nil);
    [mManager addDelegate:self];
#if TARGET_IPHONE_SIMULATOR
    [mManager addVirtualNode];
#endif
    
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
 * function called each time the user click in the uibarbutton,
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


#pragma mark - BlueSTSDKManagerDelegate

/**
 * change the button state when the manager start/stop a discovery
 */
-(void)manager:(BlueSTSDKManager *)manager  didChangeDiscovery:(BOOL)enable {
    dispatch_sync(dispatch_get_main_queue(),^{
        [self setNavigationDiscoveryButton];
    });
}

/**
 *  when a new node is discover reload the table
 */
-(void)manager:(BlueSTSDKManager *)manager didDiscoverNode:(BlueSTSDKNode *)node{
    dispatch_sync(dispatch_get_main_queue(),^{
        [self.tableView reloadData];
        
    });
}


#pragma mark - Table view data source

/**
 *the table will have only 1 colum
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

/** one row for each node/device */
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
    BlueSTSDKNode *node = mNodes[indexPath.row];
    cell.boardName.text = node.name;
    cell.boardDetails.text = (node.address == nil) ? node.tag : node.address;
    
    switch(node.type){
        case BlueSTSDKNodeTypeNucleo:
            cell.boardImage.image = [UIImage imageNamed:@"board_nucleo"];
            break;
        case BlueSTSDKNodeTypeSTEVAL_WESU1:
            cell.boardImage.image = [UIImage imageNamed:@"board_steval_wesu1"];
            break;
        case BlueSTSDKNodeTypeGeneric:
        default:
            cell.boardImage.image = [UIImage imageNamed:@"board_generic"];
            break;
    }//switch
    return cell;
}//cellForRowAtIndexPath

/**
 *  callback when the user select a row, we connect and start the demo for that particular node
 *
 *  @param tableView table selected by the user
 *  @param indexPath row/col selected by the user
 */
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    BlueSTSDKNode *node = mNodes[indexPath.row];
    [node addNodeStatusDelegate:self];
    [self showConnectionProgress:node];
}//didSelectRowAtIndexPath

#pragma mark - BlueSTSDKNodeStatusDelegate

/*
 * When the node complete the connection hide the view and do the segue for the demo
 */
- (void) node:(BlueSTSDKNode *)node didChangeState:(BlueSTSDKNodeState)newState
    prevState:(BlueSTSDKNodeState)prevState{
    if(newState == BlueSTSDKNodeStateConnected)
        dispatch_sync(dispatch_get_main_queue(),^{
            [networkCheckConnHud hide:true];
            networkCheckConnHud=nil;
            [self performSegueWithIdentifier:DEMO_SEGUE_ID sender:self];
        });
    else if (newState == BlueSTSDKNodeStateDead || newState == BlueSTSDKNodeStateUnreachable){
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
- (void)showConnectionProgress:(BlueSTSDKNode *)node {
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
 * pass the selected node to the featureList controller
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (segue) {
        [super prepareForSegue:segue sender:sender];
        if ([[segue identifier] isEqualToString:DEMO_SEGUE_ID]) {
            NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
            BlueSTSDKNode *node = mNodes[indexPath.row];
            ((FeatureListTableViewController *)[segue destinationViewController]).node=node;
           
        }
    }
}


@end
