//
//  BlueSTSDKFeatureAutoConfigurable_prv.h
//  BlueSTSDK
//
//  Created by Giovanni Visentini on 19/05/15.
//  Copyright (c) 2015 STCentralLab. All rights reserved.
//

#ifndef BlueSTSDK_BlueSTSDKFeatureAutoConfigurable_prv_h
#define BlueSTSDK_BlueSTSDKFeatureAutoConfigurable_prv_h


#import "BlueSTSDKFeatureAutoConfigurable.h"


@interface BlueSTSDKFeatureAutoConfigurable(Prv)

-(id) initWhitNode: (BlueSTSDKNode*)node name:(NSString*)name;
-(void) parseCommandResponseWithTimestamp:(uint32_t)timestamp
                              commandType:(uint8_t)commandType
                                     data:(NSData*)data;

@end

#endif
