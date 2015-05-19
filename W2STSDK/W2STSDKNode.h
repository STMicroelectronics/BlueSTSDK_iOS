//
//  W2STSDKNode.h
//  W2STSDK-CB
//
//  Created by Antonino Raucea on 18/03/14.
//  Copyright (c) 2014 STMicroelectronics. All rights reserved.
//

#ifndef W2STApp_W2STSDKNode_h
#define W2STApp_W2STSDKNode_h

#import <Foundation/Foundation.h>
#import "W2STSDKManager.h"

@class W2STSDKDebug;
@class W2STSDKFeature;
typedef NS_ENUM(NSInteger, W2STSDKNodeMode) {
    W2STSDKNodeModeUSB_DFU,
    W2STSDKNodeModeOTA_BLE_DFU,
    W2STSDKNodeModeApplication
};
typedef NS_ENUM(NSInteger, W2STSDKNodeState) {
    W2STSDKNodeStateInit          = 0,
    W2STSDKNodeStateIdle          = 1,
    W2STSDKNodeStateConnecting    = 2,
    W2STSDKNodeStateConnected     = 3,
    W2STSDKNodeStateDisconnecting = 4,
    W2STSDKNodeStateLost          = 5,
    W2STSDKNodeStateUnreachable   = 6,
    W2STSDKNodeStateDead          = 7,
};

typedef NS_ENUM(NSInteger, W2STSDKNodeType) {
    W2STSDKNodeTypeGeneric      = 0x00,
    W2STSDKNodeTypeWeSU         = 0x01,
    W2STSDKNodeTypeL1_Discovery = 0x02,
    W2STSDKNodeTypeNucleo       = 0x80,
};

@protocol W2STSDKNodeBleConnectionParamDelegate;
@protocol W2STSDKNodeStateDelegate;

NS_CLASS_AVAILABLE(10_7, 5_0)
@interface W2STSDKNode : NSObject <CBPeripheralDelegate>

@property (assign, nonatomic) W2STSDKNodeState state;
@property (assign, nonatomic) W2STSDKNodeType type;
@property (readonly) NSDate *rssiLastUpdate;
@property (retain, readonly) NSString *name;	
@property (retain, readonly) NSString *tag;
@property (retain, readonly) NSNumber *RSSI;
@property (retain, readonly) W2STSDKDebug *debugConsole;
@property (retain, readonly) NSNumber *txPower;

+(NSString*) stateToString:(W2STSDKNodeState)state;

-(id) init :(CBPeripheral *)peripheral rssi:(NSNumber*)rssi advertise:(NSDictionary*)advertisementData;
-(void) addBleConnectionParamiterDelegate:(id<W2STSDKNodeBleConnectionParamDelegate>)delegate;
-(void) removeBleConnectionParamiterDelegate:(id<W2STSDKNodeBleConnectionParamDelegate>)delegate;
-(void) addNodeStatusDelegate:(id<W2STSDKNodeStateDelegate>)delegate;
-(void) removeNodeStatusDelegate:(id<W2STSDKNodeStateDelegate>)delegate;
-(BOOL) equals:(W2STSDKNode *)node;
-(NSArray*) getFeatures;
-(void) readRssi;
-(void) connect;
-(BOOL) isConnected;
-(void) disconnect;
-(BOOL) readFeature:(W2STSDKFeature*)feature;
-(BOOL) isEnableNotification:(W2STSDKFeature*)feature;
-(BOOL) enableNotification:(W2STSDKFeature*)feature;
-(BOOL) disableNotification:(W2STSDKFeature*)feature;


@end

//Protocols definition
@protocol W2STSDKNodeStateDelegate <NSObject>
@required
- (void) node:(W2STSDKNode *)node didChangeState:(W2STSDKNodeState)newState prevState:(W2STSDKNodeState)prevState;
@end

@protocol W2STSDKNodeBleConnectionParamDelegate <NSObject>
@required
- (void) node:(W2STSDKNode *)node didChangeRssi:(NSInteger)newRssi;
@optional
- (void) node:(W2STSDKNode *)node didChangeTxPower:(NSInteger)newPower;

@end

#endif

