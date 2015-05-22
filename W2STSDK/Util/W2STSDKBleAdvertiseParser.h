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

/*
 //not used since the address field is not exported by the corebluethoot framework
typedef NS_ENUM(NSInteger, W2STSDKBLeAdvertiseAddressType) {
    W2STSDKBLeAdvertiseAddressType_PUBLIC,
    W2STSDKBLeAdvertiseAddressType_RANDOM,
    W2STSDKBLeAdvertiseAddressType_UNKNOW
};
*/

/**
 *  class that parse the ble advertise package
 */
@interface W2STSDKBleAdvertiseParser : NSObject

//@property (readonly) W2STSDKBLeAdvertiseAddressType type; //not present in the dictionary advertise
//@property (readonly) NSString *address; //not present in the dictionary advertise

/**
 *  board name
 */
@property (readonly) NSString *name;

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