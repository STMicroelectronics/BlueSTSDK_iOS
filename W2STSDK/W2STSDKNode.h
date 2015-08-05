//
//  W2STSDKNode.h
//  W2STSDK
//
//  Created by Giovanni Visentini on 21/04/15.
//  Copyright (c) 2014 STMicroelectronics. All rights reserved.
//

#ifndef W2STSDK_W2STSDKNode_h
#define W2STSDK_W2STSDKNode_h

#import <Foundation/Foundation.h>
#import "W2STSDKManager.h"

@class W2STSDKDebug;
@class W2STSDKConfigControl;
@class W2STSDKFeature;



@protocol W2STSDKNodeBleConnectionParamDelegate;
@protocol W2STSDKNodeStateDelegate;

/**
 * Class that represent a remote device that will export some data (as {@link W2STSDKFeature})
 * that the user can query or ask to be notify when they change.
 * @author STMicroelectronics - Central Labs.
 */
NS_CLASS_AVAILABLE(10_7, 5_0)
@interface W2STSDKNode : NSObject 

/**
 *  possible node mode
 */
typedef NS_ENUM(NSInteger, W2STSDKNodeMode){
    /**
     *  enter in the update mode through the usb port
     */
    W2STSDKNodeModeUSB_DFU,
    /**
     *  enter in the update mode through the ble connection
     */
    W2STSDKNodeModeOTA_BLE_DFU,
    /**
     *  normal state
     */
    W2STSDKNodeModeApplication
};

/**
 *  possible connection state
 */
typedef NS_ENUM(NSInteger, W2STSDKNodeState){
    /**
     *  start state
     */
    W2STSDKNodeStateInit          = 0,
    /**
     *  node available, waiting for a connection command
     */
    W2STSDKNodeStateIdle          = 1,
    /**
     *  connection in progress
     */
    W2STSDKNodeStateConnecting    = 2,
    /**
     *  node connected
     */
    W2STSDKNodeStateConnected     = 3,
    /**
     *  disconnection in progress
     */
    W2STSDKNodeStateDisconnecting = 4,
    /**
     *  error during a connection
     */
    W2STSDKNodeStateLost          = 5,
    /**
     *  the node does't respond to a connection
     */
    W2STSDKNodeStateUnreachable   = 6,
    /**
     *  end node
     */
    W2STSDKNodeStateDead          = 7,
};

/**
 *  board type
 */
typedef NS_ENUM(NSInteger, W2STSDKNodeType){
    /**
     *  unknown board
     */
    W2STSDKNodeTypeGeneric      = 0x00,
    /**
     *  Wesu board
     */
    W2STSDKNodeTypeWeSU         = 0x01,
    /**
     *  L1 board
     */
    W2STSDKNodeTypeL1_Discovery = 0x02,
    /**
     *  nucleo + ble expansion board
     */
    W2STSDKNodeTypeNucleo       = 0x80,
};

/**
 *  current board status
 */
@property (assign, nonatomic,readonly) W2STSDKNodeState state;

/**
 *  board type
 */
@property (assign, nonatomic,readonly) W2STSDKNodeType type;

/**
 *  node name, is not guaranteed that this string is unique
 */
@property (retain, readonly) NSString *name;

/**
 *  node address, if available in the advertise otherwise nil
 */
@property (retain, readonly) NSString *address;

/**
 *  version of the protocol
 */
@property (readonly) unsigned char protocolVersion;

/**
 *  unique string that identify the node
 */
@property (retain, readonly) NSString *tag;

/**
 *  date of the last rssi update package
 */
@property (readonly) NSDate *rssiLastUpdate;

/**
 *  last rssi signal value
 */
@property (retain, readonly) NSNumber *RSSI;

/**
 *  object that we can use for access to the debug console or nil if it is absent
 */
@property (retain, readonly) W2STSDKDebug *debugConsole;

/**
 *  object that we can use for access to the config node or nil if it is absent
 */
@property (readonly) W2STSDKConfigControl *configControl;

/**
 *  tx power used from the board
 */
@property (retain, readonly) NSNumber *txPower;

/**
 *  convert the enum value to a string
 *
 *  @param state enum with the current board status
 *
 *  @return a string representation of the enum value
 */
+(NSString*) stateToString:(W2STSDKNodeState)state;

/**
 *  add a delegate where notify the change in the connection parameters
 *
 *  @param delegate object where notify change of rssi or transmission power
 */
-(void) addBleConnectionParamiterDelegate:(id<W2STSDKNodeBleConnectionParamDelegate>)delegate;

/**
 *  remove a delefate of type {@link W2STSDKNodeBleConnectionParamDelegate}
 *
 *  @param delegate delegate to remove
 */
-(void) removeBleConnectionParamiterDelegate:(id<W2STSDKNodeBleConnectionParamDelegate>)delegate;

/**
 *  add a delegate where notify change of the node connection status
 *
 *  @param delegate delegate to add
 */
-(void) addNodeStatusDelegate:(id<W2STSDKNodeStateDelegate>)delegate;

/**
 *  remove a delegate of type {@link W2STSDKNodeStateDelegate}
 *
 *  @param delegate delegate to remove
 */
-(void) removeNodeStatusDelegate:(id<W2STSDKNodeStateDelegate>)delegate;

/**
 *  compare two nodes, the node are equal if the tag value is the same
 *
 *  @param node node to compare
 *
 *  @return true if node.tag == self.tag
 */
-(BOOL) equals:(W2STSDKNode *)node;

/**
 *  get the available node feature, there is a feature for each bit set in the advertise,
 *  if the linked characteristics is not find in the node the feature is not enabled
 *
 *  @return array of {@link W2STSDKFeature} that the node can export
 */
-(NSArray*) getFeatures;

/**
 *  request to update the rssi value
 *  the answer is notify through the {@link W2STSDKNodeBleConnectionParamDelegate::node:didChangeRssi:}
 * callback
 */
-(void) readRssi;

/**
 *  open a connection with this node
 * \par when the connection is completed the the class notify it with a callback
 * on {link W2STSDKNodeStateDelegate::node:didChangeState:prevState:
 */
-(void) connect;

/**
 *  tell if this node is connected
 *
 *  @return true if the node is in the state W2STSDKNodeStateConnected
 */
-(BOOL) isConnected;

/**
 *  close the connection with this node
 */
-(void) disconnect;

/**
 *  request to read the value of a particular feature, the feature will manage to notify you the new value
 *
 *  @param feature feature to read
 *
 *  @return true if the request is send correctly
 */
-(BOOL) readFeature:(W2STSDKFeature*)feature;

/**
 *  tell if you enable the notification for this particular feature
 *
 *  @param feature feature
 *
 *  @return true if you enable the notification for this feature
 */
-(BOOL) isEnableNotification:(W2STSDKFeature*)feature;

/**
 *  enable the notification for a particular feature, the feature will manage 
 * to notify you the new values
 *
 *  @param feature feature to notify
 *
 *  @return true if the request is send correctly
 */
-(BOOL) enableNotification:(W2STSDKFeature*)feature;

/**
 *  disable the notification for a particular feature
 *
 *  @param feature feature to stop notify
 *
 *  @return true if the request is send correctly
 */
-(BOOL) disableNotification:(W2STSDKFeature*)feature;

@end

/**
 *  protocol used by the node for notify a connection state change
 */
@protocol W2STSDKNodeStateDelegate <NSObject>

@required
/**
 *  notify to the user that the node change the status
 *
 *  @param node      node that call the delegate, node that change the status
 *  @param newState  new node status
 *  @param prevState old node status
 */
- (void) node:(W2STSDKNode *)node didChangeState:(W2STSDKNodeState)newState prevState:(W2STSDKNodeState)prevState;
@end

/**
 *  protocol used by the node for notify a change in the ble connection parameters
 */
@protocol W2STSDKNodeBleConnectionParamDelegate <NSObject>

@required
/**
 *  notify to the user a new rssi value
 *
 *  @param node    node that has a new rssi value
 *  @param newRssi new rssi value for the nodes
 */
- (void) node:(W2STSDKNode *)node didChangeRssi:(NSInteger)newRssi;

@optional
/**
 *  notify to the user that the tx power change
 *
 *  @param node     node that change the tx power
 *  @param newPower new tx power for the node
 *  @note implement this method is optional
 */
- (void) node:(W2STSDKNode *)node didChangeTxPower:(NSInteger)newPower;

@end

#endif

