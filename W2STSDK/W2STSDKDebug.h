//
//  W2STSDKDebug.h
//  W2STApp
//
//  Created by Giovanni Visentini on 21/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//
#ifndef W2STApp_W2STSDKDebug_h
#define W2STApp_W2STSDKDebug_h

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CBPeripheral.h>
#import <CoreBluetooth/CBCharacteristic.h>

#import "W2STSDKNode.h"

@protocol W2STSDKDebugOutputDelegate;

/**
 *  class that permit to read and write from the debug node console
 */
@interface W2STSDKDebug : NSObject

/**
 *  node that export this console
 */
@property (readonly,strong) W2STSDKNode* node;

/**
 *  delegate used for notify new message in the console
 */
@property (nonatomic,weak,setter=setDelegate:,getter=getDelegate) id<W2STSDKDebugOutputDelegate> delegate;

/**
 *  create a debug console
 *
 *  @param node     node that export the
 *  @param device   device associated to the node
 *  @param termChar characteristic where write and read the console message
 *  @param errChar  characteristic where receive the error messages
 *
 *  @return pointer to a W2STSDKDebug class
 */
-(id) initWithNode:(W2STSDKNode *)node device:(CBPeripheral *)device
         termChart:(CBCharacteristic*)termChar
          errChart:(CBCharacteristic*)errChar;

/**
 *  send a message to the debug console
 *
 *  @param msg message to write in the node debug console
 */
-(void) writeMessage:(NSString*)msg;

@end

@protocol W2STSDKDebugOutputDelegate
@required
/**
 *  called when we receive a message that the node write in the stdout stream
 *
 *  @param debug class that receive the message
 *  @param msg   message
 */
-(void) debug:(W2STSDKDebug*)debug didStdOutRecived:(NSString*) msg;

/**
 *  called when we receive a message that the node write in the stderr stream
 *
 *  @param debug class that receive the message
 *  @param msg   message
 */
-(void) debug:(W2STSDKDebug*)debug didStdErrRecived:(NSString*) msg;

/**
 *  called when we successfully send a message to the node stdin
 *
 *  @param debug class that send the message
 *  @param msg   message send
 *  @param error if present an error with the reason why the sending fail
 */
-(void) debug:(W2STSDKDebug*)debug didStdInSend:(NSString*) msg error:(NSError*)error;
@end

#endif
