//
//  BlueSTSDKNSLogNodeStatus.h
//  W2STApp
//
//  Created by Giovanni Visentini on 09/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BlueSTSDKNode.h"

/**
 * class that implement the {@link BlueSTSDKNodeStateDelegate} and print on the NSLog
 * stream the node status update
 * @author STMicroelectronics - Central Labs.
 */
@interface BlueSTSDKNodeStatusNSLog : NSObject<BlueSTSDKNodeStateDelegate>

@end
