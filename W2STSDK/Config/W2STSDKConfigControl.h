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

/** TODO ADD DOC*/
@interface W2STSDKConfigControl : NSObject

/**
 *  node that export this config
 */
@property (readonly,strong) W2STSDKNode *node;

/** TODO ADD DOC*/
-(id)initWithNode:(W2STSDKNode *)node device:(CBPeripheral *)device configControlChart:(CBCharacteristic*)configControlChar;
-(void)read:(W2STSDKCommand *)cmd;
-(void)write:(W2STSDKCommand *)cmd;

-(void) addConfigDelegate:(id<W2STSDKConfigControlDelegate>)delegate;
-(void) removeConfigDelegate:(id<W2STSDKConfigControlDelegate>)delegate;

@end

/** TODO ADD DOC*/
@protocol W2STSDKConfigControlDelegate
@required
/** TODO ADD DOC*/
-(void) configControl:(W2STSDKConfigControl *) configControl didRegisterReadResult:(W2STSDKCommand *)cmd error:(NSInteger)error;
/** TODO ADD DOC*/
-(void) configControl:(W2STSDKConfigControl *) configControl didRegisterWriteResult:(W2STSDKCommand *)cmd success:(BOOL)success;
@end

#endif //W2STSDKConfigControl_h
