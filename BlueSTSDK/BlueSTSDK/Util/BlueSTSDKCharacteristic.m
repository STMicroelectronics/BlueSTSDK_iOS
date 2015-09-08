//
//  BlueSTSDKCharacteristics.m
//  W2STApp
//
//  Created by Giovanni Visentini on 02/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "BlueSTSDKCharacteristic.h"

@implementation BlueSTSDKCharacteristic

+(NSArray*) getFeaturesFromChar:(CBCharacteristic*)characteristic in:(NSArray*)charFeatureArray{
    
    for( BlueSTSDKCharacteristic *temp in charFeatureArray){
        if([temp.characteristic.UUID isEqual:characteristic.UUID]){
            return temp.features;
        }//if
    }//for
    return nil;
}

+(CBCharacteristic const* ) getCharFromFeature:(BlueSTSDKFeature*)feature in:(NSArray*)CharFeatureArray{
    //array that will contains all the characteristics that export the feature
    NSMutableArray *candidateChar = [NSMutableArray array];
    //number of feature exported by the characateristic
    NSMutableArray *nCharFeatures = [NSMutableArray array];
    for(BlueSTSDKCharacteristic *temp in CharFeatureArray){
        if ([temp.features containsObject:feature]){
            [candidateChar addObject:temp.characteristic];
            [nCharFeatures addObject:
                [NSNumber numberWithUnsignedInt:(uint32_t) temp.features.count]];
        }//if
    }//for
    if(candidateChar.count == 0) //no characteristics found
        return nil;
    else if (candidateChar.count ==1){ //only one
        return [candidateChar objectAtIndex:0];
    }else{
        //more than one -> search the one that export more feature -> the max
        //value in the nCharFeatures and return the corrispective object in the
        //candidateChar array
        uint32_t maxNFeature =0;
        CBCharacteristic const* bestChar = nil;
        for(uint32_t i=0;i<candidateChar.count;i++){
            uint32_t currentFeature =(uint32_t)[nCharFeatures objectAtIndex:i];
            if(maxNFeature < currentFeature){
                maxNFeature = currentFeature;
                bestChar = [candidateChar objectAtIndex:i];
            } //if
        }//for
        return bestChar;
    }//if else
}

-(id) initWithChar:(CBCharacteristic*)charact features:(NSArray*)features{
    _characteristic=charact;
    _features = features;
    return self;
}


@end
