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

#import "BlueSTSDKFeatureLogNSLog.h"
#import "BlueSTSDKNode.h"

@implementation BlueSTSDKFeatureLogNSLog

+(instancetype)loggerWithTimestamp:(NSDate *)timestamp {
    return [[BlueSTSDKFeatureLogNSLog alloc] initWithTimestamp:timestamp];
}
-(instancetype)initWithTimestamp:(NSDate *)timestamp {
    self = [super init];
    _startupTimestamp = timestamp;
    return self;
}
/**
 *  print the new data in the NSLog stream
 */
- (void)feature:(BlueSTSDKFeature *)feature rawData:(NSData*)raw sample:(BlueSTSDKFeatureSample *)sample{
    
    NSMutableString *temp = [NSMutableString string];
    if(raw !=nil){
        [raw enumerateByteRangesUsingBlock:^(const void *bytes,
                                             NSRange byteRange,
                                             BOOL *stop) {
            for (NSUInteger i = 0; i < byteRange.length; ++i) {
                [temp appendFormat:@"%02X", ((uint8_t*)bytes)[i]];
            }//for
        }];
    }//if
    BlueSTSDKNode *node = (BlueSTSDKNode *)feature.parentNode;
    NSLog(@"%@ %@ ts:%llu Raw:%@ Data:%@", node.friendlyName, feature.name, sample.timestamp,temp,[feature description]);
}//feature

@end
