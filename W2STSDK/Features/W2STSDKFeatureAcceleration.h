//
//  W2STSDKFeatureAcceleration.h
//  W2STApp
//
//  Created by Giovanni Visentini on 02/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "W2STSDKFeature.h"

@interface W2STSDKFeatureAcceleration : W2STSDKFeature

+(void)initialize;
+(float)getAccX:(NSArray*)data;
+(float)getAccY:(NSArray*)data;
+(float)getAccZ:(NSArray*)data;

-(id) initWhitNode:(W2STSDKNode *)node;

//abstract method
-(NSArray*) getFieldsDesc;
-(NSArray*) getFieldsData;
-(uint32_t) update:(uint32_t)timestamp data:(NSData*)data dataOffset:(uint32_t)offset;

@end
