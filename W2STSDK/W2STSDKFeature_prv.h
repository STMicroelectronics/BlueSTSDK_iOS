//
//  W2STSDKFeature_prv.h
//  W2STSDK
//
//  Created by Giovanni Visentini on 19/05/15.
//  Copyright (c) 2015 STCentralLab. All rights reserved.
//

#ifndef W2STSDK_W2STSDKFeature_prv_h
#define W2STSDK_W2STSDKFeature_prv_h

#include "W2STSDKFeature.h"

@interface W2STSDKFeature(Prv)

/// protected method
-(id) initWhitNode: (W2STSDKNode*)node name:(NSString*)name;
-(void) notifyUpdate;
-(void) logFeatureUpdate:(NSData*)rawData data:(NSArray*)data;
-(BOOL) sendCommand:(uint8_t)commandType data:(NSData*)commandData;
-(void) parseCommandResponseWithTimestamp:(uint32_t)timestamp
                              commandType:(uint8_t)commandType
                                     data:(NSData*)data;
-(void)writeData:(NSData*)data;

///////package method////////////
-(void) setEnabled:(bool)enabled;
-(uint32_t) update:(uint32_t)timestamp data:(NSData*)data dataOffset:(uint32_t)offset;

@end

#endif
