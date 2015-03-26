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

@property (readonly, nonatomic) W2STSDKBLeAdvertiseAddressType type;
@property (readonly, retain, nonatomic) NSString *address;
@property (readonly, retain, nonatomic) NSString *name;
@property (readonly,  nonatomic) unsigned char deviceId;
@property (readonly,  nonatomic) unsigned int featureMap;
@property (readonly,  nonatomic) unsigned char txPower;
@property (readonly,  nonatomic) W2STSDKNodeType nodeType;

-(id)initWithAdvertise:(NSDictionary*)advertisementData;



@end

#endif
