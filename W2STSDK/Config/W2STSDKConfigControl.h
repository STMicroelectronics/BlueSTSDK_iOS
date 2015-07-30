//
//  W2STSDKConfigControl.h
//
//  Created by Antonino Raucea on 06/15/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#ifndef W2STSDKConfigControl_h
#define W2STSDKConfigControl_h

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CBPeripheral.h>
#import <CoreBluetooth/CBCharacteristic.h>

#import "W2STSDKCommand.h"
#import "W2STSDKNode.h"

@protocol W2STSDKConfigControlDelegate;

/**
 * Class that manage the Config characteristics
 * <p>
 * The class provides the read and write functions
 * to access the registers throws the {@link com.st.W2STSDK.Config.Command} class
 * </p>
 * @author STMicroelectronics - Central Labs.
 */
@interface W2STSDKConfigControl : NSObject

/**
 * node that will send the data to this class
 */
@property (readonly,strong) W2STSDKNode *node;


/**
 * Instance for Config Control class
 * @param node node that will be configurate
 * @param device CBPeripheral connection with the node
 * @param configControlChart CBCharacteristic used for access to the register
 */
+(id)configControlWithNode:(W2STSDKNode *)node device:(CBPeripheral *)device
        configControlChart:(CBCharacteristic*)configControlChar;
/** TODO ADD DOC*/
-(id)initWithNode:(W2STSDKNode *)node device:(CBPeripheral *)device configControlChart:(CBCharacteristic*)configControlChar;
/**
 * Perfome a read operation
 *
 * @param cmd read command
 */
-(void)read:(W2STSDKCommand *)cmd;
/**
 * Perfome a write operation
 *
 * @param cmd write command
 */
-(void)write:(W2STSDKCommand *)cmd;

/**
 * add a new delegate for the update of this feature
 *
 * @param delegate delegate class
 */
-(void) addConfigDelegate:(id<W2STSDKConfigControlDelegate>)delegate;
/**
 * remove a delegate for the update of this feature
 *
 * @param delegate delegate to remove
 */
-(void) removeConfigDelegate:(id<W2STSDKConfigControlDelegate>)delegate;

@end

/** Protocol used for notification */
@protocol W2STSDKConfigControlDelegate
@required
/**
 *  called when it's received a command that contains a Read result
 *
 *  @param configControl instance that receive the command
 *  @param cmd   command
 *  @param error error condition
 */
-(void) configControl:(W2STSDKConfigControl *)configControl didRegisterReadResult:(W2STSDKCommand *)cmd error:(NSInteger)error;
/**
 *  called when it's received a command that contains a Write result
 *
 *  @param configControl instance that receive the command
 *  @param cmd   command
 *  @param error error condition
 */
-(void) configControl:(W2STSDKConfigControl *)configControl didRegisterWriteResult:(W2STSDKCommand *)cmd error:(NSInteger)error;
/**
 *  called when a request is done, to get the result
 *
 *  @param configControl instance that receive the command
 *  @param cmd   command
 *  @param success YES if the request is sent
 */
-(void) configControl:(W2STSDKConfigControl *)configControl didRequestResult:(W2STSDKCommand *)cmd success:(BOOL)success;
@end

#endif //W2STSDKConfigControl_h
