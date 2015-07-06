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

-(id)initWithAdvertise:(NSDictionary *)advertisementData{
    _name = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    _txPower = [advertisementData objectForKey:CBAdvertisementDataTxPowerLevelKey];
    NSData *rawData = [advertisementData objectForKey:CBAdvertisementDataManufacturerDataKey];
    NSInteger len = [rawData length];
    
    if(len != ADVERTISE_SIZE_COMPACT && len != ADVERTISE_SIZE_FULL)
        @throw [NSException
                exceptionWithName:@"Invalid Manufactured data"
                reason:[NSString stringWithFormat:@"Manufactured data must be %d bytes or %d byte", ADVERTISE_SIZE_COMPACT, ADVERTISE_SIZE_FULL]
                userInfo:nil];
    //else
    unsigned char buffer[ADVERTISE_MAX_SIZE];
    [rawData getBytes:buffer length:rawData.length];
    _protocolVersion = buffer[ADVERTISE_FIELD_POS_PROTOCOL];
    _deviceId = buffer[ADVERTISE_FIELD_POS_DEVICE_ID];
    _nodeType = [self getNodeType: _deviceId];
    _featureMap = [rawData extractBeUInt32FromOffset:ADVERTISE_FIELD_POS_FEATURE_MAP];

    _address = @"";
    if (len == ADVERTISE_SIZE_FULL) {
        NSMutableString * locaddress = [NSMutableString stringWithString:@""];
        for(int i = ADVERTISE_FIELD_SIZE_ADDRESS - 1; i >= 0; i--)
        {
            NSInteger n = buffer[ADVERTISE_FIELD_POS_ADDRESS + i];
            [locaddress appendString:[NSString stringWithFormat:(i == 0 ? @"%02X" : @"%02X:"), (unsigned char)n]];
        }
        _address = locaddress;
    }
        
    return self;
}

-(NSDictionary*) featureMaskMap{
    id temp = [NSNumber numberWithUnsignedChar: _deviceId];
    return [[W2STSDKBoardFeatureMap boardFeatureMap] objectForKey:temp];
}

@end