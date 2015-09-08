//
//  BleAdvertiseParser.h
//  W2STApp
//
//  Created by Giovanni Visentini on 25/03/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#ifndef BlueSTSDK_BleAdvertiseParser_h
#define BlueSTSDK_BleAdvertiseParser_h

#include "BlueSTSDKBleNodeDefines.h"
#include "../BlueSTSDKNode.h"

/**
 *  Class that parse the ble advertise package
 * @author STMicroelectronics - Central Labs.
 */
@interface BlueSTSDKBleAdvertiseParser : NSObject

/**
 *  board name
 */
@property (readonly) NSString *name;

/**
 *  version of the protocol
 */
@property (readonly) unsigned char protocolVersion;
/**
 *  board id, tell the board type
 */
@property (readonly) unsigned char deviceId;

/**
 *  bit mask that tell what feature are available in the node
 */
@property (readonly) featureMask_t featureMap;

/**
 *  tell the tx power used by the node, in mdb
 */
@property (readonly) NSNumber* txPower;

/**
 *  tell the board type
 */
@property (readonly) BlueSTSDKNodeType nodeType;

/**
 *  address, can be nil if not present in the advertise
 */
@property (readonly) NSString *address;

/**
 * parse the advertise data returned by the system
 * @param advertisementData ble advertise data
 * @throw an exception if the vendor specific field isn't compatible with 
 * the W2ST protocol
 */
+(instancetype)advertiseParserWithAdvertise:(NSDictionary *)advertisementData;

/**
 * parse the advertise data returned by the system
 * @param advertisementData ble advertise data
 * @throw an exception if the vendor specific field isn't compatible with the
 * W2ST protocol
 */
-(instancetype)initWithAdvertise:(NSDictionary*)advertisementData;


@end

#endif
