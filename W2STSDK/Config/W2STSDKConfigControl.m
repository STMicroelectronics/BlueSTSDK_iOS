//
//  W2STSDKConfigControl.c
//
//  Created by Antonino Raucea on 06/15/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "W2STSDKConfigControl_prv.h"


/**
 * concurrent queue used for notify the node update in different thread
 */
static dispatch_queue_t sNotificationQueue;

@implementation W2STSDKConfigControl {
    /**
     *  device that will send the information
     */
    CBPeripheral *mDevice;
    
    /**
     *  characteristic where we will read the stdout message
     */
    CBCharacteristic* mConfigControlChar;
    
    /**
     *  fifo structure that will contain the message that we will send until
     *  we don't have a write ack
     */
    //NSMutableArray *mWriteMessageQueue;
    /**
     *  set of delegate where notify changes in node status
     */
    NSMutableSet *mConfigControlDelegates;
}

+(id)configControlWithNode:(W2STSDKNode *)node device:(CBPeripheral *)device
configControlChart:(CBCharacteristic*)configControlChar {
    return [[W2STSDKConfigControl alloc] initWithNode:node device:device configControlChart:configControlChar];
}
-(id)initWithNode:(W2STSDKNode *)node device:(CBPeripheral *)device
         configControlChart:(CBCharacteristic*)configControlChar {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sNotificationQueue = dispatch_queue_create("W2STConfigControl", DISPATCH_QUEUE_CONCURRENT);
    });
    
    self = [super init];
    _node=node;
    mConfigControlChar=configControlChar;
    mDevice=device;
    mConfigControlDelegates = [NSMutableSet set];
    
    //mWriteMessageQueue = [NSMutableArray array];
    return self;
}

-(void)read:(W2STSDKCommand *)cmd {
    [self actionWithCommand:cmd read:YES];
}

-(void)write:(W2STSDKCommand *)cmd {
    [self actionWithCommand:cmd read:NO];
}

-(void)actionWithCommand:(W2STSDKCommand *)cmd read:(BOOL)read {
    if (cmd != nil && mDevice != nil && mConfigControlChar != nil) {
        NSData *tempData = read ? [cmd toReadPacket] : [cmd toWritePacket];
        [mDevice writeValue:tempData forCharacteristic:mConfigControlChar type:CBCharacteristicWriteWithResponse];
    }
}

/**
 * call the method onCommandReadResult for
 * each listener that subscribe to this feature.
 * <p> each call will be run in a different thread</p>
 * <p>
 * if you extend the method update you have to call this method after that you update the data
 * </p>
 */
-(void)notifyRead:(NSData *)data {
    W2STSDKCommand * cmd = [W2STSDKCommand commandWithData:data];
    NSInteger error = [W2STSDKRegister getErrorFromData:data];
    
    for (id<W2STSDKConfigControlDelegate> delegate in mConfigControlDelegates) {
        dispatch_async(sNotificationQueue,^{
            [delegate configControl:self didRegisterReadResult:cmd error:error];
        });
    }//for
}//notifyRead

/**
 * call the method onCommandWriteResult for
 * each listener that subscribe to this feature.
 * <p> each call will be run in a different thread</p>
 * <p>
 * if you extend the method update you have to call this method after that you update the data
 * </p>
 */
-(void)notifyWrite:(NSData *)data success:(BOOL)success {
    W2STSDKCommand * cmd = [W2STSDKCommand commandWithData:data];
    
    for (id<W2STSDKConfigControlDelegate> delegate in mConfigControlDelegates) {
        dispatch_async(sNotificationQueue,^{
            [delegate configControl:self didRegisterWriteResult:cmd success:success];
        });
    }//for
}//notifyWrite

-(void) addConfigDelegate:(id<W2STSDKConfigControlDelegate>)delegate {
    [mConfigControlDelegates addObject:delegate];
}
-(void) removeConfigDelegate:(id<W2STSDKConfigControlDelegate>)delegate {
    [mConfigControlDelegates removeObject:delegate];
}
@end