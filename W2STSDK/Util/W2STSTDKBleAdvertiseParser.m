//
//  W2STSTDKBleAdvertiseParser.m
//  W2STApp
//
//  Created by Giovanni Visentini on 25/03/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CBAdvertisementData.h>
#import "W2STSDKBleAdvertiseParser.h"
#import "NSData+NumberConversion.h"


@interface W2STSDKBleAdvertiseParser()

-(W2STSDKNodeType) getNodeType:(unsigned char) type;

@end

@implementation W2STSDKBleAdvertiseParser

-(W2STSDKNodeType) getNodeType:(unsigned char) type {
    if (type==0x00)
        return W2STSDKNodeTypeGeneric;
    if (type == 0x01)
        return W2STSDKNodeTypeWeSU;
    if (type == 0x02)
        return W2STSDKNodeTypeL1_Discovery;
    if (type >= 0x80 && type < 0xff)
        return W2STSDKNodeTypeNucleo;
    else
        @throw [NSException
                exceptionWithName:@"Invalid Manufactured data"
                reason:@"Invalid Node Type"
                userInfo:nil];
}

-(id)initWithAdvertise:(NSDictionary *)advertisementData{
    _name = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    _txPower = [advertisementData objectForKey:CBAdvertisementDataTxPowerLevelKey];
    NSData *rawData = [advertisementData objectForKey:CBAdvertisementDataManufacturerDataKey];
    if([rawData length]!=5)
        @throw [NSException
                exceptionWithName:@"Invalid Manufactured data"
                reason:@"Manufactured data must be 5byte"
                userInfo:nil];
    //else
    _deviceId = *((unsigned char*)rawData.bytes);
    _nodeType = [self getNodeType: _deviceId];
    _featureMap = [rawData extractBeUInt32FromOffset:1];
    return self;
}

-(NSDictionary*) featureMaskMap{
    id temp = [NSNumber numberWithUnsignedChar: _deviceId];
    return [[W2STSDKBoardFeatureMap boardFeatureMap] objectForKey:temp];
}

@end