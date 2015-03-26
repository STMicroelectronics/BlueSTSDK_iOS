//
//  W2STSDKManager.m
//  W2STSDK-CB
//
//  Created by Antonino Raucea on 02/04/14.
//  Copyright (c) 2014 STMicroelectronics. All rights reserved.
//

#import <CoreBluetooth/CBCentralManager.h>
#import "W2STSDKManager.h"


@interface W2STSDKManager()
-(id)init;
-(void)notifyNewNode:(W2STSDKNode*)node;
-(void)changeDiscoveryStatus:(BOOL)newStatus;

@end

@implementation W2STSDKManager{
    BOOL mIsScanning;
    dispatch_queue_t mNotificationQueue;
     //TODO ADD LOOK
    NSMutableSet *mManagerListener;
    NSMutableSet *mDiscoveryedNode;
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
    //NSDictionary *options = nil;
    
    [mCBCentralManager scanForPeripheralsWithServices:nil options:options];
    [self changeDiscoveryStatus:true];
    if(timeoutMs>0){
        //TODO STOP THE SCAN AFTER THE TIMEOUT
    }
    
}

-(void) discoveryStop{
    [mCBCentralManager stopScan];
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

-(void)changeDiscoveryStatus:(BOOL)newStatus{
    mIsScanning=newStatus;
    //notify the new status to the other listeners
    for (id<W2STSDKManagerDelegate> delegate in mManagerListener) {
        dispatch_async(mNotificationQueue, ^{
            [delegate manager:self didChangeDiscovery:newStatus];
        });
    }
}

-(void)notifyNewNode:(W2STSDKNode *)node{
    for (id<W2STSDKManagerDelegate> delegate in mManagerListener) {
        dispatch_async(mNotificationQueue, ^{
            [delegate manager:self didDiscoverNode:node];
        });
    }
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



/////////////////////// CBCentralManagerDelegate///////////////////////////////
- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI{
    NSString *tag = peripheral.identifier.UUIDString;
    W2STSDKNode *node = [self nodeWithTag:tag];
    if(node == nil){
        node = [[W2STSDKNode alloc] init:peripheral];
        [mDiscoveryedNode addObject:node];
        [self notifyNewNode:node];
    }else{
        //[node updateRssi:RSSI];
    }
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    CBCentralManagerState state = [central state];
    if(state!=CBCentralManagerStatePoweredOn){
        [self changeDiscoveryStatus:false];
    }
}


@end
