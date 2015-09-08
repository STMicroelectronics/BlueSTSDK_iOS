//
//  BlueSTSDKConfigControl.h
//
//  Created by Antonino Raucea on 06/15/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#ifndef BlueSTSDKConfigControl_h
#define BlueSTSDKConfigControl_h

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CBPeripheral.h>
#import <CoreBluetooth/CBCharacteristic.h>

#import "BlueSTSDKCommand.h"
#import "BlueSTSDKNode.h"

@protocol BlueSTSDKConfigControlDelegate;

/**
 * Class that manage the Config characteristics
 * @par
 * The class provides the read and write functions
 * to access the registers throws the {@link BlueSTSDKCommand} class
 *
 * @author STMicroelectronics - Central Labs.
 */
@interface BlueSTSDKConfigControl : NSObject

/**
 * node that will send the data to this class
 */
@property (readonly,strong) BlueSTSDKNode *node;


/**
 * Instance for Config Control class
 * @param node node that will be configurate
 * @param device CBPeripheral connection with the node
 * @param configControlChar CBCharacteristic used for access to the register
 */
+(instancetype)configControlWithNode:(BlueSTSDKNode *)node device:(CBPeripheral *)device
                  configControlChart:(CBCharacteristic*)configControlChar;

/**
 * Initialize for Config Control class
 * @param node node that will be configurate
 * @param device CBPeripheral connection with the node
 * @param configControlChar CBCharacteristic used for access to the register */
-(instancetype)initWithNode:(BlueSTSDKNode *)node device:(CBPeripheral *)device
         configControlChart:(CBCharacteristic*)configControlChar;

/**
 * Perfome a read operation
 *
 * @param cmd read command
 */
-(void)read:(BlueSTSDKCommand *)cmd;
/**
 * Perfome a write operation
 *
 * @param cmd write command
 */
-(void)write:(BlueSTSDKCommand *)cmd;

/**
 * add a new delegate for the update of this feature
 *
 * @param delegate delegate class
 */
-(void) addConfigDelegate:(id<BlueSTSDKConfigControlDelegate>)delegate;
/**
 * remove a delegate for the update of this feature
 *
 * @param delegate delegate to remove
 */
-(void) removeConfigDelegate:(id<BlueSTSDKConfigControlDelegate>)delegate;

@end

/** Protocol used for notification */
@protocol BlueSTSDKConfigControlDelegate
@required
/**
 *  called when it's received a command that contains a Read result
 *
 *  @param configControl instance that receive the command
 *  @param cmd   command
 *  @param error error condition
 */
-(void) configControl:(BlueSTSDKConfigControl *)configControl didRegisterReadResult:(BlueSTSDKCommand *)cmd error:(NSInteger)error;
/**
 *  called when it's received a command that contains a Write result
 *
 *  @param configControl instance that receive the command
 *  @param cmd   command
 *  @param error error condition
 */
-(void) configControl:(BlueSTSDKConfigControl *)configControl didRegisterWriteResult:(BlueSTSDKCommand *)cmd error:(NSInteger)error;
/**
 *  called when a request is done, to get the result
 *
 *  @param configControl instance that receive the command
 *  @param cmd   command
 *  @param success YES if the request is sent
 */
-(void) configControl:(BlueSTSDKConfigControl *)configControl didRequestResult:(BlueSTSDKCommand *)cmd success:(bool)success;
@end

#endif //BlueSTSDKConfigControl_h
