//
//  W2STSDKNSLogNodeStatus.m
//  W2STApp
//
//  Created by Giovanni Visentini on 09/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "W2STSDKNodeStatusNSLog.h"

@implementation W2STSDKNodeStatusNSLog

/**
 *  print the node update on the NSLog console
 */
- (void) node:(W2STSDKNode *)node didChangeState:(W2STSDKNodeState)newState
    prevState:(W2STSDKNodeState)prevState{

    NSLog(@"Node:%@ from:%@ to %@",node.name,
          [W2STSDKNode stateToString: prevState],
          [W2STSDKNode stateToString: newState]);

}//didChangeState


@end
