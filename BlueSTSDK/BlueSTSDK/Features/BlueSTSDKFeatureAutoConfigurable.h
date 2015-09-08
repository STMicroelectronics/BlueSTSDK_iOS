//
//  BlueSTSDKFeatureAutoConfigurable.h
//  W2STApp
//
//  Created by Giovanni Visentini on 13/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

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
 * The status is notify using the didAutoConfigurationChange delegate callback
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
 *  @note the callback are done by an concurrent queue
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
