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

/**
 *  This class represent some set of data that a node can export, you can read
 * the feature value or register a delegate for have notification when the node
 * will update the values
 * Node that all the notification will be summited in a concurrent queue,
 * so it will be run in a concurrent thread
 *
 * this class is abstract, you have to extend it and implement the missing function
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

/**
 *  print a string with all the data present in this feature
 *
 *  @return <#return value description#>
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
 *  abstract method, build a feature that is exported by the node
 *
 *  @param node node that export this feature
 *
 *  @return pointer to a feature
 */
-(id) initWhitNode: (W2STSDKNode*)node;

/**
 *  abstract method, retrun an array of NSNumber with the data exported by the feature
 * note that the returned data is a copy of the internal state for avoid ghost update
 *
 *  @return array of NSNumber
 */
-(NSArray*) getFieldsData;

/**
 *  abstract method return an array of W2STSDKFeatureField that describe the data
 * returned by the getFieldData function
 *
 *  @return array of W2STSDKFeatureField that describe the data exported by the feature
 */
-(NSArray*) getFieldsDesc;

/**
 *  abstract method return the id of the last package received by this feature
 *
 *  @return id of the last package received by this feature
 */
-(uint32_t) getTimestamp;

@end

@protocol W2STSDKFeatureDelegate <NSObject>

/**
 *  method called every time we have new data from this feature
 *
 *  @param feature feature that was updated
 */
@required
- (void)didUpdateFeature:(W2STSDKFeature *)feature;

@end

@protocol W2STSDKFeatureLogDelegate <NSObject>


/**
 *  method called every time we have new data from this feature
 *
 *  @param feature feature that was updated
 *  @param raw     raw data used for extract the data for this feature
 *  @param data    array of NSNumber extracted by the raw data
 */
@required
- (void)feature:(W2STSDKFeature *)feature rawData:(NSData*)raw data:(NSArray*)data;
@end

#endif

