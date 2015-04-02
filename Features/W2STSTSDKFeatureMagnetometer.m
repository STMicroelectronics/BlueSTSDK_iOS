//
//  W2STSTSDKFeatureMagnetometer.m
//  W2STApp
//
//  Created by Giovanni Visentini on 02/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "W2STSTSDKFeatureMagnetometer.h"
#define FEATURE_NANE @"Magnetometer"

@implementation W2STSTSDKFeatureMagnetometer
-(id) initWhitNode:(W2STSDKNode *)node{
    self = [super initWhitNode:node];
    self.name=FEATURE_NANE;
    return self;
}
@end
