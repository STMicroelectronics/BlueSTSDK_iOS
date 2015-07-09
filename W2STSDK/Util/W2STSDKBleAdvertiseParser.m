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

@end

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
+(id)advertiseParserWithAdvertise:(NSDictionary *)advertisementData {
    return [[W2STSDKBleAdvertiseParser alloc] initWithAdvertise:advertisementData];
}

-(id)initWithAdvertise:(NSDictionary *)advertisementData{
    _name = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    _txPower = [advertisementData objectForKey:CBAdvertisementDataTxPowerLevelKey];
    NSData *rawData = [advertisementData objectForKey:CBAdvertisementDataManufacturerDataKey];
    const NSInteger len = [rawData length];
    
    //AR Changed to allow to show also the not supported boards
    //    if(len != ADVERTISE_SIZE_COMPACT && len != ADVERTISE_SIZE_FULL)
    //        @throw [NSException
    //                exceptionWithName:@"Invalid Manufactured data"
    //                reason:[NSString stringWithFormat:@"Manufactured data must be %d bytes or %d byte", ADVERTISE_SIZE_COMPACT, ADVERTISE_SIZE_FULL]
    //                userInfo:nil];

    //initialization
    _featureMap = 0x00;
    _protocolVersion = PROTOCOL_VERSION_NOT_AVAILABLE;
    _address = nil;
    _deviceId = DEVICE_ID_GENERIC;
    _nodeType = [self getNodeType: _deviceId];
    
    //check the size and otherwise check if a legacy version
    if (len != ADVERTISE_SIZE_COMPACT && len != ADVERTISE_SIZE_FULL)
    {
        if (len == ADVERTISE_SIZE_LEGACY1)
        {
            _protocolVersion = PROTOCOL_VERSION_LEGACY1;
        }
        else if (len == ADVERTISE_SIZE_LEGACY2)
        {
            _protocolVersion = PROTOCOL_VERSION_LEGACY1;
        }
        return self;
    }

    _protocolVersion = [rawData extractUInt8FromOffset:ADVERTISE_FIELD_POS_PROTOCOL];
    if ([W2STSDKNode checkProtocolVersion:_protocolVersion]) {
        _deviceId = [rawData extractUInt8FromOffset:ADVERTISE_FIELD_POS_DEVICE_ID];
        _nodeType = [self getNodeType: _deviceId];
        _featureMap = [rawData extractBeUInt32FromOffset:ADVERTISE_FIELD_POS_FEATURE_MAP];
        
        if (len == ADVERTISE_SIZE_FULL) {
            _address = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                        [rawData extractUInt8FromOffset:ADVERTISE_FIELD_SIZE_ADDRESS+0],
                        [rawData extractUInt8FromOffset:ADVERTISE_FIELD_SIZE_ADDRESS+1],
                        [rawData extractUInt8FromOffset:ADVERTISE_FIELD_SIZE_ADDRESS+2],
                        [rawData extractUInt8FromOffset:ADVERTISE_FIELD_SIZE_ADDRESS+3],
                        [rawData extractUInt8FromOffset:ADVERTISE_FIELD_SIZE_ADDRESS+4],
                        [rawData extractUInt8FromOffset:ADVERTISE_FIELD_SIZE_ADDRESS+5]
                        ];
        }//if len check
    }//if protocol check
    
    return self;
}

-(NSDictionary*) featureMaskMap{
    id temp = [NSNumber numberWithUnsignedChar: _deviceId];
    return [[W2STSDKBoardFeatureMap boardFeatureMap] objectForKey:temp];
}

@end