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
 * This interface contains the protected and packages method that can be used inside the sdk
 */
@interface W2STSDKFeature(Prv)

/**
 *  protected method, initialize a feature
 *
 *  @param node node that export the feature
 *  @param name name of the feature
 *
 *  @return pointer to the feature
 */
-(id) initWhitNode: (W2STSDKNode*)node name:(NSString*)name;

/**
 *  protected method, notify to all the register delegate that the feature has 
 * been updated
 */
-(void) notifyUpdate;

/**
 *  protected method,notify to all the register delegate that a feature has been 
 *  updated using some data
 *
 *  @param rawData raw data used for extract the new data
 *  @param data array of NSNumber extracted by raw data
 */
-(void) logFeatureUpdate:(NSData*)rawData data:(NSArray*)data;

/**
 *  protected method, send a command to this feature
 *
 *  @param commandType id of the command
 *  @param commandData optional data for the command
 *
 *  @return true if the command is correctly send to the node
 */
-(BOOL) sendCommand:(uint8_t)commandType data:(NSData*)commandData;

/**
 *  protected abstract method, parse a command response, the default 
 *  implementation is an empty method
 *
 *  @param timestamp   response id
 *  @param commandType id of the command that generate the answer
 *  @param data        response data
 */
-(void) parseCommandResponseWithTimestamp:(uint32_t)timestamp
                              commandType:(uint8_t)commandType
                                     data:(NSData*)data;

/**
 *  protected method, write a data into the feature
 *
 *  @param data data to write into the feature
 */
-(void)writeData:(NSData*)data;

///////package method////////////

/**
 *  package method, change the feature status
 *
 *  @param enabled true if the node has this feature
 */
-(void) setEnabled:(bool)enabled;

/**
 *  package method, this method is called by the CBPeriferal notify an update
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
