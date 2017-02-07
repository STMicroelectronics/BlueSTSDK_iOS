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

#ifndef BlueSTSDK_BlueSTSDKFeatureAutoConfigurable_h
#define BlueSTSDK_BlueSTSDKFeatureAutoConfigurable_h


#import "BlueSTSDKFeature.h"

@protocol BlueSTSDKFeatureAutoConfigurableDelegate;

/**
 * Extend a feature adding the possibility to have a self configuration routine
 * that run on the node. This routine can be start/stop or query by this type of
 * feature.
 *
 * @author STMicroelectronics - Central Labs.
 */
@interface BlueSTSDKFeatureAutoConfigurable : BlueSTSDKFeature

/**
 *  true if the feature is configured
 */
@property(readonly) BOOL isConfigured;

/**
 *  run the self configuration routine in the node
 *
 *  @return true if the message is correctly send
 */
-(BOOL) startAutoConfiguration;

/**
 *  request the status of the configuration process, the status is an int between
 * 0 and 100.
 * The status is notify using the 
 {@link BlueSTSDKFeatureAutoConfigurableDelegate::didAutoConfigurationChange:status:} delegate callback
 *
 *  @return true if the message is correctly send
 */
-(BOOL) requestAutoConfigurationStatus;

/**
 * request to stop the self configuration process
 *
 *  @return true if the message is correctly send
 */
-(BOOL) stopAutoConfiguration;

/**
 *  register a delegate for this feature
 *  @note the callback are done in an concurrent queue
 *
 *  @param delegate object where notify the configuration change
 */
-(void) addFeatureConfigurationDelegate:(id<BlueSTSDKFeatureAutoConfigurableDelegate>)delegate;

/**
 *  remove a delegate for this feature
 *
 *  @param delegate delegate to remove
 */
-(void) removeFeatureConfigurationDelegate:(id<BlueSTSDKFeatureAutoConfigurableDelegate>)delegate;

@end

/**
 *  Protocol used for notify the change configuration change
 */
@protocol  BlueSTSDKFeatureAutoConfigurableDelegate <NSObject>

/**
 *  method called when the node notify that the configuration routine start
 *
 *  @param feature feature that start the auto configuration process
 */
@optional -(void)didAutoConfigurationStart:(BlueSTSDKFeatureAutoConfigurable *)feature;


/**
 *  method called when the node notify a change in the configuration status
 *
 *  @param feature feature that send the message
 *  @param status  number between 0 to 100
 */
@optional -(void)didAutoConfigurationChange:(BlueSTSDKFeatureAutoConfigurable *)feature
                                     status:(int32_t)status;


/**
 *  method called when the node notify that the configuration routine ends
 *
 *  @param feature feature that finished the configuration
 *  @param status last configuration status
 */
@optional -(void)didConfigurationFinished:(BlueSTSDKFeatureAutoConfigurable *)feature
                          status:(int32_t)status;
@end

#endif
