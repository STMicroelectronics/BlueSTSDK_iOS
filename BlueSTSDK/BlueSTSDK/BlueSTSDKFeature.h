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

#ifndef BlueSTSDK_BlueSTSDKFeature_h
#define BlueSTSDK_BlueSTSDKFeature_h

#import <Foundation/Foundation.h>
#import "BlueSTSDKFeatureField.h"

@protocol BlueSTSDKFeatureDelegate;
@protocol BlueSTSDKFeatureLogDelegate;

@class BlueSTSDKNode;

/**
 *  Class that represent a sample data from a feature, it contains the data
 * exported by the feature and the node timestamp.
 * @author STMicroelectronics - Central Labs.
 */
@interface BlueSTSDKFeatureSample : NSObject

/**
 *  moment when the data arrive at the device
 */
@property(readonly,retain,nonnull) NSDate *notificaitonTime;

/**
 *  node time stamp at the moment of the data acquisition
 */
@property(readonly) uint64_t timestamp;

/**
 *  array of NSNumber with the feature data
 */
@property(readonly,retain) NSArray< NSNumber* > * _Nonnull data;

/**
 *  build a BlueSTSDKFeatureSample
 *
 *  @param timestamp times stamp of the data acquisition
 *  @param data      data exported by the feature
 *
 *  @return object that contains the data
 */
+(instancetype _Nonnull ) sampleWithTimestamp:(uint64_t)timestamp data:(NSArray<NSNumber*>* _Nonnull)data;
+(instancetype _Nonnull ) sampleWithData:(NSArray<NSNumber*>* _Nonnull)data;

/**
 *  initialize a BlueSTSDKFeatureSample
 *
 *  @param timestamp times stamp of the data acquisition
 *  @param data      data exported by the feature
 *
 *  @return object that contains the data
 */
-(instancetype _Nonnull) initWhitTimestamp: (uint64_t)timestamp data:(NSArray<NSNumber*>* _Nonnull)data;

-(instancetype _Nonnull) initWhitData:(NSArray<NSNumber*>* _Nonnull)data;

@end

/**
 *  This class represent some set of data that a node can export.
 * \par
 * You can read the feature value or register a delegate for have
 * notification when the node will update the values
 * @note That all the notification will be submited in a concurrent queue,
 * so the callback will be run in a background thread
 *
 * @note This class is abstract, you have to extend it and implement the missing function
 * @author STMicroelectronics - Central Labs.
 */
NS_CLASS_AVAILABLE(10_7, 5_0)
@interface BlueSTSDKFeature : NSObject

/**
 * if a node has in the advertise this feature the class is created but not enabled,
 * it is enabled only if the is in the advertise and the node has the equivalent
 * characteristic
 */
@property(readonly) bool enabled;

/**
 *  name of the feature
 */
@property (readonly,retain, nonatomic,nonnull) NSString *name;

/**
 *  node that export this feature
 */
@property (readonly,retain,nonatomic,nonnull) BlueSTSDKNode *parentNode;

/**
 *  system time when we receive the last update
 */
@property (readonly,nullable) NSDate* lastUpdate;

/**
 *  object that contains the last data received from the node
 */
@property (readonly,atomic,nullable) BlueSTSDKFeatureSample *lastSample;


/**
 *  create a string with all the data present in this feature
 *
 *  @return string represent the current feature data
 */
-(nonnull NSString*) description;

/**
 *  register a new {@link BlueSTSDKFeatureDelegate}, this protocol is used for 
 * notify to the user that the feature have new data
 *
 *  @param delegate class where do the callback for notify an update
 */
-(void) addFeatureDelegate:(nonnull id<BlueSTSDKFeatureDelegate>)delegate;

/**
 *  remove a previous register delegate
 *
 *  @param delegate delegate to remove
 */
-(void) removeFeatureDelegate:(nonnull id<BlueSTSDKFeatureDelegate>)delegate;

/**
 *  register a new {@link BlueSTSDKFeatureLogDelegate} this protocol will be called when
 * the feature is updated and will contain the raw data used for extract the
 * data and the parsed data,it is used for logging all the data that comes from the
 * node
 *
 *  @param delegate class where to the callback
 */
-(void) addFeatureLoggerDelegate:(nonnull id<BlueSTSDKFeatureLogDelegate>)delegate;

/**
 *  remove a previous register delegate
 *
 *  @param delegate delegate to remove
 */
-(void) removeFeatureLoggerDelegate:(nonnull id<BlueSTSDKFeatureLogDelegate>)delegate;

/**
 * Disable the notification for this specific feature
 * @return true if the connand is correcly sent
 */
-(bool) disableNotification;

/**
 * enable the notification for this specific feature
 * @return true if the connand is correcly sent
 */
-(bool) enableNotification;

-(bool) read;
/**
 *  <b>abstract method</b>, build a feature that is exported by the node
 *  @note it is an abstract method, you have to overwrite it!
 *  @param node node that export this feature
 *
 *  @return pointer to a feature
 */
-(nonnull instancetype) initWhitNode: (nonnull BlueSTSDKNode*)node;


/**
 * <b>abstract method</b>, return an array of {@link BlueSTSDKFeatureField} that
 * describe the data inside the array {@link BlueSTSDKFeatureSample::data}
 *  @note it is an abstract method, you have to overwrite it!
 *  @return array of BlueSTSDKFeatureField that describe the data exported by the feature
 */
-(nonnull NSArray<BlueSTSDKFeatureField*>*) getFieldsDesc;


@end

/** Protocol used for notify that the feature data was updated */
@protocol BlueSTSDKFeatureDelegate <NSObject>

/**
 *  method called every time we have new data from this feature
 *
 *  @param feature feature that was updated
 *  @param sample  last data read from the feature
 */
@required
- (void)didUpdateFeature:(nonnull BlueSTSDKFeature *)feature sample:(nonnull BlueSTSDKFeatureSample*) sample;

@end

/**
 * Protocol used for log all the data received from a feature
 */
@protocol BlueSTSDKFeatureLogDelegate <NSObject>


/**
 *  method called every time we have new data from this feature
 *
 *  @param feature feature that was updated
 *  @param raw     raw data used for extract the data for this feature
 *  @param sample  data extracted by the feature
 */
@required
- (void)feature:(nonnull BlueSTSDKFeature *)feature rawData:(nonnull NSData*)raw sample:(nonnull BlueSTSDKFeatureSample*)sample;
@end

#endif

