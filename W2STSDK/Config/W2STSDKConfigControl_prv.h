//
//  W2STSDKConfigControl_prv.h
//
//  Created by Antonino Raucea on 06/30/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#ifndef W2STSDKConfigControl_prv_h
#define W2STSDKConfigControl_prv_h

#import <Foundation/Foundation.h>

#import "W2STSDKConfigControl.h"

@interface W2STSDKConfigControl(prv)

-(void)notifyRead:(NSData *)data;
-(void)notifyWrite:(NSData *)data success:(BOOL)success;

@end

#endif //W2STSDKConfigControl_prv_h