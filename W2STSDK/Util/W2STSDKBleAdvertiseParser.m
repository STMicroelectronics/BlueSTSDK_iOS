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

@implementation W2STSDKBleAdvertiseParser


/**
 *  convert an uint8_t into a W2STSDKNodeType value
 *
 *  @param type board type number
 *
 *  @return equvalent type in the W2STSDKNodeType or an exception is the input is 
 *  a valid type
 */
-(W2STSDKNodeType) getNodeType:(uint8_t) type {
    W2STSDKNodeType nodetype = W2STSDKNodeTypeGeneric;
    if (type==DEVICE_ID_GENERIC)
        nodetype = W2STSDKNodeTypeGeneric;
    else if (type == DEVICE_ID_WESU)
        nodetype =  W2STSDKNodeTypeWeSU;
    else if (type == DEVICE_ID_L1DISCO)
        nodetype =  W2STSDKNodeTypeL1_Discovery;
    else if ((type & DEVICE_ID_NUCLEO_BIT) == DEVICE_ID_NUCLEO_BIT)
        nodetype =  W2STSDKNodeTypeNucleo;
    else
        @throw [NSException
                exceptionWithName:@"Invalid Manufactured data"
                reason:@"Invalid Node Type"
                userInfo:nil];
    return nodetype;
}

-(id)initWithAdvertise:(NSDictionary *)advertisementData{
    _name = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    _txPower = [advertisementData objectForKey:CBAdvertisementDataTxPowerLevelKey];
    NSData *rawData = [advertisementData objectForKey:CBAdvertisementDataManufacturerDataKey];
    const NSInteger len = [rawData length];
    
    if(len != ADVERTISE_SIZE_COMPACT && len != ADVERTISE_SIZE_FULL)
        @throw [NSException
                exceptionWithName:@"Invalid Manufactured data"
                reason:[NSString stringWithFormat:@"Manufactured data must be %d bytes or %d byte", ADVERTISE_SIZE_COMPACT, ADVERTISE_SIZE_FULL]
                userInfo:nil];
    //else
    _protocolVersion = [rawData extractUInt8FromOffset:ADVERTISE_FIELD_POS_PROTOCOL];
    _deviceId = [rawData extractUInt8FromOffset:ADVERTISE_FIELD_POS_DEVICE_ID];
    _nodeType = [self getNodeType: _deviceId];
    _featureMap = [rawData extractBeUInt32FromOffset:ADVERTISE_FIELD_POS_FEATURE_MAP];

    _address = nil;
    if (len == ADVERTISE_SIZE_FULL) {
        _address = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                        [rawData extractUInt8FromOffset:ADVERTISE_FIELD_SIZE_ADDRESS+0],
                        [rawData extractUInt8FromOffset:ADVERTISE_FIELD_SIZE_ADDRESS+1],
                        [rawData extractUInt8FromOffset:ADVERTISE_FIELD_SIZE_ADDRESS+2],
                        [rawData extractUInt8FromOffset:ADVERTISE_FIELD_SIZE_ADDRESS+3],
                        [rawData extractUInt8FromOffset:ADVERTISE_FIELD_SIZE_ADDRESS+4],
                        [rawData extractUInt8FromOffset:ADVERTISE_FIELD_SIZE_ADDRESS+5]
                    ];
    }//if
        
    return self;
}

-(NSDictionary*) featureMaskMap{
    id temp = [NSNumber numberWithUnsignedChar: _deviceId];
    return [[W2STSDKBoardFeatureMap boardFeatureMap] objectForKey:temp];
}

@end
