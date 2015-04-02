//
//  W2STSDKFeatureAcceleration.m
//  W2STApp
//
//  Created by Giovanni Visentini on 02/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "W2STSDKFeatureAcceleration.h"

#define FEATURE_NANE @"Acceleration"

@implementation W2STSDKFeatureAcceleration

-(id) initWhitNode:(W2STSDKNode *)node{
    self = [super initWhitNode:node];
    self.name=FEATURE_NANE;
    return self;
}

@end
