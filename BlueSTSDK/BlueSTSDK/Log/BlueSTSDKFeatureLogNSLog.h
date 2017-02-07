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

#ifndef BlueSTSDK_BlueSTSDKFeatureLogNSLog_h
#define BlueSTSDK_BlueSTSDKFeatureLogNSLog_h

#import <Foundation/Foundation.h>

#import "BlueSTSDKFeature.h"

/**
 * class that implement the {@link BlueSTSDKFeatureLogDelegate} and print on the NSLog
 * stream the feature update
 * @author STMicroelectronics - Central Labs.
 */
@interface BlueSTSDKFeatureLogNSLog : NSObject<BlueSTSDKFeatureLogDelegate>

/**
 *  startup timestamp of the logging
 */
@property (readonly,strong) NSDate* startupTimestamp;

/**
 *  create a logger with a timestamp
 *
 *  @param timestamp the startup timestamp of the logging
 *
 *  @return pointer to the logger
 */
+(instancetype)loggerWithTimestamp:(NSDate *)timestamp;

/**
 *  create the logger with a timestamp
 *
 *  @param timestamp the startup timestamp of the logging
 *
 *  @return pointer to the logger
 */
-(instancetype)initWithTimestamp:(NSDate *)timestamp;
@end

#endif
