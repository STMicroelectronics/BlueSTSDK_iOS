//
//  W2STSDKFeature+fake.h
//  W2STSDK
//
//  Created by Giovanni Visentini on 20/05/15.
//  Copyright (c) 2015 STCentralLab. All rights reserved.
//

#ifndef W2STSDK_W2STSDKFeature_fake_h
#define W2STSDK_W2STSDKFeature_fake_h

#import "W2STSDKFeature.h"

/**
 * Extend the feature for be able to generate fake data to be uesed in the ios 
 * emulator
 */
@interface W2STSDKFeature (fake)

/**
 *  <b>abstract method</b>, you have to overwrite this method if you want 
 *  enable the possibility to use a fake feature into the ios emulator
 *
 *  @return data that will be passed to the updateFeature for trigger a fake feature update
 */
-(NSData*) generateFakeData;

@end

#endif
