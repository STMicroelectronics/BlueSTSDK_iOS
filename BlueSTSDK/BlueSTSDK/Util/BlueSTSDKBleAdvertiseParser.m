//
//  W2STSTDKBleAdvertiseParser.m
//  W2STApp
//
//  Created by Giovanni Visentini on 25/03/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CBAdvertisementData.h>
#import "BlueSTSDKManager_prv.h"
#import "BlueSTSDKBleAdvertiseParser.h"
#import "NSData+NumberConversion.h"


#define PROTOCOL_VERSION_CURRENT 0x01
#define PROTOCOL_VERSION_CURRENT_MIN 0x01
#define PROTOCOL_VERSION_NOT_AVAILABLE 0xFF

#define DEVICE_ID_GENERIC 0x00
#define DEVICE_ID_WESU 0x01
#define DEVICE_ID_L1DISCO 0x02
#define DEVICE_ID_NUCLEO_BIT 0x80

#define ADVERTISE_SIZE_COMPACT 6
#define ADVERTISE_SIZE_FULL 12
#define ADVERTISE_MAX_SIZE 20

#define ADVERTISE_FIELD_POS_PROTOCOL 0
#define ADVERTISE_FIELD_POS_DEVICE_ID 1
#define ADVERTISE_FIELD_POS_FEATURE_MAP 2
#define ADVERTISE_FIELD_POS_ADDRESS 6

#define ADVERTISE_FIELD_SIZE_ADDRESS 6
@implementation BlueSTSDKBleAdvertiseParser


/**
 *  convert an uint8_t into a BlueSTSDKNodeType value
 *
 *  @param type board type number
 *
 *  @return equivalent type in the BlueSTSDKNodeType or an exception is the input is
 *  a valid type
 */
-(BlueSTSDKNodeType) getNodeType:(uint8_t) type {
    BlueSTSDKNodeType nodetype = BlueSTSDKNodeTypeGeneric;
    if (type==DEVICE_ID_GENERIC)
        nodetype = BlueSTSDKNodeTypeGeneric;
    else if (type == DEVICE_ID_WESU)
        nodetype =  BlueSTSDKNodeTypeWeSU;
    else if (type == DEVICE_ID_L1DISCO)
        nodetype =  BlueSTSDKNodeTypeL1_Discovery;
    else if ((type & DEVICE_ID_NUCLEO_BIT) == DEVICE_ID_NUCLEO_BIT)
        nodetype =  BlueSTSDKNodeTypeNucleo;
    else
        @throw [NSException
                exceptionWithName:@"Invalid Manufactured data"
                reason:@"Invalid Node Type"
                userInfo:nil];
    return nodetype;
}

+(instancetype)advertiseParserWithAdvertise:(NSDictionary *)advertisementData {
    return [[BlueSTSDKBleAdvertiseParser alloc] initWithAdvertise:advertisementData];
}


-(instancetype)initWithAdvertise:(NSDictionary *)advertisementData{
    _name = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    _txPower = [advertisementData objectForKey:CBAdvertisementDataTxPowerLevelKey];
    NSData *rawData = [advertisementData objectForKey:CBAdvertisementDataManufacturerDataKey];
    const NSInteger len = [rawData length];
    
    if(len != ADVERTISE_SIZE_COMPACT && len != ADVERTISE_SIZE_FULL)
        @throw [NSException
                exceptionWithName:@"Invalid Manufactured data"
                reason:[NSString stringWithFormat:@"Manufactured data must be %d bytes or %d byte",
                            ADVERTISE_SIZE_COMPACT, ADVERTISE_SIZE_FULL]
                userInfo:nil];

    //set the default value
    _featureMap = 0x00;
    _protocolVersion = PROTOCOL_VERSION_NOT_AVAILABLE;
    _address = nil;
    _deviceId = DEVICE_ID_GENERIC;
    _nodeType = [self getNodeType: _deviceId];
    
    //start to fill the value with the extracted values
    
    _protocolVersion = [rawData extractUInt8FromOffset:ADVERTISE_FIELD_POS_PROTOCOL];
    
    if(!(_protocolVersion >= PROTOCOL_VERSION_CURRENT_MIN && _protocolVersion <= PROTOCOL_VERSION_CURRENT))
        @throw [NSException
                exceptionWithName:@"Invalid Protocol version"
                reason:[NSString stringWithFormat:@"Supported protocol version are from %d to %d",
                        PROTOCOL_VERSION_CURRENT_MIN, PROTOCOL_VERSION_CURRENT]
                userInfo:nil];
    
    _deviceId = [rawData extractUInt8FromOffset:ADVERTISE_FIELD_POS_DEVICE_ID];
    _nodeType = [self getNodeType: _deviceId];
    _featureMap = [rawData extractBeUInt32FromOffset:ADVERTISE_FIELD_POS_FEATURE_MAP];
    
    
    if (len == ADVERTISE_SIZE_FULL) {
        _address = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                    [rawData extractUInt8FromOffset:ADVERTISE_FIELD_SIZE_ADDRESS+5],
                    [rawData extractUInt8FromOffset:ADVERTISE_FIELD_SIZE_ADDRESS+4],
                    [rawData extractUInt8FromOffset:ADVERTISE_FIELD_SIZE_ADDRESS+3],
                    [rawData extractUInt8FromOffset:ADVERTISE_FIELD_SIZE_ADDRESS+2],
                    [rawData extractUInt8FromOffset:ADVERTISE_FIELD_SIZE_ADDRESS+1],
                    [rawData extractUInt8FromOffset:ADVERTISE_FIELD_SIZE_ADDRESS+0]
                    ];
    }//if len check
    
    return self;
}

@end
