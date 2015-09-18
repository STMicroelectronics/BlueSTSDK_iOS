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
#import "BlueSTSDKNodeFake.h"

#import "BlueSTSDKFeature_prv.h"
#import "BlueSTSDKFeature+fake.h"

#import "BlueSTSDKFeatureAcceleration.h"
#import "BlueSTSDKFeatureMagnetometer.h"
#import "BlueSTSDKFeatureBattery.h"
#import "BlueSTSDKFeatureGyroscope.h"
#import "BlueSTSDKFeatureHumidity.h"
#import "BlueSTSDKFeatureLuminosity.h"
#import "BlueSTSDKFeaturePressure.h"
#import "BlueSTSDKFeatureProximity.h"
#import "BlueSTSDKFeatureTemperature.h"
#import "BlueSTSDKFeatureActivity.h"
#import "BlueSTSDKFeatureCarryPosition.h"
#import "BlueSTSDKFeatureMemsSensorFusion.h"

/**
 *  @relates BlueSTSDKManager
 *  a notification each 0.2s, 5 notifcation each second
 */
#define NOTIFICATION_TIME_INTERVAL 0.2f

@implementation BlueSTSDKNodeFake{
    /**
     *  system timestamp
     */
    uint32_t timestamp;
    
    /**
     *  list of feature emulated by this node, a feature must implemtnt the methos
     * inside the BlueSTSDKFeature(fake) class
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
                          [[BlueSTSDKFeatureAcceleration alloc] initWhitNode:self],
                          [[BlueSTSDKFeatureMagnetometer alloc] initWhitNode:self],
                          [[BlueSTSDKFeatureBattery alloc] initWhitNode:self],
                          [[BlueSTSDKFeatureHumidity alloc] initWhitNode:self],
                          [[BlueSTSDKFeatureLuminosity alloc] initWhitNode:self],
                          [[BlueSTSDKFeaturePressure alloc] initWhitNode:self],
                          [[BlueSTSDKFeatureGyroscope alloc] initWhitNode:self],
                          [[BlueSTSDKFeaturePressure alloc] initWhitNode:self],
                          [[BlueSTSDKFeatureProximity alloc] initWhitNode:self],
                          [[BlueSTSDKFeatureTemperature alloc] initWhitNode:self],
                          [[BlueSTSDKFeatureMemsSensorFusion alloc] initWhitNode:self],
                          [[BlueSTSDKFeatureMemsSensorFusionCompact alloc] initWhitNode:self],
                          [[BlueSTSDKFeatureActivity alloc] initWhitNode:self],
                          [[BlueSTSDKFeatureCarryPosition alloc] initWhitNode:self]];
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
    BlueSTSDKFeature *feature = (BlueSTSDKFeature*)timer.userInfo;
    [feature update_prv:(timestamp++) data:[feature generateFakeData] dataOffset:0];
}

-(BOOL)readFeature:(BlueSTSDKFeature *)feature{
    [feature update_prv:(timestamp++) data:[feature generateFakeData] dataOffset:0];
    return true;
}

-(BOOL)enableNotification:(BlueSTSDKFeature *)feature{
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

-(BlueSTSDKFeature*) getFeatureOfType:(Class)type{
    
    NSUInteger featureIdx = [availableFeatures indexOfObjectPassingTest:
                             ^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                                 if ([obj isKindOfClass: type]) {
                                     *stop = YES;
                                     return YES;
                                 }
                                 return NO;
                             }];
    if(featureIdx == NSNotFound){
        return nil;
    }//else
    return [availableFeatures objectAtIndex:featureIdx];
}

-(BOOL)disableNotification:(BlueSTSDKFeature *)feature{
    NSTimer *timer = [notifyFeatures objectForKey:feature.name];
    if(timer==nil)
        return false;
    [timer invalidate];
    [notifyFeatures removeObjectForKey:feature.name];
    return true;
}

-(BOOL)isEnableNotification:(BlueSTSDKFeature *)feature{
    return [notifyFeatures objectForKey:feature.name]!=nil;
}

-(void)connect{
    [super updateNodeStatus:BlueSTSDKNodeStateConnecting];
    //[NSThread sleepForTimeInterval:0.2];
    [super updateNodeStatus:BlueSTSDKNodeStateConnected];
}

-(void)disconnect{
    [super updateNodeStatus:BlueSTSDKNodeStateDisconnecting];
    //[NSThread sleepForTimeInterval:0.2];
    [super updateNodeStatus:BlueSTSDKNodeStateIdle];
}

@end
