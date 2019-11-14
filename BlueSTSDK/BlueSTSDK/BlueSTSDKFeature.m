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

#import "BlueSTSDKNode_prv.h"
#import "BlueSTSDKFeature_prv.h"
#import "BlueSTSDKFeatureField.h"
#import "BlueSTSDK_LocalizeUtil.h"

@interface BlueSTSDKFeature()
//@property (readwrite,atomic) BlueSTSDKFeatureSample *lastSample;
@end


@implementation BlueSTSDKFeatureSample

+(instancetype) sampleWithTimestamp:(uint64_t)timestamp data:(NSArray<NSNumber*> *)data{
    return [[BlueSTSDKFeatureSample alloc] initWhitTimestamp: timestamp data:data];
}

+(instancetype) sampleWithData:(NSArray<NSNumber*> *)data{
    return [[BlueSTSDKFeatureSample alloc] initWhitData:data];
}

-(instancetype) initWhitTimestamp: (uint64_t)timestamp data:(NSArray<NSNumber*> *)data{
    self = [super init];
    _timestamp=timestamp;
    _data=data;
    _notificaitonTime = [NSDate date];
    return self;
}

-(instancetype _Nonnull) initWhitData:(NSArray<NSNumber*>* _Nonnull)data{
    self = [super init];
    _notificaitonTime = [NSDate date];
    _timestamp=(uint64_t)_notificaitonTime.timeIntervalSince1970;
    _data=data;
    
    return self;
}


@end

@implementation BlueSTSDKExtractResult

+(instancetype) resutlWithSample:(BlueSTSDKFeatureSample *)sample nReadData:(uint32_t)nReadData{
    return [[BlueSTSDKExtractResult alloc] initWhitSample: sample nReadData:nReadData];
}

-(instancetype) initWhitSample:(BlueSTSDKFeatureSample *)sample nReadData:(uint32_t)nReadData{
    self = [super init];
    _nReadBytes=nReadData;
    _sample=sample;
    return self;
}

@end


/**
 *  concurrent queue used for notify the update in different threads
 */
static dispatch_queue_t sNotificationQueue;

/**
 *  formatter used for print the number
 */
static NSNumberFormatter *sFormatter;


@implementation BlueSTSDKFeature{
    
    /**
     *  set of delegate where log the feature update
     */
    NSMutableSet *mFeatureLogDelegates;
    
}

/**
 *  this method must be overwrite so this implementation just throw an exception
 */
-(instancetype) initWhitNode: (BlueSTSDKNode*)node{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:
                                           @"You must overwrite %@ in a subclass",
                                           NSStringFromSelector(_cmd)]
                                 userInfo:nil];
    return nil;
}

-(instancetype) initWhitNode: (BlueSTSDKNode*)node name:(NSString *)name{
    self = [super init];
    static dispatch_once_t onceToken;
    //the first time we create the queue and the formatter that are sheared
    //between all the nodes
    dispatch_once(&onceToken, ^{
        sNotificationQueue = dispatch_queue_create("BlueSTSDKFeature", DISPATCH_QUEUE_CONCURRENT);
        sFormatter = [[NSNumberFormatter alloc]init];
        [sFormatter setPositiveFormat:@" #0.00"];
        [sFormatter setNegativeFormat:@"-#0.00"];
    });
    
    _featureDelegates = [NSMutableSet set];
    mFeatureLogDelegates = [NSMutableSet set];
    _parentNode=node;
    _enabled=false;
    _name=name;
    return self;
}

-(void) setEnabled:(bool)enabled{
    _enabled=enabled;
}

-(bool)enableNotification{
    return [_parentNode enableNotification:self];
}

-(bool)disableNotification{
    return [_parentNode disableNotification:self];
}

-(bool)read{
    return [_parentNode readFeature:self];
}

-(void) addFeatureDelegate:(id<BlueSTSDKFeatureDelegate>)delegate{
    [_featureDelegates addObject:delegate];
}
-(void) removeFeatureDelegate:(id<BlueSTSDKFeatureDelegate>)delegate{
    [_featureDelegates removeObject:delegate];
}

-(void) addFeatureLoggerDelegate:(id<BlueSTSDKFeatureLogDelegate>)delegate{
    [mFeatureLogDelegates addObject:delegate];
}
-(void) removeFeatureLoggerDelegate:(id<BlueSTSDKFeatureLogDelegate>)delegate{
    [mFeatureLogDelegates removeObject:delegate];
}

//this function must be implemented in a subclass, this implementation only throw an exception
-(NSArray<BlueSTSDKFeatureField*>*)getFieldsDesc{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:
                                           @"You must overwrite %@ in a subclass",
                                           NSStringFromSelector(_cmd)]
                                 userInfo:nil];
    return nil;
}//getFieldsDesc


//this function must be implemented in a subclass, this implementation only throw an exception
-(BlueSTSDKExtractResult*) extractData:(uint64_t)timestamp data:(NSData*)data dataOffset:(uint32_t)offset{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:
                                           @"You must overwrite %@ in a subclass",
                                           NSStringFromSelector(_cmd)]
                                 userInfo:nil];
    return nil;
}//update


-(uint32_t) update:(uint64_t)timestamp data:(NSData*)data dataOffset:(uint32_t)offset{
    BlueSTSDKExtractResult *temp = [self extractData:timestamp data:data dataOffset:offset];
    if(temp.sample!=nil){
        self.lastSample = temp.sample;
        if(self.enabled){
            [self notifyUpdateWithSample:temp.sample];
        }
    }
    if(self.enabled){
        if(temp.nReadBytes!=data.length)
            [self logFeatureUpdate:[data subdataWithRange:NSMakeRange(offset, temp.nReadBytes)]
                        sample:temp.sample];
        else
            [self logFeatureUpdate:data
                            sample:temp.sample];
    }

    return temp.nReadBytes;
}//update

-(void) notifyUpdateWithSample:(BlueSTSDKFeatureSample *)sample{
    for (id<BlueSTSDKFeatureDelegate> delegate in _featureDelegates) {
        dispatch_async(sNotificationQueue,^{
            [delegate didUpdateFeature:self sample:sample];
        });
    }//for
}//notifyUpdateWithSample

-(void) logFeatureUpdate:(NSData*)rawData sample:(BlueSTSDKFeatureSample*)sample{
    for (id<BlueSTSDKFeatureLogDelegate> delegate in mFeatureLogDelegates) {
        dispatch_async(sNotificationQueue,^{
            [delegate feature:self rawData:rawData sample:sample];
        });
    }//for
}//logFeatureUpdate

-(bool) sendCommand:(uint8_t)commandType data:(NSData*)commandData{
    return [_parentNode sendCommandMessageToFeature: self type:commandType data:commandData];
}//sendCommand

//optional abstract method -> default implementation is an empty method
-(void) parseCommandResponseWithTimestamp:(uint64_t)timestamp
                              commandType:(uint8_t)commandType
                                     data:(NSData*)data{
    
}//parseCommandResponseWithTimestamp

-(void) writeData:(NSData *)data{
    [_parentNode writeDataToFeature:self data:data];
}//writeData


-(NSString*) description{
    NSMutableString *s = [NSMutableString stringWithString:@"Ts:"];
    BlueSTSDKFeatureSample *sample = self.lastSample;
    [s appendFormat:@"%lld ",sample.timestamp ];
    NSArray *fields = [self getFieldsDesc];
    NSArray<NSNumber *> *datas = sample.data;
    for (NSUInteger i = 0; i < datas.count; i++) {
        BlueSTSDKFeatureField *field =(BlueSTSDKFeatureField*) fields[i];
        NSNumber *data = datas[i];
        [s appendFormat:@"%@: %@ ",field.name,[sFormatter stringFromNumber:data]];
        if([field hasUnit]){
            [s appendFormat:@"(%@) ", field.unit ];
        }//if
    }//for
    return s;
}//description

@end


#pragma mark - BlueSTSDKFeature(fake)

#import "BlueSTSDKFeature+fake.h"

@implementation BlueSTSDKFeature(fake)

-(NSData*) generateFakeData{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:
                                           @"You must overwrite %@ in a subclass",
                                           NSStringFromSelector(_cmd)]
                                 userInfo:nil];
    return nil;
}

@end
