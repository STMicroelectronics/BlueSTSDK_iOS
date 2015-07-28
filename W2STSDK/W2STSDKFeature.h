//
//  W2STSDKFeature.h
//  W2STSDK-CB
//
//  Created by Antonino Raucea on 30/04/14.
//  Copyright (c) 2014 STMicroelectronics. All rights reserved.
//
#ifndef W2STSDK_W2STSDKFeature_h
#define W2STSDK_W2STSDKFeature_h

#import <Foundation/Foundation.h>

@protocol W2STSDKFeatureDelegate;
@protocol W2STSDKFeatureLogDelegate;

@class W2STSDKNode;


@interface W2STSDKFeatureSample : NSObject
    @property(readonly) uint32_t timestamp;
    @property(readonly) NSArray *data;

+(W2STSDKFeatureSample*) sampleWithTimestamp:(uint32_t)timestamp data:(NSArray*)data;
-(id) initWhitTimestamp: (uint32_t)timestamp data:(NSArray*)data;

@end

/**
 *  This class represent some set of data that a node can export.
 * <p>You can read the feature value or register a delegate for have 
 * notification when the node will update the values </p>
 * <p>Node that all the notification will be submited in a concurrent queue,
 * so the callback will be run in a concurrent thread </p>
 * <p>
 * This class is abstract, you have to extend it and implement the missing function
 * </p>
 */
@interface W2STSDKFeature : NSObject

/**
 * if a node has in the advertise this feature the class is created but not enable,
 * it is enabled only if the is in the advertise and the node has the corrispective
 * characteristics
 */
@property(readonly) bool enabled;

/**
 *  name of the feature
 */
@property (readonly,retain, nonatomic) NSString *name;

/**
 *  node that export this feature
 */
@property (readonly,retain,nonatomic) W2STSDKNode *parentNode;

/**
 *  date of the last feature update
 */
@property (readonly) NSDate* lastUpdate;

@property (readonly,atomic) W2STSDKFeatureSample *lastSample;


/**
 *  create a string with all the data present in this feature
 *
 *  @return string rappresenting the current feature data
 */
-(NSString*) description;

/**
 *  register a new W2STSDKFeatureDelegate, this protocol is used for notify the
 * user that the feature was updated
 *
 *  @param delegate class where do the callback for notify an update
 */
-(void) addFeatureDelegate:(id<W2STSDKFeatureDelegate>)delegate;

/**
 *  remove a previous register delegate
 *
 *  @param delegate delegate to remove
 */
-(void) removeFeatureDelegate:(id<W2STSDKFeatureDelegate>)delegate;

/**
 *  register a new W2STSDKFeatureLogDelegate this protocol will be called when
 * the feature is updated and will contain the raw data used for extract the 
 * data and the parsed data, is used for logging all the data that comes from the
 * node
 *
 *  @param delegate class where to the callback
 */
-(void) addFeatureLoggerDelegate:(id<W2STSDKFeatureLogDelegate>)delegate;

/**
 *  remove a previous register delegate
 *
 *  @param delegate delegate to remove
 */
-(void) removeFeatureLoggerDelegate:(id<W2STSDKFeatureLogDelegate>)delegate;

/**
 *  <b>abstract method</b>, build a feature that is exported by the node
 *  <p>it is an abstract method, you have to overwrite it </p>
 *  @param node node that export this feature
 *
 *  @return pointer to a feature
 */
-(id) initWhitNode: (W2STSDKNode*)node;

/**
 * <b>abstract method</b>, retrun an array of NSNumber with the data exported by the feature
 * note that the returned data is a copy of the internal state for avoid ghost update
 *
 *  @return array of NSNumber
 */
-(NSArray*) getFieldsData __attribute__ ((deprecated));

/**
 * <b>abstract method</b>, return an array of W2STSDKFeatureField that describe the data
 * returned by the getFieldData function
 *
 *  @return array of W2STSDKFeatureField that describe the data exported by the feature
 */
-(NSArray*) getFieldsDesc;

/**
 * <b>abstract method</b>, return the id of the last package received by this feature
 *
 *  @return id of the last package received by this feature
 */
-(uint32_t) getTimestamp __attribute__ ((deprecated));

@end

/** Protocol used for notify that the feature data was updated */
@protocol W2STSDKFeatureDelegate <NSObject>

/**
 *  method called every time we have new data from this feature
 *
 *  @param feature feature that was updated
 */
@required
- (void)didUpdateFeature:(W2STSDKFeature *)feature sample:(W2STSDKFeatureSample*) sample;

@end

/**
* Protocol used for log all the data received from a feature
*/
@protocol W2STSDKFeatureLogDelegate <NSObject>


/**
 *  method called every time we have new data from this feature
 *
 *  @param feature feature that was updated
 *  @param raw     raw data used for extract the data for this feature
 *  @param data    array of NSNumber extracted by the raw data
 */
@required
- (void)feature:(W2STSDKFeature *)feature rawData:(NSData*)raw sample:(W2STSDKFeatureSample*)sample;
@end

#endif

