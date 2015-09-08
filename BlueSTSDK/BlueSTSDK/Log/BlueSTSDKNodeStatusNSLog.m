//
//  BlueSTSDKNSLogNodeStatus.m
//  W2STApp
//
//  Created by Giovanni Visentini on 09/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "BlueSTSDKNodeStatusNSLog.h"

@implementation BlueSTSDKNodeStatusNSLog

/**
 *  print the node update on the NSLog console
 */
- (void) node:(BlueSTSDKNode *)node didChangeState:(BlueSTSDKNodeState)newState
    prevState:(BlueSTSDKNodeState)prevState{

    NSLog(@"Node:%@ from:%@ to %@",node.name,
          [BlueSTSDKNode stateToString: prevState],
          [BlueSTSDKNode stateToString: newState]);

}//didChangeState


@end
