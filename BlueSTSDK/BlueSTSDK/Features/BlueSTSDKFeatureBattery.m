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

#import "../Util/NSData+NumberConversion.h"

#define FEATURE_NAME @"Battery"

#define FEATURE_LEVEL_NAME @"Level"
#define FEATURE_LEVEL_UNIT @"%"
#define FEATURE_LEVEL_MAX @100
#define FEATURE_LEVEL_MIN @0

#define FEATURE_VOLTAGE_NAME @"Voltage"
#define FEATURE_VOLTAGE_UNIT @"V"
#define FEATURE_VOLTAGE_MAX @-10
#define FEATURE_VOLTAGE_MIN @10

#define FEATURE_CURRENT_NAME @"Current"
#define FEATURE_CURRENT_UNIT @"mA"
#define FEATURE_CURRENT_MAX @-10
#define FEATURE_CURRENT_MIN @10

#define FEATURE_STATUS_NAME @"Status"
#define FEATURE_STATUS_UNIT @""
#define FEATURE_STATIS_MAX @0xFF
#define FEATURE_STATUS_MIN @0

/**
 * @memberof BlueSTSDKFeatureBattery
 *  array with the description of field exported by the feature
 */
static NSArray *sFieldDesc;

@implementation BlueSTSDKFeatureBattery

+(void)initialize{
    if(self == [BlueSTSDKFeatureBattery class]){
        sFieldDesc = [NSArray arrayWithObjects:
                      [BlueSTSDKFeatureField  createWithName:FEATURE_LEVEL_NAME
                                                      unit:FEATURE_LEVEL_UNIT
                                                      type:BlueSTSDKFeatureFieldTypeFloat
                                                       min:FEATURE_LEVEL_MIN
                                                       max:FEATURE_LEVEL_MAX ],
                      [BlueSTSDKFeatureField  createWithName:FEATURE_VOLTAGE_NAME
                                                      unit:FEATURE_VOLTAGE_UNIT
                                                      type:BlueSTSDKFeatureFieldTypeFloat
                                                       min:FEATURE_VOLTAGE_MAX
                                                       max:FEATURE_VOLTAGE_MIN ],
                      [BlueSTSDKFeatureField  createWithName:FEATURE_CURRENT_NAME
                                                      unit:FEATURE_CURRENT_UNIT
                                                      type:BlueSTSDKFeatureFieldTypeFloat
                                                       min:FEATURE_CURRENT_MAX
                                                       max:FEATURE_CURRENT_MIN ],
                      [BlueSTSDKFeatureField  createWithName:FEATURE_STATUS_NAME
                                                      unit:FEATURE_STATUS_UNIT
                                                      type:BlueSTSDKFeatureFieldTypeUInt8
                                                       min:FEATURE_STATIS_MAX
                                                       max:FEATURE_STATUS_MIN ],
                      nil];
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
        case 0xFF:
            return BlueSTSDKFeatureBatteryStatusError;
        default:
            return BlueSTSDKFeatureBatteryStatusError;
    }
}

+(NSString*)getBatteryStatusStr:(BlueSTSDKFeatureSample*)sample{
    switch ([BlueSTSDKFeatureBattery getBatteryStatus:sample]){
        case BlueSTSDKFeatureBatteryStatusLowBattery:
            return @"Low battery";
        case BlueSTSDKFeatureBatteryStatusDischarging:
            return @"Discharging";
        case BlueSTSDKFeatureBatteryStatusPluggedNotCharging:
            return @"Plugged";
        case BlueSTSDKFeatureBatteryStatusCharging:
            return @"Charging";
        case BlueSTSDKFeatureBatteryStatusError:
            return @"Error";
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
    return self;
}

-(NSArray*) getFieldsDesc{
    return sFieldDesc;
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
*  @return number of read bytes
*/
-(BlueSTSDKExtractResult*) update:(uint32_t)timestamp data:(NSData*)rawData dataOffset:(uint32_t)offset{
    
    
    if(rawData.length-offset < 7){
        @throw [NSException
                exceptionWithName:@"Invalid Battery data"
                reason:@"The feature need 7 byte for extract the data"
                userInfo:nil];
    }//if
    
    float percentage =  [rawData extractLeUInt16FromOffset:offset]/10.0f;
    //the data arrive in mV we store it in V
    float voltage = [rawData extractLeInt16FromOffset:offset+2]/1000.0f;
    float current = [rawData extractLeInt16FromOffset:offset+4];
    uint8_t status = [rawData extractUInt8FromOffset:offset+6];
    
    
    NSArray *data = [NSArray arrayWithObjects:
                     [NSNumber numberWithFloat:percentage],
                     [NSNumber numberWithFloat:voltage],
                     [NSNumber numberWithFloat:current],
                     [NSNumber numberWithUnsignedChar:status],
                     nil];
    
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

