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

#import "BlueSTSDKFeature_prv.h"
#import "BlueSTSDKFeatureBattery.h"
#import "BlueSTSDKFeatureField.h"
#import "BlueSTSDK_LocalizeUtil.h"

#import "../Util/NSData+NumberConversion.h"

#define FEATURE_NAME BLUESTSDK_LOCALIZE(@"Battery",nil)

#define FEATURE_LEVEL_NAME BLUESTSDK_LOCALIZE(@"Level",nil)
#define FEATURE_LEVEL_UNIT @"%"
#define FEATURE_LEVEL_MAX @100
#define FEATURE_LEVEL_MIN @0

#define FEATURE_VOLTAGE_NAME BLUESTSDK_LOCALIZE(@"Voltage",nil)
#define FEATURE_VOLTAGE_UNIT @"V"
#define FEATURE_VOLTAGE_MAX @-10
#define FEATURE_VOLTAGE_MIN @10

#define FEATURE_CURRENT_NAME BLUESTSDK_LOCALIZE(@"Current",nil)
#define FEATURE_CURRENT_UNIT @"mA"
#define FEATURE_CURRENT_MAX @-10
#define FEATURE_CURRENT_MIN @10

#define FEATURE_STATUS_NAME BLUESTSDK_LOCALIZE(@"Status",nil)
#define FEATURE_STATUS_UNIT nil
#define FEATURE_STATIS_MAX @0xFF
#define FEATURE_STATUS_MIN @0


#define COMMAND_GET_BATTERY_CAPACITY 0x01

#define COMMAND_GET_MAX_ASSORBED_CURRENT 0x02

#define UNKNOW_CURRENT_VALUE ((int16_t)(0x8000))

/**
 *  queue used for notify things to the delegate
 */
static dispatch_queue_t sNotificationQueue;

/**
 * @memberof BlueSTSDKFeatureBattery
 *  array with the description of field exported by the feature
 */
static NSArray<BlueSTSDKFeatureField*> *sFieldDesc;

@implementation BlueSTSDKFeatureBattery{
    NSMutableSet<id<BlueSTSDKFeatureBatteryDelegate>> *mFeatureBatteryDelegates;
}

+(void)initialize{
    if(self == [BlueSTSDKFeatureBattery class]){
        sFieldDesc = @[[BlueSTSDKFeatureField createWithName:FEATURE_LEVEL_NAME
                                                        unit:FEATURE_LEVEL_UNIT
                                                        type:BlueSTSDKFeatureFieldTypeFloat
                                                         min:FEATURE_LEVEL_MIN
                                                         max:FEATURE_LEVEL_MAX],
                [BlueSTSDKFeatureField createWithName:FEATURE_VOLTAGE_NAME
                                                 unit:FEATURE_VOLTAGE_UNIT
                                                 type:BlueSTSDKFeatureFieldTypeFloat
                                                  min:FEATURE_VOLTAGE_MAX
                                                  max:FEATURE_VOLTAGE_MIN],
                [BlueSTSDKFeatureField createWithName:FEATURE_CURRENT_NAME
                                                 unit:FEATURE_CURRENT_UNIT
                                                 type:BlueSTSDKFeatureFieldTypeFloat
                                                  min:FEATURE_CURRENT_MAX
                                                  max:FEATURE_CURRENT_MIN],
                [BlueSTSDKFeatureField createWithName:FEATURE_STATUS_NAME
                                                 unit:FEATURE_STATUS_UNIT
                                                 type:BlueSTSDKFeatureFieldTypeUInt8
                                                  min:FEATURE_STATIS_MAX
                                                  max:FEATURE_STATUS_MIN]];
    }//if
}//initialize



+(BlueSTSDKFeatureBatteryStatus)getBatteryStatus:(BlueSTSDKFeatureSample*)sample{
    if(sample.data.count<3)
        return NAN;
    switch([[sample.data objectAtIndex:3] unsignedCharValue]){
        case 0x00:
            return BlueSTSDKFeatureBatteryStatusLowBattery;
        case 0x01:
            return BlueSTSDKFeatureBatteryStatusDischarging;
        case 0x02:
            return BlueSTSDKFeatureBatteryStatusPluggedNotCharging;
        case 0x03:
            return BlueSTSDKFeatureBatteryStatusCharging;
        case 0x04:
            return BlueSTSDKFeatureBatteryStatusUnknown;
        case 0xFF:
            return BlueSTSDKFeatureBatteryStatusError;
        default:
            return BlueSTSDKFeatureBatteryStatusError;
    }
}

+(NSString*)getBatteryStatusStr:(BlueSTSDKFeatureSample*)sample{
    switch ([BlueSTSDKFeatureBattery getBatteryStatus:sample]){
        case BlueSTSDKFeatureBatteryStatusLowBattery:
            return BLUESTSDK_LOCALIZE(@"Low battery",nil);
        case BlueSTSDKFeatureBatteryStatusDischarging:
            return BLUESTSDK_LOCALIZE(@"Discharging",nil);
        case BlueSTSDKFeatureBatteryStatusPluggedNotCharging:
            return BLUESTSDK_LOCALIZE(@"Plugged",nil);
        case BlueSTSDKFeatureBatteryStatusCharging:
            return BLUESTSDK_LOCALIZE(@"Charging",nil);
        case BlueSTSDKFeatureBatteryStatusUnknown:
            return BLUESTSDK_LOCALIZE(@"Unknown",nil);
        case BlueSTSDKFeatureBatteryStatusError:
            return BLUESTSDK_LOCALIZE(@"Error",nil);
    }//switch
}//getBatteryStatusStr


+(float)getBatteryLevel:(BlueSTSDKFeatureSample*)sample{
    if(sample.data.count==0)
        return NAN;
    return[[sample.data objectAtIndex:0] floatValue];
}

+(float)getBatteryVoltage:(BlueSTSDKFeatureSample*)sample{
    if(sample.data.count<1)
        return NAN;
    return [[sample.data objectAtIndex:1] floatValue];
}

+(float)getBatteryCurrent:(BlueSTSDKFeatureSample*)sample{
    if(sample.data.count<2)
        return NAN;
    return [[sample.data objectAtIndex:2] floatValue];
}


-(instancetype) initWhitNode:(BlueSTSDKNode *)node{
    self = [super initWhitNode:node name:FEATURE_NAME];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sNotificationQueue = dispatch_queue_create("BlueSTSDKFeatureBattery",
                                                   DISPATCH_QUEUE_CONCURRENT);
    });
    mFeatureBatteryDelegates = [NSMutableSet set];
    return self;
}

-(NSArray<BlueSTSDKFeatureField*>*) getFieldsDesc{
    return sFieldDesc;
}


 /**
 * the most significative bit in the staus tell us if the current has an high resolution or not
 * @param status battery status
 * @return true if the  MSB is 1 -> we use high precision current, false otherwise
 */
static bool hasHeightResolutionCurrent(uint8_t status){
    return (status & 0x80)!=0;
}

static bool hasUnknownCurrent(int16_t current){
    return current == UNKNOW_CURRENT_VALUE;
}

/***
 * remove the most MSB for extract only the battery status value
 * @param status battery status
 * @return the status with the MSB set to 0
 */
static uint8_t getBatteryStatus(uint8_t status){
    return (status & 0x7F);
}

-(void) addBatteryDelegate:(id<BlueSTSDKFeatureBatteryDelegate>)delegate{
    [mFeatureBatteryDelegates addObject:delegate];
}

-(void) removeBatteryDelegate:(id<BlueSTSDKFeatureBatteryDelegate>)delegate{
    [mFeatureBatteryDelegates removeObject:delegate];
}

/**
 * Send the command used for read the board battery capacity. The value will be notified with the
 * callback {@link FeatureBattery.FeatureBatteryListener#onCapacityRead(FeatureBattery, int)}
 * @return true if the command is correctly sent
 */
-(BOOL)readBatteryCapacity{
    return [super sendCommand:COMMAND_GET_BATTERY_CAPACITY data:[NSData data]];
}

/**
 * Send the command used for read the biggest current assorbed by the system.
 * The value will be notified with the callback
 * {@link FeatureBattery.FeatureBatteryListener#onMaxAssorbedCurrentRead(FeatureBattery, float)}
 * @return true if the command is correctly sent
 */
-(BOOL)readMaxAbsorbedCurrent{
    return [super sendCommand:COMMAND_GET_MAX_ASSORBED_CURRENT data:[NSData data]];
}

-(void)notifyBatteryCapacity:(uint16_t)capacity{
    for (id<BlueSTSDKFeatureBatteryDelegate> delegate in mFeatureBatteryDelegates) {
        if( [delegate respondsToSelector:@selector(didCapacityRead:capacity:)]){
            dispatch_async(sNotificationQueue, ^(){
                [delegate didCapacityRead: self capacity:capacity];
            });
        }//if
    }//for
}

-(void)notifyMaxAssorbedCurrent:(float)current{
    for (id<BlueSTSDKFeatureBatteryDelegate> delegate in mFeatureBatteryDelegates) {
        if( [delegate respondsToSelector:@selector(didMaxAssorbedCurrentRead:current:)]){
            dispatch_async(sNotificationQueue, ^(){
                [delegate didMaxAssorbedCurrentRead: self current:current];
            });
        }//if
    }//for
}


/**
 *  this function is called when the node rensponse to a command, for this feature
 * it extarct the status and call the correct delegate. if the status is 100 the
 * feature is considered configurated and the stop signal is send
 *
 *  @param timestamp   package id
 *  @param commandType command type
 *  @param data        command data
 */
-(void) parseCommandResponseWithTimestamp:(uint64_t)timestamp
                              commandType:(uint8_t)commandType
                                     data:(NSData*)data{
    if(commandType == COMMAND_GET_BATTERY_CAPACITY){
        uint16_t capacity = [data extractLeUInt16FromOffset:0];
        [self notifyBatteryCapacity:capacity];
        return;
    }
    if(commandType == COMMAND_GET_MAX_ASSORBED_CURRENT){
        float current = [data extractLeInt16FromOffset:0]/10.0f;
        [self notifyMaxAssorbedCurrent:current];
        return;
    }
    //if is an unknow command call the super method
    [super parseCommandResponseWithTimestamp:timestamp
                                 commandType:commandType
                                        data:data];
}//parseCommandResponseWithTimestamp

static float extractCurrent(int16_t current,bool hightRes){
    if(hasUnknownCurrent(current))
        return NAN;
    
    if(hightRes)
        return ((float)current)*0.1f;
    
    return current;
}

/**
*  read 3*int16+uint8 for build the battery value, create the new sample and
* and notify it to the delegate
*
*  @param timestamp data time stamp
*  @param rawData   array of byte send by the node
*  @param offset    offset where we have to start reading the data
*
*  @throw exception if there are no 7 bytes available in the rawdata array
 *  @return battery information + number of read bytes (7)
 */
-(BlueSTSDKExtractResult*) extractData:(uint64_t)timestamp data:(NSData*)rawData dataOffset:(uint32_t)offset{
    
    
    if(rawData.length-offset < 7){
        @throw [NSException
                exceptionWithName:BLUESTSDK_LOCALIZE(@"Invalid Battery data",nil)
                reason:BLUESTSDK_LOCALIZE(@"The feature need 7 byte for extract the data",nil)
                userInfo:nil];
    }//if
    
    float percentage =  [rawData extractLeUInt16FromOffset:offset]/10.0f;
    //the data arrive in mV we store it in V
    float voltage = [rawData extractLeInt16FromOffset:offset+2]/1000.0f;
    int16_t tempCurrent = [rawData extractLeInt16FromOffset:offset+4];
    
    
    uint8_t tempStatus = [rawData extractUInt8FromOffset:offset+6];
    
    float current = extractCurrent(tempCurrent,hasHeightResolutionCurrent(tempStatus));
        
    NSArray *data = @[@(percentage), @(voltage), @(current),
                      @(getBatteryStatus(tempStatus))];
    
    BlueSTSDKFeatureSample *sample = [BlueSTSDKFeatureSample sampleWithTimestamp:timestamp data:data ];
    return [BlueSTSDKExtractResult resutlWithSample:sample nReadData:7];
}

@end


#import "../BlueSTSDKFeature+fake.h"

@implementation BlueSTSDKFeatureBattery (fake)

-(NSData*) generateFakeData{
    NSMutableData *data = [NSMutableData dataWithCapacity:7];
    
    int16_t temp = rand()%1000;
    [data appendBytes:&temp length:2];
    
    temp = rand()%10000;
    [data appendBytes:&temp length:2];
    
    temp = rand()%10;
    [data appendBytes:&temp length:2];
    
    uint8_t state= rand()%4;
    [data appendBytes:&state length:1];
    return data;
}

@end

