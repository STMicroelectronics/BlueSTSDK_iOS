//
//  W2STSDKNodeFake.h
//  W2STSDK
//
//  Created by Giovanni Visentini on 19/05/15.
//  Copyright (c) 2015 STCentralLab. All rights reserved.
//

#import <W2STSDK/W2STSDK.h>

@interface W2STSDKNodeFake : W2STSDKNode


@property (retain, readonly) NSString *name;
/**
 *  unique string that identify the node
 */
@property (retain, readonly) NSString *tag;

/**
 *  tx power used from the board
 */
@property (retain, readonly) NSNumber *txPower;


-(id)init;

@end
