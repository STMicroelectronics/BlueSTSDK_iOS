//
//  W2STSDKManager.h
//  W2STSDK-CB
//
//  Created by Antonino Raucea on 02/04/14.
//  Copyright (c) 2014 STMicroelectronics. All rights reserved.
//
#ifndef W2STApp_W2STSDKManager_h
#define W2STApp_W2STSDKManager_h

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#include "W2STSDKNode.h"
@protocol W2STSDKManagerDelegate;


@interface W2STSDKManager : NSObject<CBCentralManagerDelegate>
-(void)discoveryStart;
-(void)discoveryStart:(int)timeoutMs;
-(void)discoveryStop;

-(void)addDelegate:(id<W2STSDKManagerDelegate>)delegate;
-(void)removeDelegate:(id<W2STSDKManagerDelegate>)delegate;
-(NSArray *) nodes;
-(BOOL) isDiscovering;
-(void) resetDiscovery;
-(W2STSDKNode *)nodeWithName:(NSString *)name;
-(W2STSDKNode *)nodeWithTag:(NSString *)tag;

+ (W2STSDKManager *)sharedInstance;

/////////package function//////////////
-(void)connect:(CBPeripheral*)peripheral;
-(void)disconnect:(CBPeripheral*)peripheral;

@end

//protocol
@protocol W2STSDKManagerDelegate <NSObject>
@required
- (void)manager:(W2STSDKManager *)manager didDiscoverNode:(W2STSDKNode *)node;
- (void)manager:(W2STSDKManager *)manager didChangeDiscovery:(BOOL)enable;
@end

#endif