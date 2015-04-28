//
//  W2STSDKFeatureProximity.h
//  W2STApp
//
//  Created by Giovanni Visentini on 28/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "W2STSDKFeature.h"

@interface W2STSDKFeatureProximity : W2STSDKFeature
+(void)initialize;
+(uint16_t)getProximityDistance:(NSArray*)data;
+(uint16_t)outOfRangeValue;
-(id) initWhitNode:(W2STSDKNode *)node;

//abstract method
-(NSArray*) getFieldsDesc;
-(NSArray*) getFieldsData;
-(uint32_t) update:(uint32_t)timestamp data:(NSData*)data dataOffset:(uint32_t)offset;
@end
