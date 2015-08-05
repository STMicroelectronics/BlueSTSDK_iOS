//
//  W2STSDKFeature.m
//  W2STSDK-CB
//
//  Created by Giovanni Visentini on 21/04/15.
//  Copyright (c) 2014 STMicroelectronics. All rights reserved.
//

#import "W2STSDKNode_prv.h"
#import "W2STSDKFeature_prv.h"
#import "W2STSDKFeatureField.h"

@interface W2STSDKFeature()
@property (readwrite,atomic) W2STSDKFeatureSample *lastSample;
@end


@implementation W2STSDKFeatureSample

+(instancetype) sampleWithTimestamp:(uint32_t)timestamp data:(NSArray*)data{
    return [[W2STSDKFeatureSample alloc] initWhitTimestamp: timestamp data:data];
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


@implementation W2STSDKFeature{
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
-(instancetype) initWhitNode: (W2STSDKNode*)node{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must overwrite %@ in a subclass]",
                                           NSStringFromSelector(_cmd)]
                                 userInfo:nil];
    return nil;
}

-(instancetype) initWhitNode: (W2STSDKNode*)node name:(NSString *)name{
    self = [super init];
    static dispatch_once_t onceToken;
    //the first time we create the queue and the formatter that are sheared
    //between all the nodes
    dispatch_once(&onceToken, ^{
        sNotificationQueue = dispatch_queue_create("W2STSDKFeature", DISPATCH_QUEUE_CONCURRENT);
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

-(void) notifyUpdateWithSample:(W2STSDKFeatureSample *)sample{
    for (id<W2STSDKFeatureDelegate> delegate in mFeatureDelegates) {
        dispatch_async(sNotificationQueue,^{
            [delegate didUpdateFeature:self sample:sample];
        });
    }//for
}//notifyUpdateWithSample

-(void) logFeatureUpdate:(NSData*)rawData sample:(W2STSDKFeatureSample*)sample{
    for (id<W2STSDKFeatureLogDelegate> delegate in mFeatureLogDelegates) {
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
    W2STSDKFeatureSample *sample = self.lastSample;
    [s appendFormat:@"%d ",sample.timestamp ];
    NSArray *fields = [self getFieldsDesc];
    NSArray *datas = sample.data;
    for (int i = 0; i < fields.count; i++) {
        W2STSDKFeatureField *field =(W2STSDKFeatureField*)[fields objectAtIndex:i];
        NSNumber *data = (NSNumber*)[datas objectAtIndex:i];
        [s appendFormat:@"%@: %@ ",field.name,[sFormatter stringFromNumber:data]];
        if(field.unit.length!=0){
            [s appendFormat:@"(%@) ", field.unit ];
        }//if
    }//for
    return s;
}//description

@end


#pragma mark - W2STSDKFeature(fake)

#include "W2STSDKFeature+fake.h"

@implementation W2STSDKFeature(fake)

-(NSData*) generateFakeData{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must overwrite %@ in a subclass]",
                                           NSStringFromSelector(_cmd)]
                                 userInfo:nil];
    return nil;
}

@end
