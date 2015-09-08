//
//  BlueSTSDKNodeFake.h
//  BlueSTSDK
//
//  Created by Giovanni Visentini on 19/05/15.
//  Copyright (c) 2015 STCentralLab. All rights reserved.
//

#import <BlueSTSDK/BlueSTSDK.h>

/**
 * this class overwrite the node method for avoid to use the bluethoot connection
 * and generate fake datas
 * @note it is automaticaly created and add in the manager list if the application
 * is run inside the emulator
 * @author STMicroelectronics - Central Labs.
 */
@interface BlueSTSDKNodeFake : BlueSTSDKNode

/**
 *  create a fake BlueSTSDKNode that doesn't use the bluethoot
 *
 *  @return pointer to a BlueSTSDKNode
 */
-(instancetype)init;

@end
