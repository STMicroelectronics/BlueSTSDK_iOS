//
//  BlueSTSDKManager.h
//  BlueSTSDK-CB
//
//  Created by Giovanni Visentini on 21/04/15.
//  Copyright (c) 2014 STMicroelectronics. All rights reserved.
//
#ifndef BlueSTSDK_BlueSTSDKManager_h
#define BlueSTSDK_BlueSTSDKManager_h

#import <Foundation/Foundation.h>


@class BlueSTSDKNode;

@protocol BlueSTSDKManagerDelegate;

/**
 * \relates BlueSTSDKManager
 *  Default scan time
 */
#define BlueSTSDKMANAGER_DEFAULT_SCANING_TIMEOUT_S 1.0f

/**
 *  Class that permit to discover new node that are compatible with the BlueSTSDK
 *  protocol
 * @author STMicroelectronics - Central Labs.
 */
NS_CLASS_AVAILABLE(10_7, 5_0)
@interface BlueSTSDKManager : NSObject

/**
 *  start a discovery process, it will stop after 
 * {@link BlueSTSDKMANAGER_DEFAULT_SCANING_TIMEOUT_S} seconds
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
 *  @param delegate class that implement the {@link BlueSTSDKManagerDelegate} protocol
 */
-(void)addDelegate:(id<BlueSTSDKManagerDelegate>)delegate;

/**
 *  remove a delegate
 *
 *  @param delegate delegate to remove
 */
-(void)removeDelegate:(id<BlueSTSDKManagerDelegate>)delegate;

/**
 *  get all the discovered nodes
 *
 *  @return array of {@link BlueSTSDKNode} with all the discovered nodes
 */
-(NSArray *) nodes;

/**
 *  tell if the manager is in a discovery state
 *
 *  @return true if the manager is in a discovery state
 */
-(BOOL) isDiscovering;

/**
 *  remove all the discovered nodes
 */
-(void) resetDiscovery;

/**
 *  search in the discovered node the one that has a particular name,
 *  @note the node name is not unique so we will return the first node that match the name
 *
 *  @param name node name to search
 *
 *  @return a node with the name, or nil if a node with that name doesn't exist
 */
-(BlueSTSDKNode *)nodeWithName:(NSString *)name;

/**
 *  search in the discovered node the one that has a particular tag
 *
 *  @param tag tag to search
 *
 *  @return a node with that tag or nil if the node doesn't exist
 */
-(BlueSTSDKNode *)nodeWithTag:(NSString *)tag;

/**
 *  add to a device a list of possible feature exported by the node
 *
 *  @param boardId  new board id or a board id that we want extend
 *  @param features map of new features add to the board, it is a dictionary of 
 * <{@link featureMask_t},BlueSTSDKFeature>
 * @throw and exception if the featureMask as more than one bit set to 1
 */
-(void)addFeatureForBoard:(uint8_t)boardId features:(NSDictionary*)features;

/**
 *  get the singleton instance of the manager
 *
 *  @return instance of the BlueSTSDKManager
 */
+ (instancetype)sharedInstance;

@end

/**
 *  Delegate interface, used for notify change in the manager state or the 
 *  discover of a new compatible node
 */
@protocol BlueSTSDKManagerDelegate <NSObject>
@required
/**
 *  function called when a new node is discovered
 *
 *  @param manager manager that discovered the node (the manger is a singleton,
 *    so this parameter is only for have a consistent method sign with the others delegate)
 *  @param node new node discovered
 */
- (void)manager:(BlueSTSDKManager *)manager didDiscoverNode:(BlueSTSDKNode *)node;

/**
 *  function called when the status of the manager change
 *
 *  @param manager manager that discovered the node (the manger is a singleton,
 *    so this parameter is only for have a consistent method sign with the others delegate)
 *  @param enable true if the manger start a scan process, false if it end the scanning
 */
- (void)manager:(BlueSTSDKManager *)manager didChangeDiscovery:(BOOL)enable;
@end

#endif
