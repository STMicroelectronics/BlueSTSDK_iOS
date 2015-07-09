//
//  W2STSDKManager.m
//  W2STSDK-CB
//
//  Created by Antonino Raucea on 02/04/14.
//  Copyright (c) 2014 STMicroelectronics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import "W2STSDKManager_prv.h"
#import "W2STSDKNode_prv.h"
#import "W2STSDKNodeFake.h"

@interface W2STSDKManager()<CBCentralManagerDelegate>
@end

@implementation W2STSDKManager{
    /**
     *  true if the manager is scanning for a new nodes
     */
    BOOL mIsScanning;
    
    /**
     *  queue to use for do delegate callback
     */
    dispatch_queue_t mNotificationQueue;
    
    /**
     *  set of W2STSDKManagerDelegate
     */
    NSMutableSet *mManagerListener;
    
    /**
     *  set with the discovered nodes, of type W2STSDKNode
     */
    NSMutableSet *mDiscoveredNode;
    
    /**
     *  system ble manager
     */
    CBCentralManager * mCBCentralManager;
}


+(W2STSDKManager *)sharedInstance {
    static W2STSDKManager *this = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        this = [[self alloc] init];
    });
    return this;
}

/**
 *  initialize the private variables
 *
 *  @return instance of a class W2STSDKManager
 */
-(id)init {
    self = [super init];

    mDiscoveredNode = [[NSMutableSet alloc] init];
    mManagerListener = [[NSMutableSet alloc] init];
    mCBCentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    mNotificationQueue = dispatch_queue_create("W2STSDKManager", DISPATCH_QUEUE_CONCURRENT);

    return self;
}

-(void) discoveryStart{
    [self discoveryStart:-1];
}

-(void) discoveryStart:(int)timeoutMs{
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES],
                             CBCentralManagerScanOptionAllowDuplicatesKey, nil];
    
    [mCBCentralManager scanForPeripheralsWithServices:nil options:options];
    [self changeDiscoveryStatus:true];
    NSTimeInterval delay = W2STSDKMANAGER_DEFAULT_SCANING_TIMEOUT_S;
    if(timeoutMs>0)
        if (timeoutMs >= 0 && timeoutMs <= 60000) { //max 60 sec
            delay = (NSTimeInterval)((double)timeoutMs / 1000.0f);
        }
    //if timeoutMs
    [self performSelector:@selector(discoveryStop) withObject:nil afterDelay:delay];
    
    //if we are running in a simulator we create a fake node for show random numbers
#if (TARGET_IPHONE_SIMULATOR)
    W2STSDKNode *fakeNode = [[W2STSDKNodeFake alloc] init];
    W2STSDKNode *node = [self nodeWithTag:fakeNode.tag];
    if(node == nil){
        [mDiscoveryedNode addObject:fakeNode];
        [self notifyNewNode:fakeNode];
    }
#endif
    
}

-(void) discoveryStop{
    [mCBCentralManager stopScan];
    [self changeDiscoveryStatus:false];
}

-(void)resetDiscovery {
    [mDiscoveredNode removeAllObjects];
}

-(NSArray*) nodes{
    return [mDiscoveredNode allObjects];
}

-(void)addDelegate:(id<W2STSDKManagerDelegate>)delegate {
    [mManagerListener addObject:delegate];
    
}
-(void)removeDelegate:(id<W2STSDKManagerDelegate>)delegate{
    [mManagerListener removeObject:delegate];
}

-(BOOL)isDiscovering{
    return mIsScanning;
}

/**
 *  call all the delegate for notify a manager status change
 *
 *  @param newStatus new manager status
 */
-(void)changeDiscoveryStatus:(BOOL)newStatus{
    mIsScanning=newStatus;
    //notify the new status to the other listeners
    for (id<W2STSDKManagerDelegate> delegate in mManagerListener) {
        dispatch_async(mNotificationQueue, ^{
            [delegate manager:self didChangeDiscovery:newStatus];
        });
    }//for
}

/**
 *  call all the delegate for notify the discovery of a new node
 *
 *  @param node new discovered node
 */
-(void)notifyNewNode:(W2STSDKNode *)node{
    for (id<W2STSDKManagerDelegate> delegate in mManagerListener) {
        dispatch_async(mNotificationQueue, ^{
            [delegate manager:self didDiscoverNode:node];
        });
    }//for
}

-(W2STSDKNode *)nodeWithName:(NSString *)name{
    for (W2STSDKNode *node in mDiscoveredNode) {
        if ([name isEqual: node.name]) {
            return node;
        }
    }
    return nil;
}

-(W2STSDKNode *)nodeWithTag:(NSString *)tag{
    for (W2STSDKNode *node in mDiscoveredNode) {
        if ([tag isEqual: node.tag]) {
            return node;
        }
    }
    return nil;
}

-(void)connect:(CBPeripheral*)peripheral{
    [mCBCentralManager connectPeripheral:peripheral options:nil];
}

-(void)disconnect:(CBPeripheral*)peripheral{
    [mCBCentralManager cancelPeripheralConnection:peripheral];
}

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

    W2STSDKNode *node = [self nodeWithTag:tag];
    if(node == nil){
        @try {
            node = [[W2STSDKNode alloc] init:peripheral rssi:RSSI
                                   advertise:advertisementData];
            
            //AR changed, in the previous version a not supported board was discarded to n exception
            //now we create the node, but without feature
            if ([node isSupported])
            {
                [mDiscoveredNode addObject:node];
                [self notifyNewNode:node];
            }
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
    }
}

/**
 * when the peripheral is connected we call the method completeconnection of the
 * node class
 */
- (void)centralManager:(CBCentralManager *)central
  didConnectPeripheral:(CBPeripheral *)peripheral{
    NSString *tag = peripheral.identifier.UUIDString;
    W2STSDKNode *node = [self nodeWithTag:tag];
    if(node == nil) //we did not handle this peripheral
        return;
    [node completeConnection];
}

/**
 * when a connection fail we call the method connectionError of the node class
 */
-(void)notifyConnectionError:(CBPeripheral*)peripheral error:(NSError*)error{
    NSString *tag = peripheral.identifier.UUIDString;
    W2STSDKNode *node = [self nodeWithTag:tag];
    if(node == nil) //we did not handle this peripheral
        return;
    [node connectionError:error];
}

/**
 * when a connection fail we call the method connectionError of the node class
 */
- (void)centralManager:(CBCentralManager *)central
didFailToConnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error{
    [self notifyConnectionError:peripheral error:error];
}

/**
 * when the peripheral is disconnected we call the method completeDisconnection of the
 * node class
 */
- (void)centralManager:(CBCentralManager *)central
didDisconnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error{
    NSString *tag = peripheral.identifier.UUIDString;
    W2STSDKNode *node = [self nodeWithTag:tag];
    if(node == nil) //we did not handle this periferal
        return;
    [node completeDisconnection:error];
}
@end
