//
//  W2STSDKFeatureGyroscope.m
//  W2STApp
//
//  Created by Giovanni Visentini on 02/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "W2STSDKFeatureGyroscope.h"
#define FEATURE_NANE @"Gyroscope"

@implementation W2STSDKFeatureGyroscope
-(id) initWhitNode:(W2STSDKNode *)node{
    self = [super initWhitNode:node];
    self.name=FEATURE_NANE;
    return self;
}
@end
