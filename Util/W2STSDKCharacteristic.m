//
//  W2STSDKCharacteristics.m
//  W2STApp
//
//  Created by Giovanni Visentini on 02/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "W2STSDKCharacteristic.h"

@implementation W2STSDKCharacteristic
+(NSArray*) getFeaturesFromChar:(CBCharacteristic*)characteristic in:(NSArray*)charFeatureArray{
    
    for( W2STSDKCharacteristic *temp in charFeatureArray){
        if([temp.characteristic.UUID isEqual:characteristic.UUID]){
            return temp.features;
        }
    }
    return nil;
}

-(id) initWithChar:(CBCharacteristic*)characteristic features:(NSArray*)features{
    self.characteristic=characteristic;
    self.features = features;
    return self;
}


@end
