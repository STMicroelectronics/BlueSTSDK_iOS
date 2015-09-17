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

@interface BlueSTSDKFeature()
@property (readwrite,atomic) BlueSTSDKFeatureSample *lastSample;
@end


@implementation BlueSTSDKFeatureSample

+(instancetype) sampleWithTimestamp:(uint32_t)timestamp data:(NSArray*)data{
    return [[BlueSTSDKFeatureSample alloc] initWhitTimestamp: timestamp data:data];
}

-(instancetype) initWhitTimestamp: (uint32_t)timestamp data:(NSArray*)data{
    self = [super init];
    _timestamp=timestamp;
    _data=data;
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
     *  set of delegate where notify the feature update
     */
    NSMutableSet *mFeatureDelegates;
    
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
                                   reason:[NSString stringWithFormat:@"You must overwrite %@ in a subclass]",
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
    
    mFeatureDelegates = [NSMutableSet set];
    mFeatureLogDelegates = [NSMutableSet set];
    _parentNode=node;
    _enabled=false;
    _name=name;
    return self;
}

-(void) setEnabled:(bool)enabled{
    _enabled=enabled;
}

-(void) addFeatureDelegate:(id<BlueSTSDKFeatureDelegate>)delegate{
    [mFeatureDelegates addObject:delegate];
}
-(void) removeFeatureDelegate:(id<BlueSTSDKFeatureDelegate>)delegate{
    [mFeatureDelegates removeObject:delegate];
}

-(void) addFeatureLoggerDelegate:(id<BlueSTSDKFeatureLogDelegate>)delegate{
    [mFeatureLogDelegates addObject:delegate];
}
-(void) removeFeatureLoggerDelegate:(id<BlueSTSDKFeatureLogDelegate>)delegate{
    [mFeatureLogDelegates removeObject:delegate];
}

//this function must be implemented in a subclass, this implementation only throw an exception
-(NSArray*)getFieldsDesc{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must overwrite %@ in a subclass]",
                                           NSStringFromSelector(_cmd)]
                                 userInfo:nil];
    return nil;
}//getFieldsDesc

//this function must be implemented in a subclass, this implementation only throw an exception
-(uint32_t) update:(uint32_t)timestamp data:(NSData*)data dataOffset:(uint32_t)offset{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must overwrite %@ in a subclass]",
                                           NSStringFromSelector(_cmd)]
                                 userInfo:nil];
    return 0;
}//update

-(void) notifyUpdateWithSample:(BlueSTSDKFeatureSample *)sample{
    for (id<BlueSTSDKFeatureDelegate> delegate in mFeatureDelegates) {
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
-(void) parseCommandResponseWithTimestamp:(uint32_t)timestamp
                              commandType:(uint8_t)commandType
                                     data:(NSData*)data{
    
}//parseCommandResponseWithTimestamp

-(void) writeData:(NSData *)data{
    [_parentNode writeDataToFeature:self data:data];
}//writeData


-(NSString*) description{
    NSMutableString *s = [NSMutableString stringWithString:@"Ts:"];
    BlueSTSDKFeatureSample *sample = self.lastSample;
    [s appendFormat:@"%d ",sample.timestamp ];
    NSArray *fields = [self getFieldsDesc];
    NSArray *datas = sample.data;
    for (int i = 0; i < fields.count; i++) {
        BlueSTSDKFeatureField *field =(BlueSTSDKFeatureField*)[fields objectAtIndex:i];
        NSNumber *data = (NSNumber*)[datas objectAtIndex:i];
        [s appendFormat:@"%@: %@ ",field.name,[sFormatter stringFromNumber:data]];
        if(field.unit.length!=0){
            [s appendFormat:@"(%@) ", field.unit ];
        }//if
    }//for
    return s;
}//description

@end


#pragma mark - BlueSTSDKFeature(fake)

#include "BlueSTSDKFeature+fake.h"

@implementation BlueSTSDKFeature(fake)

-(NSData*) generateFakeData{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must overwrite %@ in a subclass]",
                                           NSStringFromSelector(_cmd)]
                                 userInfo:nil];
    return nil;
}

@end
