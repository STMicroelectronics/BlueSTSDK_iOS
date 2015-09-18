/*******************************************************************************
 * COPYRIGHT(c) 2015 STMicroelectronics
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *   1. Redistributions of source code must retain the above copyright notice,
 *      this list of conditions and the following disclaimer.
 *   2. Redistributions in binary form must reproduce the above copyright notice,
 *      this list of conditions and the following disclaimer in the documentation
 *      and/or other materials provided with the distribution.
 *   3. Neither the name of STMicroelectronics nor the names of its contributors
 *      may be used to endorse or promote products derived from this software
 *      without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 ******************************************************************************/

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

-(instancetype) initWithChar:(CBCharacteristic*)charact features:(NSArray*)features{
    _characteristic=charact;
    _features = features;
    return self;
}


@end
