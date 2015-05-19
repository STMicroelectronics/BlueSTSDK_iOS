//
//  W2STFeaturePressure.h
//  W2STApp
//
//  Created by Giovanni Visentini on 10/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "W2STSDKFeature.h"

@interface W2STSDKFeaturePressure : W2STSDKFeature
+(void)initialize;
+(float)getPressure:(NSArray*)data;

-(id) initWhitNode:(W2STSDKNode *)node;

//abstract method
-(NSArray*) getFieldsDesc;
-(NSArray*) getFieldsData;
-(uint32_t) update:(uint32_t)timestamp data:(NSData*)data dataOffset:(uint32_t)offset;

@end
