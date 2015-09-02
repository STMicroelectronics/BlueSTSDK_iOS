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
     *  set of delegate where notify changes in node status
     */
    NSMutableSet *mConfigControlDelegates;
}

+(instancetype)configControlWithNode:(W2STSDKNode *)node device:(CBPeripheral *)device
                  configControlChart:(CBCharacteristic*)configControlChar {
    return [[W2STSDKConfigControl alloc] initWithNode:node device:device configControlChart:configControlChar];
}
-(instancetype)initWithNode:(W2STSDKNode *)node device:(CBPeripheral *)device
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
    
    [mDevice setNotifyValue:YES forCharacteristic:configControlChar];
    
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
    if (cmd != nil && cmd.registerField != nil && mDevice != nil && mConfigControlChar != nil) {
        NSData *tempData = read ? [cmd toReadPacket] : [cmd toWritePacket];
        [mDevice writeValue:tempData forCharacteristic:mConfigControlChar type:CBCharacteristicWriteWithResponse];
    }
}

/**
 * call the method to notify to each
 * each delegate that subscribe to this feature.
 * <p> each call will be run in a different thread</p>
 */
-(void)characteristicsUpdate:(CBCharacteristic *)characteristic {
    NSData *data = characteristic.value;
    W2STSDKCommand * cmd = [W2STSDKCommand commandWithData:data];
    NSInteger error = [W2STSDKRegister getErrorFromData:data];
    bool readOperation = [W2STSDKRegister isReadOperationFromData:data];
    
    for (id<W2STSDKConfigControlDelegate> delegate in mConfigControlDelegates) {
        dispatch_async(sNotificationQueue,^{
            if (readOperation) {
                [delegate configControl:self didRegisterReadResult:cmd error:error];
            }
            else {
                [delegate configControl:self didRegisterWriteResult:cmd error:error];
            }
        });
    }//for
    
}//characteristicsUpdate

/**
 * call the method to notify to each
 * each delegate that subscribe to this feature.
 * <p> each call will be run in a different thread</p>
 */
-(void)characteristicsWriteUpdate:(CBCharacteristic *)characteristic success:(bool)success {
    NSData *data = characteristic.value;
    W2STSDKCommand * cmd = [W2STSDKCommand commandWithData:data];
    
    for (id<W2STSDKConfigControlDelegate> delegate in mConfigControlDelegates) {
        dispatch_async(sNotificationQueue,^{
            [delegate configControl:self didRequestResult:cmd success:success];
        });
    }//for
    
}//characteristicsUpdate


-(void) addConfigDelegate:(id<W2STSDKConfigControlDelegate>)delegate {
    if (![mConfigControlDelegates containsObject:delegate])
    {
        [mConfigControlDelegates addObject:delegate];
    }
}
-(void) removeConfigDelegate:(id<W2STSDKConfigControlDelegate>)delegate {
    if ([mConfigControlDelegates containsObject:delegate])
    {
        [mConfigControlDelegates removeObject:delegate];
    }
}
@end