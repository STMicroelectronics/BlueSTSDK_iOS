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

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import "Util/BlueSTSDKBleNodeDefines.h"
#import "BlueSTSDKManager_prv.h"
#import "BlueSTSDKNode_prv.h"
#import "BlueSTSDKNodeFake.h"

#define RETRAY_START_SCANNING_DELAY (0.5) //half second

@interface BlueSTSDKManager()<CBCentralManagerDelegate>
@end

@implementation BlueSTSDKManager{
    /**
     *  true if the manager is scanning for a new nodes
     */
    bool mIsScanning;
    
    /**
     *  concurrent queue to use for do callback
     */
    dispatch_queue_t mNotificationQueue;
    
    /**
     *  set of BlueSTSDKManagerDelegate
     */
    NSMutableSet *mManagerListener;
    
    /**
     *  set with the discovered nodes, of type BlueSTSDKNode
     */
    NSMutableArray *mDiscoveredNode;
    
    /**
     * contains the map (featureMask_t,Feature class) for each know node id
     */
    NSMutableDictionary *mNodeFeatureMap;
    
    /**
     *  system ble manager
     */
    CBCentralManager * mCBCentralManager;
}


+(instancetype)sharedInstance {
    static BlueSTSDKManager *this = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        this = [[self alloc] init];
    });
    return this;
}

/**
 *  initialize the private variables
 *
 *  @return instance of a class BlueSTSDKManager
 */
-(id)init {
    self = [super init];
    
    mDiscoveredNode = [NSMutableArray array];
    mManagerListener = [NSMutableSet set];
    mCBCentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    mNotificationQueue = dispatch_queue_create("BlueSTSDKManager", DISPATCH_QUEUE_CONCURRENT);
    

    NSDictionary *defaultValue =[BlueSTSDKBoardFeatureMap boardFeatureMap];
    mNodeFeatureMap = [NSMutableDictionary dictionaryWithCapacity:defaultValue.count];
    //for each key in defaultValue, add a new entry in the mNodeFeatureMap
    [defaultValue enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
        [mNodeFeatureMap setObject:[NSMutableDictionary dictionaryWithDictionary:object]
                             forKey:key];
    }];
    
    return self;
}

-(void) discoveryStart{
    [self discoveryStart:-1];
}//discoveryStart

-(void)discoveryStartObj:(NSNumber*)timeoutMs{
    [self discoveryStart:timeoutMs.intValue];
}

-(void) discoveryStart:(int)timeoutMs{
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES],
                             CBCentralManagerScanOptionAllowDuplicatesKey, nil];
    if(mCBCentralManager.state!=CBCentralManagerStatePoweredOn){
        [self performSelector:@selector(discoveryStartObj:)
                   withObject:[NSNumber numberWithInt:timeoutMs]
                   afterDelay:RETRAY_START_SCANNING_DELAY];
        return;
    }
    [mCBCentralManager scanForPeripheralsWithServices:nil options:options];
    [self changeDiscoveryStatus:true];
    NSTimeInterval delay = -1.0f;
    if(timeoutMs>0) {
        delay = (NSTimeInterval)((double)timeoutMs / 1000.0f);
        //if timeoutMs
    }
    if(delay>0)
        [self performSelector:@selector(discoveryStop)
                   withObject:nil
                   afterDelay:delay];
    //else don't stop the discovery
}//discoveryStart

-(void) discoveryStop{
    if(mCBCentralManager.state!=CBCentralManagerStatePoweredOn)
        return;
    [mCBCentralManager stopScan];
    //remove perfom selector if we stop the discovery before the timeout
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(discoveryStop)
                                               object:nil];
    [self changeDiscoveryStatus:false];
}

-(void)resetDiscovery {
    [self resetDiscovery:YES];
}
-(void)resetDiscovery:(BOOL)force {
    if (force) {
        for( BlueSTSDKNode *node in mDiscoveredNode){
            if([node isConnected]){
                [node disconnect];
            }//if
        }//for
    }
    NSMutableArray *removeMe = [NSMutableArray arrayWithCapacity:mDiscoveredNode.count];
    for( BlueSTSDKNode *node in mDiscoveredNode){
        if( ![node isConnected]){
            [removeMe addObject:node];
        }//if
    }//for
    for (BlueSTSDKNode *remove in removeMe){
        [mDiscoveredNode removeObject:remove];
    }//for
    
    
}//resetDiscovery

-(NSArray*) nodes{
    return mDiscoveredNode; //[mDiscoveredNode allObjects];
}

-(void)addDelegate:(id<BlueSTSDKManagerDelegate>)delegate {
    [mManagerListener addObject:delegate];
    
}
-(void)removeDelegate:(id<BlueSTSDKManagerDelegate>)delegate{
    [mManagerListener removeObject:delegate];
}

-(BOOL)isDiscovering{
    return mIsScanning;
}

/**
 *  change the status and call all the delegate for notify a manager status change
 *
 *  @param newStatus new manager status
 */
-(void)changeDiscoveryStatus:(BOOL)newStatus{
    mIsScanning=newStatus;
    //notify the new status to the other listeners
    for (id<BlueSTSDKManagerDelegate> delegate in mManagerListener) {
        dispatch_async(mNotificationQueue, ^{
            [delegate manager:self didChangeDiscovery:newStatus];
        });
    }//for
}//changeDiscoveryStatus

/**
 *  add a new node and call all the delegate for notify the discovery of a new node
 *
 *  @param node new discovered node
 */
-(void)addAndNotifyNewNode:(BlueSTSDKNode *)node{
    [mDiscoveredNode addObject:node];
    for (id<BlueSTSDKManagerDelegate> delegate in mManagerListener) {
        dispatch_async(mNotificationQueue, ^{
            [delegate manager:self didDiscoverNode:node];
        });
    }//for
}//addAndNotifyNewNode

-(BlueSTSDKNode *)nodeWithName:(NSString *)name{
    for (BlueSTSDKNode *node in mDiscoveredNode) {
        if ([name isEqual: node.name]) {
            return node;
        }//if
    }//for
    return nil;
}//nodeWithName

-(BlueSTSDKNode *)nodeWithTag:(NSString *)tag{
    for (BlueSTSDKNode *node in mDiscoveredNode) {
        if ([tag isEqual: node.tag]) {
            return node;
        }//if
    }//for
    return nil;
}//nodeWithTag

/**
 *  add a new node and call all the delegate for notify the discovery of a new node
 *
 *  @param node new discovered node
 */
- (void) addVirtualNode {
    @try {
        BlueSTSDKNode *fakeNode = [[BlueSTSDKNodeFake alloc] init];
        [self addAndNotifyNewNode:fakeNode];
    }
    @catch (NSException *exception) {//not a valid advertise -> avoid to add it
    }
}
/**
 *  for each key of the dictionary it check that it has only one bit to 1
 *
 *  @param features map of <uint32_t,Feature class>
 *
 *  @return true if all the keys have only one bit set to 1
 */
-(bool)checkFeatureMask:(NSDictionary*)features{
    
    for( NSNumber *n in features ){
        uint32_t temp = n.unsignedIntValue;
        
        //http://stackoverflow.com/questions/109023/how-to-count-the-number-of-set-bits-in-a-32-bit-integer
        temp = temp - ((temp >> 1) & 0x55555555);
        temp = (temp & 0x33333333) + ((temp >> 2) & 0x33333333);
        temp = (((temp + (temp >> 4)) & 0x0F0F0F0F) * 0x01010101) >> 24;
        
        if(temp!=1)
            return false;
    }
    return true;
    
}

-(void)addFeatureForNode:(uint8_t)nodeId features:(NSDictionary*)features{

    if(![self checkFeatureMask:features])
        @throw [NSException
                exceptionWithName:@"Invalid feature key data"
                reason:@"the key must have only one bit set to 1"
                userInfo:nil];
    NSMutableDictionary *addToMe = [mNodeFeatureMap objectForKey:
                                  [NSNumber numberWithUnsignedChar:nodeId]];
    if(addToMe==nil){
        [mNodeFeatureMap setObject:[NSMutableDictionary dictionaryWithDictionary:features]
                             forKey:[NSNumber numberWithUnsignedChar:nodeId]];
    }else{
        [addToMe addEntriesFromDictionary:features];
    }
    
}

-(NSDictionary*)getFeaturesForNode:(uint8_t)nodeId{
    return [mNodeFeatureMap objectForKey:
            [NSNumber numberWithUnsignedChar:nodeId]];
}

-(bool)isValidNodeId:(uint8_t)nodeId{
    return [self getFeaturesForNode:nodeId]!=nil;
}

#pragma mark - BlueSTSDKManager(prv)

-(void)connect:(CBPeripheral*)peripheral{
    if(mCBCentralManager.state!=CBCentralManagerStatePoweredOn)
        return;
    [mCBCentralManager connectPeripheral:peripheral options:nil];
}//connect

-(void)disconnect:(CBPeripheral*)peripheral{
    if(mCBCentralManager.state!=CBCentralManagerStatePoweredOn)
        return;
    [mCBCentralManager cancelPeripheralConnection:peripheral];
}//disconnect

#pragma mark - CBCentralManagerDelegate

/**
 * if the peripheral has a valid advertise we build a new node and notify the discovery
 * otherwise we skip it
 * if the node is already discovered we update its rssi value
 */
- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI{
    NSString *tag = peripheral.identifier.UUIDString;
    
    BlueSTSDKNode *node = [self nodeWithTag:tag];
    if(node == nil){
        @try {
            node = [[BlueSTSDKNode alloc] init:peripheral rssi:RSSI
                                   advertise:advertisementData];
            [self addAndNotifyNewNode:node];
        }
        @catch (NSException *exception) {//not a valid advertise -> avoid to add it
        }
        
    }else{
        [node updateRssi:RSSI];
    }//if-else
}

/**
 * when the system stop the discovery process we notify it to the user
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    CBCentralManagerState state = [central state];
    if(state!=CBCentralManagerStatePoweredOn){
        [self changeDiscoveryStatus:false];
    }else{
        [self changeDiscoveryStatus:true];
    }//if-else
}//centralManagerDidUpdateState

/**
 * when the peripheral is connected we call the method
 * {@link BlueSTSDKNode#completeConnection} of the node class
 */
- (void)centralManager:(CBCentralManager *)central
  didConnectPeripheral:(CBPeripheral *)peripheral{
    NSString *tag = peripheral.identifier.UUIDString;
    BlueSTSDKNode *node = [self nodeWithTag:tag];
    if(node == nil) //we did not handle this peripheral
        return;
    [node completeConnection];
}//didConnectPeripheral

/**
 * when a connection fail we call the method {@link BlueSTSDKNode#connectionError:}
 * of the node class
 */
-(void)notifyConnectionError:(CBPeripheral*)peripheral error:(NSError*)error{
    NSString *tag = peripheral.identifier.UUIDString;
    BlueSTSDKNode *node = [self nodeWithTag:tag];
    if(node == nil) //we did not handle this peripheral
        return;
    [node connectionError:error];
}//notifyConnectionError

/**
 * when a connection fail we call the method {@link BlueSTSDKNode#connectionError:}
 * of the node class
 */
- (void)centralManager:(CBCentralManager *)central
didFailToConnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error{
    [self notifyConnectionError:peripheral error:error];
}//didFailToConnectPeripheral

/**
 * when the peripheral is disconnected we call the method 
 * {@link BlueSTSDKNode#completeDisconnection:} of the node class
 */
- (void)centralManager:(CBCentralManager *)central
didDisconnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error{
    NSString *tag = peripheral.identifier.UUIDString;
    BlueSTSDKNode *node = [self nodeWithTag:tag];
    if(node == nil) //we did not handle this peripheral
        return;
    [node completeDisconnection:error];
}//didDisconnectPeripheral

@end
