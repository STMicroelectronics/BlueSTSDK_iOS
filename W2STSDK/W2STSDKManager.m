//
//  W2STSDKManager.m
//  W2STSDK-CB
//
//  Created by Antonino Raucea on 02/04/14.
//  Copyright (c) 2014 STMicroelectronics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CBCentralManager.h>

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
    NSMutableSet *mDiscoveryedNode;
    
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

    mDiscoveryedNode = [[NSMutableSet alloc] init];
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
    [mDiscoveryedNode removeAllObjects];
}

-(NSArray*) nodes{
    return [mDiscoveryedNode allObjects];
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
    for (W2STSDKNode *node in mDiscoveryedNode) {
        if ([name isEqual: node.name]) {
            return node;
        }
    }
    return nil;
}

-(W2STSDKNode *)nodeWithTag:(NSString *)tag{
    for (W2STSDKNode *node in mDiscoveryedNode) {
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

/////////////////////// CBCentralManagerDelegate///////////////////////////////
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
            [mDiscoveryedNode addObject:node];
            [self notifyNewNode:node];
        }
        @catch (NSException *exception) {//not a valid advertise -> avoid to add it
        }
       
    }else{
        [node updateRssi:RSSI];
    }
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    CBCentralManagerState state = [central state];
    if(state!=CBCentralManagerStatePoweredOn){
        [self changeDiscoveryStatus:false];
    }else{
        [self changeDiscoveryStatus:true];
    }
}

- (void)centralManager:(CBCentralManager *)central
  didConnectPeripheral:(CBPeripheral *)peripheral{
    NSString *tag = peripheral.identifier.UUIDString;
    W2STSDKNode *node = [self nodeWithTag:tag];
    if(node == nil) //we did not handle this periferal
        return;
    [node completeConnection];
}

-(void)notifyConnectionError:(CBPeripheral*)peripheral error:(NSError*)error{
    NSString *tag = peripheral.identifier.UUIDString;
    W2STSDKNode *node = [self nodeWithTag:tag];
    if(node == nil) //we did not handle this periferal
        return;
    [node connectionError:error];
}

- (void)centralManager:(CBCentralManager *)central
didFailToConnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error{
    [self notifyConnectionError:peripheral error:error];
}

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
