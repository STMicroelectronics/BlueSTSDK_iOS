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
 *  print on the NSLog console when a node change his status
 */
@interface W2STSDKNodeStatusNSLog : NSObject<W2STSDKNodeStateDelegate>

@end
