//
//  BleAdvertiseParser.h
//  W2STApp
//
//  Created by Giovanni Visentini on 25/03/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#ifndef W2STSDK_BleAdvertiseParser_h
#define W2STSDK_BleAdvertiseParser_h

#include "W2STSDKBleNodeDefines.h"
#include "../W2STSDKNode.h"




/**
 *  Class that parse the ble advertise package
 */
@interface W2STSDKBleAdvertiseParser : NSObject

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
@property (readonly) W2STSDKNodeType nodeType;

/**
 *  address
 */
@property (readonly) NSString *address;

/**
 * parse the advertise data returned by the system
 * @param advertisementData ble advertise data
 * @throw an exception if the vendor specific field isn't compatible with the W2ST protocol
 */
+(id)advertiseParserWithAdvertise:(NSDictionary *)advertisementData;

/**
 * parse the advertise data returned by the system
 * @param advertisementData ble advertise data
 * @throw an exception if the vendor specific field isn't compatible with the W2ST protocol
 */
-(id)initWithAdvertise:(NSDictionary*)advertisementData;

/**
 *  map of <featureMask_t,W2STSDKFeature>, this can be used for undestand what
 * feature a ble characteristic export
 *
 *  @return map of <featureMask_t,W2STSDKFeature>
 */
-(NSDictionary*) featureMaskMap;


@end

#endif
