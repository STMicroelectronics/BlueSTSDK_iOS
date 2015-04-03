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

+(CBCharacteristic*) getCharFromFeature:(W2STSDKFeature*)feature in:(NSArray*)CharFeatureArray{
    NSMutableArray *candidateChar = [NSMutableArray array];
    NSMutableArray *nCharFeatures = [NSMutableArray array];
    for(W2STSDKCharacteristic *temp in CharFeatureArray){
        if ([temp.features containsObject:feature]){
            [candidateChar addObject:temp.features];
            [nCharFeatures addObject: [NSNumber numberWithUnsignedInt: temp.features.count]];
        }//if
    }//for
    if(candidateChar.count == 0)
        return nil;
    else if (candidateChar.count ==1){
        return [candidateChar objectAtIndex:0];
    }else{
        uint32_t maxNFeature =0;
        CBCharacteristic *bestChar = nil;
        for(uint32_t i=0;i<candidateChar.count;i++){
            uint32_t currentFeature =[[nCharFeatures objectAtIndex:i] unsignedIntegerValue];
            if(maxNFeature < currentFeature){
                maxNFeature = currentFeature;
                bestChar = [candidateChar objectAtIndex:i];
            }
        }
        return bestChar;
    }
}



-(id) initWithChar:(CBCharacteristic*)characteristic features:(NSArray*)features{
    self.characteristic=characteristic;
    self.features = features;
    return self;
}


@end
