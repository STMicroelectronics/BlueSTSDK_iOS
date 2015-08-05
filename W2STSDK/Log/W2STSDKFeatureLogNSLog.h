//
//  W2STFeatureLogNSLog.h
//  W2STApp
//
//  Created by Giovanni Visentini on 22/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "W2STSDKFeature.h"

/**
 * class that implement the {@link W2STSDKFeatureLogDelegate} and print on the NSLog
 * stream the feature update
 * @author STMicroelectronics - Central Labs.
 */
@interface W2STSDKFeatureLogNSLog : NSObject<W2STSDKFeatureLogDelegate>

@end
