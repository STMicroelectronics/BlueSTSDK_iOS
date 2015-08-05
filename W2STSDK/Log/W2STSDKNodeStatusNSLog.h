//
//  W2STSDKNSLogNodeStatus.h
//  W2STApp
//
//  Created by Giovanni Visentini on 09/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "W2STSDKNode.h"

/**
 * class that implement the {@link W2STSDKNodeStateDelegate} and print on the NSLog
 * stream the node status update
 * @author STMicroelectronics - Central Labs.
 */
@interface W2STSDKNodeStatusNSLog : NSObject<W2STSDKNodeStateDelegate>

@end
