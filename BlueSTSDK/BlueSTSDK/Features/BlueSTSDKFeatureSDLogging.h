/*******************************************************************************
 * COPYRIGHT(c) 2017 STMicroelectronics
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

#import "BlueSTSDKFeature.h"

typedef NS_ENUM(uint8_t,BlueSTSDKFeatureSDLoggingStatus){
    BlueSTSDKFeatureSDLoggingStatusSTOPPED=0,
    BlueSTSDKFeatureSDLoggingStatusSTARTED=1,
    BlueSTSDKFeatureSDLoggingStatusNO_SD=2,
    BlueSTSDKFeatureSDLoggingStatusIO_ERROR =0xFF
};

/**
 * Class to manage the loggin on the SD
 */
@interface BlueSTSDKFeatureSDLogging : BlueSTSDKFeature

+(BlueSTSDKFeatureSDLoggingStatus) getStatus:(BlueSTSDKFeatureSample *)data;

/**
 *tell if the board is currently loggin on the sd
 *
 *@param data status data
 *@return true if the node is logging on the sd
 */
+(BOOL)isLogging:(BlueSTSDKFeatureSample*)data;


/**
 *tell how many seconds there are between one samplig and another.

 @param data status data
 @return sampling interval
 */
+(uint32_t)getLogInterval:(BlueSTSDKFeatureSample*)data;


/**
 * get the list of feature that are currently logged

 @param node node where the logging is happaning
 @param data status data
 @return list of feature that the node is logging
 */
+(NSSet<BlueSTSDKFeature*>*)getLoggedFeature:(BlueSTSDKNode*)node data:(BlueSTSDKFeatureSample*)data;


/**
 * Start the logging
 * @param featureToLog list of feature that the node has to log
 * @param seconds interval between 2 sensor reads, in seconds
 */
-(void)sartLoggingFeature:(NSSet<BlueSTSDKFeature*>*)featureToLog evrey:(uint32_t)seconds;

/**
 * stop the logging
 */
-(void)stopLogging NS_SWIFT_NAME(stopLogging()); 


@end
