//
//  W2STSDKNodeFake.m
//  W2STSDK
//
//  Created by Giovanni Visentini on 19/05/15.
//  Copyright (c) 2015 STCentralLab. All rights reserved.
//

#import "W2STSDKNode_prv.h"
#import "W2STSDKNodeFake.h"

#import "W2STSDKFeature_prv.h"
#import "W2STSDKFeature+fake.h"

#import "W2STSDKFeatureAcceleration.h"
#import "W2STSDKFeatureMagnetometer.h"
#import "W2STSDKFeatureBattery.h"
#import "W2STSDKFeatureGyroscope.h"
#import "W2STSDKFeatureHumidity.h"
#import "W2STSDKFeatureLuminosity.h"
#import "W2STSDKFeaturePressure.h"
#import "W2STSDKFeatureProximity.h"
#import "W2STSDKFeatureTemperature.h"
#import "W2STSDKFeatureActivity.h"
#import "W2STSDKFeatureCarryPosition.h"
#import "W2STSDKFeatureMemsSensorFusion.h"

/**
 *  @relates W2STSDKManager
 *  a notification each 0.2s, 5 notifcation each second
 */
#define NOTIFICATION_TIME_INTERVAL 0.2f

@implementation W2STSDKNodeFake{
    /**
     *  system timestamp
     */
    uint32_t timestamp;
    
    /**
     *  list of feature emulated by this node, a feature must implemtnt the methos
     * inside the W2STSDKFeature(fake) class
     */
    NSArray *availableFeatures;
    
    /**
     *  link a feature name with a time that will triger the generation of new data
     */
    NSMutableDictionary *notifyFeatures;
}

@synthesize name = _name;
@synthesize tag = _tag;
@synthesize txPower = _txPower;


-(instancetype)init{
    self = [super init];
    timestamp=0;
    _name=@"FakeNode";
    _tag=@"012345678-1234-5678-0123-123456789ABCD";
    _txPower=@100;
    availableFeatures = @[
                          [[W2STSDKFeatureAcceleration alloc] initWhitNode:self],
                          [[W2STSDKFeatureMagnetometer alloc] initWhitNode:self],
                          [[W2STSDKFeatureBattery alloc] initWhitNode:self],
                          [[W2STSDKFeatureHumidity alloc] initWhitNode:self],
                          [[W2STSDKFeatureLuminosity alloc] initWhitNode:self],
                          [[W2STSDKFeaturePressure alloc] initWhitNode:self],
                          [[W2STSDKFeatureGyroscope alloc] initWhitNode:self],
                          [[W2STSDKFeaturePressure alloc] initWhitNode:self],
                          [[W2STSDKFeatureProximity alloc] initWhitNode:self],
                          [[W2STSDKFeatureTemperature alloc] initWhitNode:self],
                          [[W2STSDKFeatureMemsSensorFusion alloc] initWhitNode:self],
                          [[W2STSDKFeatureMemsSensorFusionCompact alloc] initWhitNode:self],
                          [[W2STSDKFeatureActivity alloc] initWhitNode:self],
                          [[W2STSDKFeatureCarryPosition alloc] initWhitNode:self]];
    notifyFeatures = [NSMutableDictionary dictionary];
    return self;
}//init

-(void)readRssi{
    [super updateRssi: @(rand() % 100)];
}//readRssi

-(NSArray*) getFeatures{
    return availableFeatures;
}//getFeatures

/**
 *  callback fired each time a timer expired, it generate and parse new data for
 * the feature that arm the timer
 *
 *  @param timer timer that expire
 */
-(void)generateFakeFeatureNotification:(NSTimer *)timer{
    W2STSDKFeature *feature = (W2STSDKFeature*)timer.userInfo;
    [feature update:(timestamp++) data:[feature generateFakeData] dataOffset:0];
}

-(BOOL)readFeature:(W2STSDKFeature *)feature{
    [feature update:(timestamp++) data:[feature generateFakeData] dataOffset:0];
    return true;
}

-(BOOL)enableNotification:(W2STSDKFeature *)feature{
    //start a timer that fire each NOTIFICATION_TIME_INTERVAL seconds and call
    // the function generateFakeFeatureNotification
    NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:NOTIFICATION_TIME_INTERVAL
                                                      target:self
                                                    selector:@selector(generateFakeFeatureNotification:)
                                                    userInfo:feature
                                                     repeats:YES];
    
    [notifyFeatures setObject:timer forKey:feature.name];
    return true;
}

-(BOOL)disableNotification:(W2STSDKFeature *)feature{
    NSTimer *timer = [notifyFeatures objectForKey:feature.name];
    if(timer==nil)
        return false;
    [timer invalidate];
    [notifyFeatures removeObjectForKey:feature.name];
    return true;
}

-(BOOL)isEnableNotification:(W2STSDKFeature *)feature{
    return [notifyFeatures objectForKey:feature.name]!=nil;
}

-(void)connect{
    [super updateNodeStatus:W2STSDKNodeStateConnecting];
    //[NSThread sleepForTimeInterval:0.2];
    [super updateNodeStatus:W2STSDKNodeStateConnected];
}

-(void)disconnect{
    [super updateNodeStatus:W2STSDKNodeStateDisconnecting];
    //[NSThread sleepForTimeInterval:0.2];
    [super updateNodeStatus:W2STSDKNodeStateIdle];
}

@end
