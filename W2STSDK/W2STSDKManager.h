//
//  W2STSDKManager.h
//  W2STSDK-CB
//
//  Created by Antonino Raucea on 02/04/14.
//  Copyright (c) 2014 STMicroelectronics. All rights reserved.
//
#ifndef W2STSDK_W2STSDKManager_h
#define W2STSDK_W2STSDKManager_h

#import <Foundation/Foundation.h>


@class W2STSDKNode;

@protocol W2STSDKManagerDelegate;


#define W2STSDKMANAGER_DEFAULT_SCANING_TIMEOUT_S 1.0f

/**
 *  Class that permit to discover new node that are compatible with the w2stsdk
 *  protocol
 */
@interface W2STSDKManager : NSObject

/**
 *  start a discovery process, it will stop after few seconds
 */
-(void)discoveryStart;

/**
 *  start a discovery process that will scan for a new device for
 *
 *  @param timeoutMs milliseconds to wait before stop the scanning
 */
-(void)discoveryStart:(int)timeoutMs;

/**
 *  stop the discovery process
 */
-(void)discoveryStop;

/**
 *  add a delegate where the class will notify a change of status or a new node 
 *  discovered.
 *
 *  you can register multiple delegate, the call back will be done in a concurrent queue
 *
 *  @param delegate class that implement the W2STSDKManagerDelegate protocol
 */
-(void)addDelegate:(id<W2STSDKManagerDelegate>)delegate;

/**
 *  remove a delegate
 *
 *  @param delegate delegate to remove
 */
-(void)removeDelegate:(id<W2STSDKManagerDelegate>)delegate;

/**
 *  get all the discovered nodes
 *
 *  @return array of W2STSDKNode with all the discovery nodes
 */
-(NSArray *) nodes;

/**
 *  tell if the manager is in a discovery state
 *
 *  @return true if the manager is in a discovery state
 */
-(BOOL) isDiscovering;

/**
 *  remove all the dicovered nodes
 */
-(void) resetDiscovery;

/**
 *  search in the discovered node the one that has a particular name,
 *    the node is not unique so we will return the first node the match the name
 *
 *  @param name node name to search
 *
 *  @return a node with the name, or nil if a node with that name doesn't exist
 */
-(W2STSDKNode *)nodeWithName:(NSString *)name;

/**
 *  search in the discovered node the one that has a particular tag
 *
 *  @param tag tag to search
 *
 *  @return a node with that tag or nil if the node doesn't exist
 */
-(W2STSDKNode *)nodeWithTag:(NSString *)tag;

/**
 *  get the singleton instance of the manager
 *
 *  @return instance of the W2STSDKManager
 */
+ (W2STSDKManager *)sharedInstance;

@end

@protocol W2STSDKManagerDelegate <NSObject>
@required
/**
 *  function called when a new node is discovered
 *
 *  @param manager manager that discovered the node (the manger is a singleton,
 *    so this parameter is only for have a consistent method sign with the others delegate)
 *  @param node new node discovered
 */
- (void)manager:(W2STSDKManager *)manager didDiscoverNode:(W2STSDKNode *)node;

/**
 *  function called when the status of the manager change
 *
 *  @param manager manager that discovered the node (the manger is a singleton,
 *    so this parameter is only for have a consistent method sign with the others delegate)
 *  @param enable  true if the manger start a scan process, false if it end the scanning
 */
- (void)manager:(W2STSDKManager *)manager didChangeDiscovery:(BOOL)enable;
@end

#endif