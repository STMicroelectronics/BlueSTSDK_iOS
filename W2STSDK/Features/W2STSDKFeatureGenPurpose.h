//
//  W2STSDKFeatureGenPurpose.h
//  W2STSDK
//
//  Created by Giovanni Visentini on 25/05/15.
//  Copyright (c) 2015 STCentralLab. All rights reserved.
//

#import <W2STSDK/W2STSDK.h>

@interface W2STSDKFeatureGenPurpose : W2STSDKFeature

@property(readonly,weak) CBCharacteristic* characteristics;

+(NSData*) getRawData:(NSArray*)data;

-(id)initWhitNode:(W2STSDKNode *)node characteristics:(CBCharacteristic*)c;



@end
