//
//  W2STFeatureLogNSLog.m
//  W2STApp
//
//  Created by Giovanni Visentini on 22/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "BlueSTSDKFeatureLogNSLog.h"

@implementation BlueSTSDKFeatureLogNSLog

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
    NSLog(@"%@ ts:%d Raw:%@ Data:%@",feature.name,sample.timestamp,temp,[feature description]);
}//feature

@end
