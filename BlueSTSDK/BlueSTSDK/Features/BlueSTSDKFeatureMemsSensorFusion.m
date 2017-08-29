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

#import "BlueSTSDKFeature_prv.h"
#import "BlueSTSDKFeatureMemsSensorFusion.h"
#import "BlueSTSDKFeatureField.h"
#import "BlueSTSDK_LocalizeUtil.h"
#import "../Util/NSData+NumberConversion.h"

#define FEATURE_NAME BLUESTSDK_LOCALIZE(@"MEMS Sensor Fusion",nil)
#define FEATURE_UNIT @""
#define FEATURE_MIN -1.0f
#define FEATURE_MAX 1.0
#define FEATURE_TYPE BlueSTSDKFeatureFieldTypeFloat

/**
 * @memberof BlueSTSDKFeatureMemsSensorFusion
 *  array with the description of field exported by the feature
 */
static NSArray<BlueSTSDKFeatureField*> *sFieldDesc;

@implementation BlueSTSDKFeatureMemsSensorFusion

+(void)initialize{
    if(self == [BlueSTSDKFeatureMemsSensorFusion class]){
        sFieldDesc = @[[BlueSTSDKFeatureField createWithName:@"qi"
                                                        unit:FEATURE_UNIT
                                                        type:FEATURE_TYPE
                                                         min:@FEATURE_MIN
                                                         max:@FEATURE_MAX],
                [BlueSTSDKFeatureField createWithName:@"qj"
                                                 unit:FEATURE_UNIT
                                                 type:FEATURE_TYPE
                                                  min:@FEATURE_MIN
                                                  max:@FEATURE_MAX],
                [BlueSTSDKFeatureField createWithName:@"qk"
                                                 unit:FEATURE_UNIT
                                                 type:FEATURE_TYPE
                                                  min:@FEATURE_MIN
                                                  max:@FEATURE_MAX],
                [BlueSTSDKFeatureField createWithName:@"qs"
                                                 unit:FEATURE_UNIT
                                                 type:FEATURE_TYPE
                                                  min:@FEATURE_MIN
                                                  max:@FEATURE_MAX]];
    }//if
}//initialize


+(float)getQi:(BlueSTSDKFeatureSample*)sample{
    if(sample.data.count==0)
        return NAN;
    return[[sample.data objectAtIndex:0] floatValue];
}//getQi

+(float)getQj:(BlueSTSDKFeatureSample*)sample{
    if(sample.data.count<1)
        return NAN;
    return[[sample.data objectAtIndex:1] floatValue];
}

+(float)getQk:(BlueSTSDKFeatureSample*)sample{
    if(sample.data.count<2)
        return NAN;
    return[[sample.data objectAtIndex:2] floatValue];
}

+(float)getQs:(BlueSTSDKFeatureSample*)sample{
    if(sample.data.count<3)
        return NAN;
    return[[sample.data objectAtIndex:3] floatValue];
}

-(instancetype) initWhitNode:(BlueSTSDKNode *)node{
    self = [super initWhitNode:node name:FEATURE_NAME];
    return self;
}

-(NSArray<BlueSTSDKFeatureField*>*) getFieldsDesc{
    return sFieldDesc;
}

/**
 *  read 3 or 4 float for build the quaternion value, create the new sample and
 * and notify it to the delegate.
 * it the scalar component is not present we assume that the other are normalized
 * and we compute it
 *
 *  @param timestamp data time stamp
 *  @param rawData   array of byte send by the node
 *  @param offset    offset where we have to start reading the data
 *
 *  @throw exception if there are no almost 12 bytes available in the rawdata array
 *  @return quaternion angle + number of read bytes (12 or 16)
 */
-(BlueSTSDKExtractResult*) extractData:(uint64_t)timestamp data:(NSData*)rawData dataOffset:(uint32_t)offset{
    
    if(rawData.length-offset < 12){
        @throw [NSException
                exceptionWithName:BLUESTSDK_LOCALIZE(@"Invalid SensorFunsion data",nil)
                reason:BLUESTSDK_LOCALIZE(@"The feature need almost 12 byte for extract the data",nil)
                userInfo:nil];
    }//if
    
    float x,y,z,w;
    x= [rawData extractLeFloatFromOffset:offset];
    y= [rawData extractLeFloatFromOffset:offset+4];
    z= [rawData extractLeFloatFromOffset:offset+8];
    
    uint8_t readbyte =12;
    
    if((rawData.length-offset) > 12){
        w= [rawData extractLeFloatFromOffset:offset+12];
        readbyte=16;
        
        //normalize the quaternion
        const float norm = sqrtf(x*x+y*y+z*z+w*w);
        x/=norm;
        y/=norm;
        z/=norm;
        w/=norm;
        
    }else
        w = sqrt(1-(x*x+y*y+z*z));
        
    NSArray *newData = @[@(x), @(y), @(z), @(w)];
    
    BlueSTSDKFeatureSample *sample = [BlueSTSDKFeatureSample sampleWithTimestamp:timestamp data:newData];
    return [BlueSTSDKExtractResult resutlWithSample:sample nReadData:readbyte];
}

@end


#import "../BlueSTSDKFeature+fake.h"

#define N_DECIMAL 100
@implementation BlueSTSDKFeatureMemsSensorFusion (fake)

-(NSData*) generateFakeData{
    NSMutableData *data = [NSMutableData dataWithCapacity:12];
    
    float x = FEATURE_MIN*N_DECIMAL + rand()%((int)((FEATURE_MAX-FEATURE_MIN)*N_DECIMAL));
    
    float y= FEATURE_MIN*N_DECIMAL + rand()%((int)((FEATURE_MAX-FEATURE_MIN)*N_DECIMAL));
    
    float z = FEATURE_MIN*N_DECIMAL + rand()%((int)((FEATURE_MAX-FEATURE_MIN)*N_DECIMAL));
    
    float w = FEATURE_MIN*N_DECIMAL + rand()%((int)((FEATURE_MAX-FEATURE_MIN)*N_DECIMAL));
    
    const float norm = sqrtf(x*x+y*y+z*z+w*w);
    
    x/=norm;
    y/=norm;
    z/=norm;
    w/=norm;
    
    [data appendBytes:&x length:4];
    [data appendBytes:&y length:4];
    [data appendBytes:&z length:4];
    [data appendBytes:&w length:4];
    return data;
}

@end
