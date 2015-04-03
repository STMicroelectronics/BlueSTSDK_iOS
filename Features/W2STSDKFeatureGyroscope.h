//
//  W2STSDKFeatureGyroscope.h
//  W2STApp
//
//  Created by Giovanni Visentini on 02/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "W2STSDKFeature.h"

@interface W2STSDKFeatureGyroscope : W2STSDKFeature

+(void)initialize;
+(float)getGyroX:(NSArray*)data;
+(float)getGyroY:(NSArray*)data;
+(float)getGyroZ:(NSArray*)data;

-(id) initWhitNode:(W2STSDKNode *)node;

//abstract method
-(NSArray*) getFieldDesc;
-(NSArray*) getFieldData;
-(uint32_t) update:(uint32_t)timestamp data:(NSData*)data dataOffset:(uint32_t)offset;

@end
