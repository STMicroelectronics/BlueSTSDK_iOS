//
//  W2STSDKFeatureLogCSV.h
//  W2STApp
//
//  Created by Giovanni Visentini on 22/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "W2STSDKFeature.h"


@interface W2STSDKFeatureLogCSV : NSObject<W2STSDKFeatureLogDelegate>

-(id)init;
-(void) clean;
-(void) closeFiles;


@end
