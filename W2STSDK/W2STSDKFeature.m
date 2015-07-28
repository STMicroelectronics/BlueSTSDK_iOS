//
//  W2STSDKFeature.m
//  W2STSDK-CB
//
//  Created by Antonino Raucea on 30/04/14.
//  Copyright (c) 2014 STMicroelectronics. All rights reserved.
//

#import "W2STSDKNode_prv.h"
#import "W2STSDKFeature_prv.h"
#import "W2STSDKFeatureField.h"

#define DECIMAL_POSITION 2

@interface W2STSDKFeature()
    @property (readwrite,atomic) W2STSDKFeatureSample *lastSample;
@end


@implementation W2STSDKFeatureSample

+(W2STSDKFeatureSample*) sampleWithTimestamp:(uint32_t)timestamp data:(NSArray*)data{
    return [[W2STSDKFeatureSample alloc] initWhitTimestamp: timestamp data:data];
}

-(id) initWhitTimestamp: (uint32_t)timestamp data:(NSArray*)data{
    self = [super init];
    _timestamp=timestamp;
    _data=data;
    return self;
}

@end


/**
 *  cuncurrent queue used for notify the update in different threads
 */
static dispatch_queue_t sNotificationQueue;

@implementation W2STSDKFeature{
    /**
     *  set of delegate where notify the feature update
     */
    NSMutableSet *mFeatureDelegates;
    
    /**
     *  set of delegate where log the feature update
     */
    NSMutableSet *mFeatureLogDelegates;
    
    NSNumberFormatter *mFormatter;
}

-(id) initWhitNode: (W2STSDKNode*)node{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must overide %@ in a subclass]",
                                           NSStringFromSelector(_cmd)]
                                 userInfo:nil];
    return nil;
}

-(id) initWhitNode: (W2STSDKNode*)node name:(NSString *)name{
    self = [super init];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sNotificationQueue = dispatch_queue_create("W2STSDKFeature", DISPATCH_QUEUE_CONCURRENT);
    });

    mFormatter = [[NSNumberFormatter alloc]init];
    [mFormatter setPositiveFormat:@" #0.00"];
    [mFormatter setNegativeFormat:@"-#0.00"];

    
    mFeatureDelegates = [[NSMutableSet alloc] init];
    mFeatureLogDelegates = [[NSMutableSet alloc] init];
    _parentNode=node;
    _enabled=false;
    _name=name;
    return self;
}

-(void) setEnabled:(bool)enabled{
    _enabled=enabled;
}

-(void) addFeatureDelegate:(id<W2STSDKFeatureDelegate>)delegate{
    [mFeatureDelegates addObject:delegate];
}
-(void) removeFeatureDelegate:(id<W2STSDKFeatureDelegate>)delegate{
    [mFeatureDelegates removeObject:delegate];
}

-(void) addFeatureLoggerDelegate:(id<W2STSDKFeatureLogDelegate>)delegate{
    [mFeatureLogDelegates addObject:delegate];
}
-(void) removeFeatureLoggerDelegate:(id<W2STSDKFeatureLogDelegate>)delegate{
    [mFeatureLogDelegates removeObject:delegate];
}

-(NSArray*)getFieldsData{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must overide %@ in a subclass]",
                                           NSStringFromSelector(_cmd)]
                                 userInfo:nil];
    return nil;
}

-(NSArray*)getFieldsDesc{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must overide %@ in a subclass]",
                                           NSStringFromSelector(_cmd)]
                                 userInfo:nil];
    return nil;
}

-(uint32_t)getTimestamp{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must overide %@ in a subclass]",
                                           NSStringFromSelector(_cmd)]
                                 userInfo:nil];
    return -1;
}

-(uint32_t) update:(uint32_t)timestamp data:(NSData*)data dataOffset:(uint32_t)offset{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must overide %@ in a subclass]",
                                           NSStringFromSelector(_cmd)]
                                 userInfo:nil];
    return 0;
}

-(void) notifyUpdateWithSample:(W2STSDKFeatureSample *)sample{
    for (id<W2STSDKFeatureDelegate> delegate in mFeatureDelegates) {
        dispatch_async(sNotificationQueue,^{
            [delegate didUpdateFeature:self sample:sample];
        });
    }//for
}

-(void) logFeatureUpdate:(NSData*)rawData sample:(W2STSDKFeatureSample*)sample{
    for (id<W2STSDKFeatureLogDelegate> delegate in mFeatureLogDelegates) {
        dispatch_async(sNotificationQueue,^{
            [delegate feature:self rawData:rawData sample:sample];
        });
    }//for
}

-(BOOL) sendCommand:(uint8_t)commandType data:(NSData*)commandData{
    return [_parentNode sendCommandMessageToFeature: self type:commandType data:commandData];
}

//optinal abstract method -> default implementation is an empty method
-(void) parseCommandResponseWithTimestamp:(uint32_t)timestamp
                                 commandType:(uint8_t)commandType
                                        data:(NSData*)data{
    
}

-(void) writeData:(NSData *)data{
    [_parentNode writeDataToFeature:self data:data];
}


-(NSString*) description{
    NSMutableString *s = [NSMutableString stringWithString:@"Ts:"];
    W2STSDKFeatureSample *sample = self.lastSample;
    [s appendFormat:@"%d ",sample.timestamp ];
    NSArray *fields = [self getFieldsDesc];
    NSArray *datas = sample.data;
    for (int i = 0; i < fields.count; i++) {
        W2STSDKFeatureField *field =(W2STSDKFeatureField*)[fields objectAtIndex:i];
        NSNumber *data = (NSNumber*)[datas objectAtIndex:i];
        [s appendFormat:@"%@: %@ ",field.name,[mFormatter stringFromNumber:data]];
        if(field.unit.length!=0){
            [s appendFormat:@"(%@) ", field.unit ];
        }
    }//for
    return s;
}

@end


#include "W2STSDKFeature+fake.h"

@implementation W2STSDKFeature(fake)

-(NSData*) generateFakeData{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must overide %@ in a subclass]",
                                           NSStringFromSelector(_cmd)]
                                 userInfo:nil];
    return nil;
}

@end
