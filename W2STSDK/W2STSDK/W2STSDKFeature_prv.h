//
//  W2STSDKFeature_prv.h
//  W2STSDK
//
//  Created by Giovanni Visentini on 19/05/15.
//  Copyright (c) 2015 STCentralLab. All rights reserved.
//

#ifndef W2STSDK_W2STSDKFeature_prv_h
#define W2STSDK_W2STSDKFeature_prv_h

#include "W2STSDKFeature.h"

/**
 * This interface contains the protected and packages method that can be used
 * inside the sdk
 * @author STMicroelectronics - Central Labs.
 */
@interface W2STSDKFeature(Prv)

//we redefine the property for be read write, when the user see it in read only
@property (readwrite,atomic) W2STSDKFeatureSample *lastSample;

/**
 * @protected
 *  initialize a feature
 *  @par protected function
 *  @param node node that export the feature
 *  @param name name of the feature
 *
 *  @return pointer to the feature
 */
-(instancetype) initWhitNode: (W2STSDKNode*)node name:(NSString*)name;

/**
 *  @protected
 * notify to all the registered delegate that the feature has update its data
 
 *  @par protected function
 *  @param sample new sample data that we want notify
 */
-(void) notifyUpdateWithSample:(W2STSDKFeatureSample*)sample;

/**
 * @protected
 *  notify to all the register delegate that a feature has been
 *  updated using some data
 
 *  @par protected function
 *  @param rawData raw data used for extract the new data
 *  @param data array of NSNumber extracted by raw data
 */
-(void) logFeatureUpdate:(NSData*)rawData sample:(W2STSDKFeatureSample*)sample;

/**
 *  @protected
 * send a command to this feature using the command characteristics
 *
 *  @par protected function
 *  @param commandType id of the command
 *  @param commandData optional data for the command
 *
 *  @return true if the command is correctly send to the node
 */
-(bool) sendCommand:(uint8_t)commandType data:(NSData*)commandData;

/**
 * @protected
 *  parse a command response, the default
 *  implementation is an empty method 
 *
 *  @par protected abstract function
 *  @param timestamp   response id
 *  @param commandType id of the command that generate the answer
 *  @param data        response data
 */
-(void) parseCommandResponseWithTimestamp:(uint32_t)timestamp
                              commandType:(uint8_t)commandType
                                     data:(NSData*)data;

/**
 *  @protected
 * write a data into the feature
 *
 *  @par protected function
 *  @param data data to write into the feature
 */
-(void)writeData:(NSData*)data;

///////package method////////////

/**
 * @package
 *  change the feature status
 *  @par package function
 *  @param enabled true if the node has this feature
 */
-(void) setEnabled:(bool)enabled;

/**
 *  This method is called by the CBPeriferal to notify an update
 *  @par package function
 *
 *  @param timestamp  package id
 *  @param data      raw data received by the node
 *  @param offset    offset where start to read the raw data
 *
 *  @return number of read byte
 */
-(uint32_t) update:(uint32_t)timestamp data:(NSData*)data dataOffset:(uint32_t)offset;

@end

#endif
