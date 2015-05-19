//
//  W2STSDKFeatureAutoConfigurable_prv.h
//  W2STSDK
//
//  Created by Giovanni Visentini on 19/05/15.
//  Copyright (c) 2015 STCentralLab. All rights reserved.
//

#ifndef W2STSDK_W2STSDKFeatureAutoConfigurable_prv_h
#define W2STSDK_W2STSDKFeatureAutoConfigurable_prv_h

#import "W2STSDKFeatureAutoConfigurable.h"

@interface W2STSDKFeatureAutoConfigurable(Prv)

-(id) initWhitNode: (W2STSDKNode*)node name:(NSString*)name;
-(void) parseCommandResponseWithTimestamp:(uint32_t)timestamp
                              commandType:(uint8_t)commandType
                                     data:(NSData*)data;

@end

#endif
