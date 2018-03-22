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

#import <limits.h>

#import "BlueSTSDKFeature_prv.h"
#import "BlueSTSDKFeatureField.h"
#import "BlueSTSDKFeatureAccelerometerEvent.h"
#import "BlueSTSDK_LocalizeUtil.h"
#import "../Util/NSData+NumberConversion.h"

#define FEATURE_UNIT nil
#define FEATURE_MIN @0
#define FEATURE_MAX_EVENT @256
#define FEATURE_MAX_STEPS @(USHRT_MAX)
#define FEATURE_TYPE_EVENT BlueSTSDKFeatureFieldTypeUInt8
#define FEATURE_TYPE_STEPS BlueSTSDKFeatureFieldTypeUInt16

/**
 * @memberof BlueSTSDKFeatureAccelerometerEvent
 *  array with the description of field exported by the feature
 */
static NSArray<BlueSTSDKFeatureField*> *sFieldDesc;

/**
 *  @memberof BlueSTSDKFeatureAccelerometerEvent
 *  queue used for notify things to the delegate
 */
static dispatch_queue_t sNotificationQueue;
static const uint8_t ENABLE_COMMAND[] = {1};
static const uint8_t DISABLE_COMMAND[] = {0};
static NSData *sDisableCommand;
static NSData *sEnableCommand;
static NSArray *sDetectableEventTypeName;
static NSArray *sEventTypeName;


@implementation BlueSTSDKFeatureAccelerometerEvent{
    /**
     *  Set of delegate where notify the change on the confuguration
     */
    NSMutableSet *mFeatureEnableTypeDelegate;

    BOOL mIsPedometerEnabled;

}

+(void)initialize{
    if(self == [BlueSTSDKFeatureAccelerometerEvent class]){
        sEnableCommand = [NSData dataWithBytesNoCopy:(void*)&ENABLE_COMMAND
                                              length:sizeof(ENABLE_COMMAND)];
        sDisableCommand = [NSData dataWithBytesNoCopy:(void*)&DISABLE_COMMAND
                                              length:sizeof(DISABLE_COMMAND)];
        sFieldDesc = @[[BlueSTSDKFeatureField createWithName:BLUESTSDK_LOCALIZE(@"Event",nil)
                                                        unit:FEATURE_UNIT
                                                        type:FEATURE_TYPE_EVENT
                                                         min:FEATURE_MIN
                                                         max:FEATURE_MAX_EVENT],
                [BlueSTSDKFeatureField createWithName:BLUESTSDK_LOCALIZE(@"nSteps",nil)
                                                 unit:FEATURE_UNIT
                                                 type:FEATURE_TYPE_STEPS
                                                  min:FEATURE_MIN
                                                  max:FEATURE_MAX_STEPS]];
        
        sDetectableEventTypeName = @[BLUESTSDK_LOCALIZE(@"None",nil),
                                     BLUESTSDK_LOCALIZE(@"Orientation",nil),
                                     BLUESTSDK_LOCALIZE(@"Free Fall",nil),
                                     BLUESTSDK_LOCALIZE(@"Single Tap",nil),
                                     BLUESTSDK_LOCALIZE(@"Double Tap",nil),
                                     BLUESTSDK_LOCALIZE(@"Wake Up",nil),
                                     BLUESTSDK_LOCALIZE(@"Tilt",nil),
                                     BLUESTSDK_LOCALIZE(@"Pedometer",nil),
                                     BLUESTSDK_LOCALIZE(@"Multiple",nil)];
        
        sEventTypeName = @[BLUESTSDK_LOCALIZE(@"Orientation Top Left",nil),
                           BLUESTSDK_LOCALIZE(@"Orientation Top Right",nil),
                           BLUESTSDK_LOCALIZE(@"Orientation Bottom Left",nil),
                           BLUESTSDK_LOCALIZE(@"Orientation Bottom Right",nil),
                           BLUESTSDK_LOCALIZE(@"Orientation Up",nil),
                           BLUESTSDK_LOCALIZE(@"Orientation Down",nil),
                           BLUESTSDK_LOCALIZE(@"Tilt",nil),
                           BLUESTSDK_LOCALIZE(@"Free Fall",nil),
                           BLUESTSDK_LOCALIZE(@"Single Tap",nil),
                           BLUESTSDK_LOCALIZE(@"Double Tap",nil),
                           BLUESTSDK_LOCALIZE(@"Wake Up",nil),
                           BLUESTSDK_LOCALIZE(@"Pedometer",nil),
                           BLUESTSDK_LOCALIZE(@"No Event",nil),
                           BLUESTSDK_LOCALIZE(@"Error",nil)];
    }
    
}

-(instancetype) initWhitNode: (BlueSTSDKNode*)node{
    self = [super initWhitNode:node name: BLUESTSDK_LOCALIZE(@"Accelerometer Events",nil)];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sNotificationQueue = dispatch_queue_create("BlueSTSDKFeatureAccelerometerEvent",
                                                   DISPATCH_QUEUE_CONCURRENT);
    });
    
    mFeatureEnableTypeDelegate = [NSMutableSet set];
    mIsPedometerEnabled=false;
    _DEFAULT_ENABLED_EVENT=BlueSTSDKFeatureEventTypeMultiple;
    return self;
}

+(BlueSTSDKFeatureAccelerometerEventType)getAccelerationEvent:(BlueSTSDKFeatureSample*)sample{
    if(sample.data.count>0) {
        return (BlueSTSDKFeatureAccelerometerEventType)[sample.data[0] unsignedShortValue];
    }//if
    return BlueSTSDKFeatureAccelerometerError;
}

+(NSString*) detectableEventTypeToString:(BlueSTSDKFeatureAccelerationDetectableEventType)event{
    switch (event) {
        case BlueSTSDKFeatureEventTypeOrientation:
            return sDetectableEventTypeName[1];
        case BlueSTSDKFeatureEventTypeFreeFall:
            return sDetectableEventTypeName[2];
        case BlueSTSDKFeatureEventTypeSingleTap:
            return sDetectableEventTypeName[3];
        case BlueSTSDKFeatureEventTypeDoubleTap:
            return sDetectableEventTypeName[4];
        case BlueSTSDKFeatureEventTypeWakeUp:
            return sDetectableEventTypeName[5];
        case BlueSTSDKFeatureEventTypeTilt:
            return sDetectableEventTypeName[6];
        case BlueSTSDKFeatureEventTypePedometer:
            return sDetectableEventTypeName[7];
        case BlueSTSDKFeatureEventTypeMultiple:
            return sDetectableEventTypeName[8];
        case BlueSTSDKFeatureEventTypeNone:
        default:
            return sDetectableEventTypeName[0];
    }
}

+(NSString*) eventTypeToString:(BlueSTSDKFeatureAccelerometerEventType)event{
    switch (event) {
        case BlueSTSDKFeatureAccelerometerOrientationTopLeft:
            return sEventTypeName[0];
        case BlueSTSDKFeatureAccelerometerOrientationTopRight:
            return sEventTypeName[1];
        case BlueSTSDKFeatureAccelerometerOrientationBottomLeft:
            return sEventTypeName[2];
        case BlueSTSDKFeatureAccelerometerOrientationBottomRight:
            return sEventTypeName[3];
        case BlueSTSDKFeatureAccelerometerOrientationUp:
            return sEventTypeName[4];
        case BlueSTSDKFeatureAccelerometerOrientationDown:
            return sEventTypeName[5];
        case BlueSTSDKFeatureAccelerometerTilt:
            return sEventTypeName[6];
        case BlueSTSDKFeatureAccelerometerFreeFall:
            return sEventTypeName[7];
        case BlueSTSDKFeatureAccelerometerSingleTap:
            return sEventTypeName[8];
        case BlueSTSDKFeatureAccelerometerDoubleTap:
            return sEventTypeName[9];
        case BlueSTSDKFeatureAccelerometerWakeUp:
            return sEventTypeName[10];
        case BlueSTSDKFeatureAccelerometerPedometer:
            return sEventTypeName[11];
        case BlueSTSDKFeatureAccelerometerNoEvent:
            return sEventTypeName[12];
        case BlueSTSDKFeatureAccelerometerError:
        default:
            return sEventTypeName[13];
    }
}

+(BlueSTSDKFeatureAccelerometerEventType)extractOrientationEvent:(BlueSTSDKFeatureAccelerometerEventType)event{
    return event & 0x07;
}

+(int32_t) getPedometerSteps:(BlueSTSDKFeatureSample*)sample{
    if(sample.data.count>1){
        BlueSTSDKFeatureAccelerometerEventType eventType =
                [BlueSTSDKFeatureAccelerometerEvent getAccelerationEvent:sample];
        if ((eventType & BlueSTSDKFeatureAccelerometerPedometer)!=0) {
            return [sample.data[1] unsignedShortValue];
        }
    }
    return -1;
}

-(NSArray<BlueSTSDKFeatureField*>*) getFieldsDesc{
    return sFieldDesc;
}

/**
 *  notify to all the registered delegate that the configuration process starts
 */
-(void)notifyEventEnableChange: (BlueSTSDKFeatureAccelerationDetectableEventType)type newStatus:(BOOL)newStatus{
    for (id<BlueSTSDKFeatureAccelerationEnableTypeDelegate> delegate in mFeatureEnableTypeDelegate) {
        if( [delegate respondsToSelector:@selector(didTypeChangeStatus:type:newStatus:)]){
            dispatch_async(sNotificationQueue, ^(){
                [delegate didTypeChangeStatus: self type:type newStatus:newStatus];
            });
        }//if
    }//for
}

-(NSNumber*) enumToObject:(BlueSTSDKFeatureAccelerometerEventType)type{
    return @((uint16_t) type);
}

-(BOOL)enableEvent:(BlueSTSDKFeatureAccelerationDetectableEventType)type enable:(BOOL)enable{

    if(type == BlueSTSDKFeatureEventTypePedometer){
        mIsPedometerEnabled=enable;
    }

    if(type != BlueSTSDKFeatureEventTypeNone){
        return [self sendCommand:(uint8_t)type data: enable? sEnableCommand : sDisableCommand];
    }else{
        [self notifyEventEnableChange:BlueSTSDKFeatureEventTypeNone newStatus:true];
        return true;
    }
}

-(void) addFeatureAccelerationEnableTypeDelegate:(id<BlueSTSDKFeatureAccelerationEnableTypeDelegate>)delegate{
    [mFeatureEnableTypeDelegate addObject:delegate];
}

-(void) removeFeatureAccelerationEnableTypeDelegate:(id<BlueSTSDKFeatureAccelerationEnableTypeDelegate>)delegate{
    [mFeatureEnableTypeDelegate removeObject:delegate];
}

-(BlueSTSDKExtractResult*) extractPedometerData:(uint64_t)timestamp
                                           data:(NSData*)rawData
                                     dataOffset:(uint32_t)offset{
    if(rawData.length-offset < 2){
        @throw [NSException
                exceptionWithName:BLUESTSDK_LOCALIZE(@"Invalid Pedometer data",nil)
                reason:BLUESTSDK_LOCALIZE(@"The feature need almost 2 byte for extract the data",nil)
                userInfo:nil];
    }//if
    
    uint16_t nSteps= [rawData extractLeUInt16FromOffset:offset];
    
    NSArray *data = @[[self enumToObject:BlueSTSDKFeatureAccelerometerPedometer],
            [NSNumber numberWithUnsignedChar:nSteps]];
    
    BlueSTSDKFeatureSample *sample = [BlueSTSDKFeatureSample sampleWithTimestamp:timestamp data:data ];
    return [BlueSTSDKExtractResult resutlWithSample:sample nReadData:2];
    
}

-(BlueSTSDKExtractResult*) extractEventData:(uint64_t)timestamp
                                           data:(NSData*)rawData
                                     dataOffset:(uint32_t)offset{
    if(rawData.length-offset < 1){
        @throw [NSException
                exceptionWithName:BLUESTSDK_LOCALIZE(@"Invalid AccelerationEvent data",nil)
                reason:BLUESTSDK_LOCALIZE(@"The feature need almost 1 byte for extract the data",nil)
                userInfo:nil];
    }//if
    
    uint8_t eventId= [rawData extractUInt8FromOffset:offset] ;

    NSArray *data = @[@(eventId)];
    
    BlueSTSDKFeatureSample *sample = [BlueSTSDKFeatureSample sampleWithTimestamp:timestamp data:data ];
    return [BlueSTSDKExtractResult resutlWithSample:sample nReadData:1];
    
}


-(BlueSTSDKExtractResult*) extractEventAndPedomiterData:(uint64_t)timestamp
                                                   data:(NSData*)rawData
                                             dataOffset:(uint32_t)offset{
    
    if(rawData.length-offset < 3){
        @throw [NSException
                exceptionWithName:BLUESTSDK_LOCALIZE(@"Invalid AccelerationEvent data",nil)
                reason:BLUESTSDK_LOCALIZE(@"The feature need almost 3 byte for extract the data",nil)
                userInfo:nil];
    }//if
        
    uint16_t eventId= [rawData extractUInt8FromOffset:offset] | BlueSTSDKFeatureAccelerometerPedometer;
    uint16_t nSteps= [rawData extractLeUInt16FromOffset:offset+1];

    NSArray *data = @[@(eventId),@(nSteps)];
    
    BlueSTSDKFeatureSample *sample = [BlueSTSDKFeatureSample sampleWithTimestamp:timestamp data:data ];
    return [BlueSTSDKExtractResult resutlWithSample:sample nReadData:3];

    
}

/**
 *  read int8 for build the position value, create the new sample and
 * and notify it to the delegate
 *
 *  @param timestamp data time stamp
 *  @param rawData   array of byte send by the node
 *  @param offset    offset where we have to start reading the data
 *
 *  @throw exception if there are no byte available in the rawdata array
 *  @return carry position + number of read bytes (1)
 */
-(BlueSTSDKExtractResult*) extractData:(uint64_t)timestamp data:(NSData*)rawData dataOffset:(uint32_t)offset{
    
    const NSUInteger dataLength =rawData.length-offset;
    
    if(dataLength>=3)
        return [self extractEventAndPedomiterData:timestamp data:rawData dataOffset:offset];
    else if(dataLength>=2 && mIsPedometerEnabled){
        return [self extractPedometerData:timestamp data:rawData dataOffset:offset];
    }else
        return [self extractEventData:timestamp data:rawData dataOffset:offset];
    
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
    BOOL newStatus;
    [data getBytes:&newStatus length:1];
    BlueSTSDKFeatureAccelerationDetectableEventType event =
        (BlueSTSDKFeatureAccelerationDetectableEventType) commandType;
    
    [self notifyEventEnableChange:event
                        newStatus:newStatus];

}//parseCommandResponseWithTimestamp

@end


#import "../BlueSTSDKFeature+fake.h"

@implementation BlueSTSDKFeatureAccelerometerEvent(fake)

-(NSData*) generateFakeData{
    static BlueSTSDKFeatureAccelerometerEventType eventType[] ={
        
        BlueSTSDKFeatureAccelerometerOrientationTopLeft,
        BlueSTSDKFeatureAccelerometerOrientationTopRight,
        BlueSTSDKFeatureAccelerometerOrientationBottomLeft,
        BlueSTSDKFeatureAccelerometerOrientationBottomRight,
        BlueSTSDKFeatureAccelerometerOrientationUp,
        BlueSTSDKFeatureAccelerometerOrientationDown,
        BlueSTSDKFeatureAccelerometerTilt,
        BlueSTSDKFeatureAccelerometerFreeFall,
        BlueSTSDKFeatureAccelerometerSingleTap,
        BlueSTSDKFeatureAccelerometerDoubleTap,
        BlueSTSDKFeatureAccelerometerWakeUp,
        BlueSTSDKFeatureAccelerometerPedometer,
        BlueSTSDKFeatureAccelerometerError
        
    };
    uint8_t eventIndex =  rand()%(13);
    if(eventType[eventIndex]!=BlueSTSDKFeatureEventTypePedometer){
        NSMutableData *data = [NSMutableData dataWithCapacity:1];
        uint8_t eventId =(uint8_t)eventType[eventIndex];
        [data appendBytes:&eventId length:1];
        return data;
    }else{
        uint16_t nSteps =  rand()%(256);
        NSMutableData *data = [NSMutableData dataWithCapacity:2];
        [data appendBytes:&nSteps length:2];
        return data;
    }
}

@end
