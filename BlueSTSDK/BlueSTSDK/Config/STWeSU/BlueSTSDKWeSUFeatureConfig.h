//
//  BlueSTSDKWeSUFeatureConfig.h
//  BlueSTSDK
//
//  Created by Giovanni Visentini on 20/12/2016.
//  Copyright © 2016 STCentralLab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BlueSTSDKWeSUFeatureConfig : NSObject
@property BOOL outputBLE;
@property BOOL outputUSART;
@property BOOL outputRAM;
@property uint8_t subsampling;

+(instancetype)configWithSubsampling:(uint8_t)subsampling outputBLE:(BOOL)outputBle
                         outputUSART:(BOOL)outputUSART outputRAM:(BOOL)outputRAM;

@end
