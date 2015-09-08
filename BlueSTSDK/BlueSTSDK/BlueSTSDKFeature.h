//
//  BlueSTSDKFeature.h
//  BlueSTSDK-CB
//
//  Created by Giovanni Visentini on 21/04/15.
//  Copyright (c) 2014 STMicroelectronics. All rights reserved.
//
#ifndef BlueSTSDK_BlueSTSDKFeature_h
#define BlueSTSDK_BlueSTSDKFeature_h

#import <Foundation/Foundation.h>

@protocol BlueSTSDKFeatureDelegate;
@protocol BlueSTSDKFeatureLogDelegate;

@class BlueSTSDKNode;

/**
 *  Class that represent a sample data from a feature, it contains the data
 * exported by the feature and the device timestamp.
 * @author STMicroelectronics - Central Labs.
 */
@interface BlueSTSDKFeatureSample : NSObject
/**
 *  device time stamp at the moment of the data acquisition
 */
@property(readonly) uint32_t timestamp;

/**
 *  array of NSNumber with the feature data
 */
@property(readonly,retain) NSArray *data;

/**
 *  build a BlueSTSDKFeatureSample
 *
 *  @param timestamp times stamp of the data acquisition
 *  @param data      data exported by the feature
 *
 *  @return object that contains the data
 */
+(instancetype) sampleWithTimestamp:(uint32_t)timestamp data:(NSArray*)data;

/**
 *  initialize a BlueSTSDKFeatureSample
 *
 *  @param timestamp times stamp of the data acquisition
 *  @param data      data exported by the feature
 *
 *  @return object that contains the data
 */
-(instancetype) initWhitTimestamp: (uint32_t)timestamp data:(NSArray*)data;

@end

/**
 *  This class represent some set of data that a node can export.
 * \par
 * You can read the feature value or register a delegate for have
 * notification when the node will update the values
 * \par
 * Node that all the notification will be summited in a concurrent queue,
 * so the callback will be run in a concurrent thread
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
@property (readonly,retain, nonatomic) NSString *name;

/**
 *  node that export this feature
 */
@property (readonly,retain,nonatomic) BlueSTSDKNode *parentNode;

/**
 *  system time when we receive the last update
 */
@property (readonly) NSDate* lastUpdate;

/**
 *  object that contains the last data received from the device
 */
@property (readonly,atomic) BlueSTSDKFeatureSample *lastSample;


/**
 *  create a string with all the data present in this feature
 *
 *  @return string represent the current feature data
 */
-(NSString*) description;

/**
 *  register a new {@link BlueSTSDKFeatureDelegate}, this protocol is used for 
 * notify the user that the feature was updated
 *
 *  @param delegate class where do the callback for notify an update
 */
-(void) addFeatureDelegate:(id<BlueSTSDKFeatureDelegate>)delegate;

/**
 *  remove a previous register delegate
 *
 *  @param delegate delegate to remove
 */
-(void) removeFeatureDelegate:(id<BlueSTSDKFeatureDelegate>)delegate;

/**
 *  register a new {@link BlueSTSDKFeatureLogDelegate} this protocol will be called when
 * the feature is updated and will contain the raw data used for extract the
 * data and the parsed data, is used for logging all the data that comes from the
 * node
 *
 *  @param delegate class where to the callback
 */
-(void) addFeatureLoggerDelegate:(id<BlueSTSDKFeatureLogDelegate>)delegate;

/**
 *  remove a previous register delegate
 *
 *  @param delegate delegate to remove
 */
-(void) removeFeatureLoggerDelegate:(id<BlueSTSDKFeatureLogDelegate>)delegate;

/**
 *  <b>abstract method</b>, build a feature that is exported by the node
 *  @note it is an abstract method, you have to overwrite it!
 *  @param node node that export this feature
 *
 *  @return pointer to a feature
 */
-(instancetype) initWhitNode: (BlueSTSDKNode*)node;


/**
 * <b>abstract method</b>, return an array of {@link BlueSTSDKFeatureField} that
 * describe the data inside the array {@link BlueSTSDKFeatureSample::data}
 *  @note it is an abstract method, you have to overwrite it!
 
 *  @return array of BlueSTSDKFeatureField that describe the data exported by the feature
 */
-(NSArray*) getFieldsDesc;


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
- (void)didUpdateFeature:(BlueSTSDKFeature *)feature sample:(BlueSTSDKFeatureSample*) sample;

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
- (void)feature:(BlueSTSDKFeature *)feature rawData:(NSData*)raw sample:(BlueSTSDKFeatureSample*)sample;
@end

#endif

