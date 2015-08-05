//
//  W2STSDKNode_prv.h
//  W2STSDK
//
//  Created by Giovanni Visentini on 19/05/15.
//  Copyright (c) 2015 STCentralLab. All rights reserved.
//

#ifndef W2STSDK_W2STSDKNode_prv_h
#define W2STSDK_W2STSDKNode_prv_h

#include <CoreBluetooth/CBPeripheral.h>
#include <CoreBluetooth/CBCharacteristic.h>
#include "W2STSDKNode.h"

/**
 * package method of the {@link W2STSDKNode} class
 * @author STMicroelectronics - Central Labs.
 */
@interface W2STSDKNode(Prv)

/**
 *  create a new node, if the node doesn't has a correct advertise this method will
 * throw an exception
 *
 *  @param peripheral        ble peripheral that
 *  @param rssi              advertise rssi
 *  @param advertisementData data in the advertise
 *
 *  @return class W2STSDKNode
 *  @throw NSException if the ble advertise hasn't all the mandatory fields
 */
-(instancetype) init :(CBPeripheral *)peripheral rssi:(NSNumber*)rssi
  advertise:(NSDictionary*)advertisementData;

/**
 *  initialize the node without a peripheral
 * \note it will not be able to do anything this function is needed if you want
 * extend the node and keep using the delegate system build by this class
 *
 *  @return semi functional node pointer
 */
-(instancetype) init;

/**
 *  this method will update the rssi node value and notify the update to
 * the delegates
 *
 *  @param rssi new rssi values
 */
-(void)updateRssi:(NSNumber*)rssi;

/**
 *  this method will update the txPower of the node and notify the update to
 * the delegates
 *
 *  @param txPower new tx power
 */
-(void)updateTxPower:(NSNumber*)txPower;

/**
 *  this method is called by the W2STSDKManager when the CBCentralManager
 * complete the connection with the peripheral, this method will start to request
 * the node service and characteristics
 */
-(void)completeConnection;

/**
 *  this method is called by  W2STSDKManager when the CBCentralManager is not able
 *  to complete a connection because some error happen
 *
 *  @param error error occurred during the disconnection
 */
-(void)connectionError:(NSError*)error;

/**
 *  this method is called by the W2STSDKManager when the CBCentralManager complete the
 * peripheral disconnection.
 *
 *  @param error optional error occurred during the disconnection
 */
-(void)completeDisconnection:(NSError*)error;

/**
 *  change the node status and notify the event to the delegates
 *
 *  @param newState new node status
 */
-(void)updateNodeStatus:(W2STSDKNodeState)newState;

/**
 *  called by the CBPeripheralDelegate when a characteristics is read or notify
 *
 *  @param characteristics characteristics that has new data to be parsed
 */
-(void)characteristicUpdate:(CBCharacteristic*)characteristics;

/**
 *  send a command to the command service in the node
 *
 *  @param f           feature that will receive the command
 *  @param commandType command id
 *  @param commandData optional command data
 *
 *  @return true if the command is correctly send
 */
-(BOOL)sendCommandMessageToFeature:(W2STSDKFeature*)f type:(uint8_t)commandType
                              data:(NSData*) commandData;

/**
 *  write a data into a feature characteristics
 *
 *  @param f receiver feature
 *  @param data data to send to the feature
 *
 *  @return true if the command is correctly send
 */
-(BOOL)writeDataToFeature:(W2STSDKFeature*)f data:(NSData*)data;


@end


#endif
