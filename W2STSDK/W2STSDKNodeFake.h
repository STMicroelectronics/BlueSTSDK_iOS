//
//  W2STSDKNodeFake.h
//  W2STSDK
//
//  Created by Giovanni Visentini on 19/05/15.
//  Copyright (c) 2015 STCentralLab. All rights reserved.
//

#import <W2STSDK/W2STSDK.h>

/**
 * this class overwrite the node method for avoid to use the bluethoot connection
 * and generate fake datas
 */
@interface W2STSDKNodeFake : W2STSDKNode

/**
 *  create a fake W2STSDKNode that doesn't use the bluethoot
 *
 *  @return pointer to a W2STSDK
 */
-(id)init;

@end
