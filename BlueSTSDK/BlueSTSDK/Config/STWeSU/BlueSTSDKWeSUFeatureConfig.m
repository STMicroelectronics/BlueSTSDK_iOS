//
//  BlueSTSDKWeSUFeatureConfig.m
//  BlueSTSDK
//
//  Created by Giovanni Visentini on 20/12/2016.
//  Copyright © 2016 STCentralLab. All rights reserved.
//

#import "BlueSTSDKWeSUFeatureConfig.h"

@implementation BlueSTSDKWeSUFeatureConfig

+(instancetype)configWithSubsampling:(uint8_t)subsampling outputBLE:(BOOL)outputBle
                         outputUSART:(BOOL)outputUSART outputRAM:(BOOL)outputRAM{
    
    BlueSTSDKWeSUFeatureConfig *temp = [[BlueSTSDKWeSUFeatureConfig alloc]init];
    temp.subsampling = subsampling;
    temp.outputBLE = outputBle;
    temp.outputUSART = outputUSART;
    temp.outputRAM = outputRAM;
    return temp;
}

-(NSString*) description{
    
    NSMutableString *desc = [NSMutableString string];
    
    [desc appendString:@"Output: "];
    if(_outputBLE == false && _outputRAM==false && _outputUSART==false)
        [desc appendString:@"NONE "];
    else{
        if(_outputBLE)
            [desc appendString:@"BLE "];
        if(_outputRAM)
            [desc appendString:@"RAM "];
        if(_outputUSART)
            [desc appendString:@"USART "];
    }
    
    [desc appendFormat:@"Subsampling: %u",_subsampling];
    
    return desc;
}

@end
