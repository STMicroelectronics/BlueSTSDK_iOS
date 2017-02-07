/*******************************************************************************
 * COPYRIGHT(c) 2015 STMicroelectronics
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *   1. Redistributions of source code must retain the above copyright notice,
 *      this list of conditions and the following disclaimer.
 *   2. Redistributions in binary form must reproduce the above copyright notice,
 *      this list of conditions and the following disclaimer in the documentation
 *      and/or other materials provided with the distribution.
 *   3. Neither the name of STMicroelectronics nor the names of its contributors
 *      may be used to endorse or promote products derived from this software
 *      without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 ******************************************************************************/

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CBAdvertisementData.h>
#import "BlueSTSDKManager_prv.h"
#import "BlueSTSDKBleAdvertiseParser.h"
#import "NSData+NumberConversion.h"


#define PROTOCOL_VERSION_CURRENT 0x01
#define PROTOCOL_VERSION_CURRENT_MIN 0x01
#define PROTOCOL_VERSION_NOT_AVAILABLE 0xFF

#define NODE_ID_GENERIC 0x00
#define NODE_ID_STEVAL_WESU1 0x01
#define NODE_ID_SENSOR_TILE 0x02
#define NODE_ID_BLUE_COIN 0x03
#define NODE_ID_NUCLEO_BIT 0x80
#define NODE_ID_IS_SLEEPING_BIT 0x40
#define NODE_ID_HAS_EXTENSION_BIT 0x20

#define ADVERTISE_SIZE_COMPACT 6
#define ADVERTISE_SIZE_FULL 12
#define ADVERTISE_MAX_SIZE 20

#define ADVERTISE_FIELD_POS_PROTOCOL 0
#define ADVERTISE_FIELD_POS_NODE_ID 1
#define ADVERTISE_FIELD_POS_FEATURE_MAP 2
#define ADVERTISE_FIELD_POS_ADDRESS 6

#define ADVERTISE_FIELD_SIZE_ADDRESS 6

static uint8_t extractNodeType(uint8_t type){
    if(type & NODE_ID_NUCLEO_BIT)
        return type;
    else
        return type &(0x1F);
}

static BOOL extractIsSleepingBit(uint8_t type){
    if(type & NODE_ID_NUCLEO_BIT)
        return false;
    else
        return (type & NODE_ID_IS_SLEEPING_BIT)!=0;
}

static BOOL extractHasExtensionBit(uint8_t type){
    if(type & NODE_ID_NUCLEO_BIT)
        return false;
    else
        return (type & NODE_ID_HAS_EXTENSION_BIT)!=0;
}

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
    if(![BlueSTSDKManager.sharedInstance isValidNodeId:type])
        @throw [NSException
                exceptionWithName:@"Invalid Manufactured data"
                reason:@"Invalid Node Type"
                userInfo:nil];
   
    if (type == NODE_ID_STEVAL_WESU1)
        nodetype =  BlueSTSDKNodeTypeSTEVAL_WESU1;
    else if(type == NODE_ID_SENSOR_TILE)
        nodetype = BlueSTSDKNodeTypeSensor_Tile;
    else if(type == NODE_ID_BLUE_COIN)
        nodetype = BlueSTSDKNodeTypeBlue_Coin;
    else if ((type & NODE_ID_NUCLEO_BIT) == NODE_ID_NUCLEO_BIT)
        nodetype =  BlueSTSDKNodeTypeNucleo;
    
    return nodetype;
}

+(instancetype)advertiseParserWithAdvertise:(NSDictionary *)advertisementData {
    return [[BlueSTSDKBleAdvertiseParser alloc] initWithAdvertise:advertisementData];
}


-(instancetype)initWithAdvertise:(NSDictionary *)advertisementData{
    _name = advertisementData[CBAdvertisementDataLocalNameKey];
    _txPower = advertisementData[CBAdvertisementDataTxPowerLevelKey];
    NSData *rawData = advertisementData[CBAdvertisementDataManufacturerDataKey];
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
    _nodeId = NODE_ID_GENERIC;
    _nodeType = [self getNodeType: _nodeId];
    
    //start to fill the value with the extracted values
    
    _protocolVersion = [rawData extractUInt8FromOffset:ADVERTISE_FIELD_POS_PROTOCOL];
    
    if(!(_protocolVersion >= PROTOCOL_VERSION_CURRENT_MIN && _protocolVersion <= PROTOCOL_VERSION_CURRENT))
        @throw [NSException
                exceptionWithName:@"Invalid Protocol version"
                reason:[NSString stringWithFormat:@"Supported protocol version are from %d to %d",
                        PROTOCOL_VERSION_CURRENT_MIN, PROTOCOL_VERSION_CURRENT]
                userInfo:nil];
    
    uint8_t typeId =[rawData extractUInt8FromOffset:ADVERTISE_FIELD_POS_NODE_ID];
    _nodeId = extractNodeType(typeId);
    _isSleeping = extractIsSleepingBit(typeId);
    _hasExtension = extractHasExtensionBit(typeId);
    
    _nodeType = [self getNodeType: _nodeId];
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
