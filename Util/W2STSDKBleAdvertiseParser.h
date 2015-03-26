//
//  BleAdvertiseParser.h
//  W2STApp
//
//  Created by Giovanni Visentini on 25/03/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#ifndef W2STApp_BleAdvertiseParser_h
#define W2STApp_BleAdvertiseParser_h

#import "../W2STSDKNode.h"

typedef NS_ENUM(NSInteger, W2STSDKBLeAdvertiseAddressType) {
    W2STSDKBLeAdvertiseAddressType_PUBLIC,
    W2STSDKBLeAdvertiseAddressType_RANDOM,
    W2STSDKBLeAdvertiseAddressType_UNKNOW
};

@interface W2STSDKBleAdvertiseParser : NSObject

//@property (readonly) W2STSDKBLeAdvertiseAddressType type; //not present in the dictionary advertise
//@property (readonly) NSString *address; //not present in the dictionary advertise

@property (readonly) NSString *name;
@property (readonly) unsigned char deviceId;
@property (readonly) unsigned int featureMap;
@property (readonly) NSNumber* txPower;
@property (readonly) W2STSDKNodeType nodeType;

-(id)initWithAdvertise:(NSDictionary*)advertisementData;



@end

#endif
