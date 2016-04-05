/*******************************************************************************
 * COPYRIGHT(c) 2015 STMicroelectronics
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *   1. Redistributions of source code must retain the above copyright notice,
 *      this list of conditions and the following disclaimer.
 *   2. Redistributions in binary form must reproduce the above copyright notice,
 *      this list of conditions and the following disclaimer in the documentation
 *      and/or other materials provided with the distribution.
 *   3. Neither the name of STMicroelectronics nor the names of its contributors
 *      may be used to endorse or promote products derived from this software
 *      without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 ******************************************************************************/

#import "BlueSTSDKConfigControl_prv.h"


/**
 * concurrent queue used for notify the node update in different thread
 */
static dispatch_queue_t sNotificationQueue;

@implementation BlueSTSDKConfigControl {
    /**
     *  periph that will send the information
     */
    CBPeripheral *mPeriph;
    
    /**
     *  characteristic where we will read the stdout message
     */
    CBCharacteristic* mConfigControlChar;
    
    /**
     *  set of delegate where notify changes in node status
     */
    NSMutableSet *mConfigControlDelegates;
}

+(instancetype)configControlWithNode:(BlueSTSDKNode *)node periph:(CBPeripheral *)periph
                  configControlChart:(CBCharacteristic*)configControlChar {
    return [[BlueSTSDKConfigControl alloc] initWithNode:node periph:periph configControlChart:configControlChar];
}
-(instancetype)initWithNode:(BlueSTSDKNode *)node periph:(CBPeripheral *)periph
         configControlChart:(CBCharacteristic*)configControlChar {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sNotificationQueue = dispatch_queue_create("W2STConfigControl", DISPATCH_QUEUE_CONCURRENT);
    });
    
    self = [super init];
    _node=node;
    mConfigControlChar=configControlChar;
    mPeriph=periph;
    mConfigControlDelegates = [NSMutableSet set];
    
    [mPeriph setNotifyValue:YES forCharacteristic:configControlChar];
    
    //mWriteMessageQueue = [NSMutableArray array];
    return self;
}


-(void)read:(BlueSTSDKCommand *)cmd {
    [self actionWithCommand:cmd read:YES];
}

-(void)write:(BlueSTSDKCommand *)cmd {
    [self actionWithCommand:cmd read:NO];
}

-(void)actionWithCommand:(BlueSTSDKCommand *)cmd read:(BOOL)read {
    if (cmd != nil && cmd.registerField != nil && mPeriph != nil && mConfigControlChar != nil) {
        NSData *tempData = read ? [cmd toReadPacket] : [cmd toWritePacket];
        [mPeriph writeValue:tempData forCharacteristic:mConfigControlChar type:CBCharacteristicWriteWithResponse];
    }
}

/**
 * call the method to notify to each
 * each delegate that subscribe to this feature.
 * <p> each call will be run in a different thread</p>
 */
-(void)characteristicsUpdate:(CBCharacteristic *)characteristic {
    NSData *data = characteristic.value;
    BlueSTSDKCommand * cmd = [BlueSTSDKCommand commandWithData:data];
    NSInteger error = [BlueSTSDKRegister getErrorFromData:data];
    bool readOperation = [BlueSTSDKRegister isReadOperationFromData:data];
    
    for (id<BlueSTSDKConfigControlDelegate> delegate in mConfigControlDelegates) {
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
    BlueSTSDKCommand * cmd = [BlueSTSDKCommand commandWithData:data];
    
    for (id<BlueSTSDKConfigControlDelegate> delegate in mConfigControlDelegates) {
        dispatch_async(sNotificationQueue,^{
            [delegate configControl:self didRequestResult:cmd success:success];
        });
    }//for
    
}//characteristicsUpdate


-(void) addConfigDelegate:(id<BlueSTSDKConfigControlDelegate>)delegate {
    if (![mConfigControlDelegates containsObject:delegate])
    {
        [mConfigControlDelegates addObject:delegate];
    }
}
-(void) removeConfigDelegate:(id<BlueSTSDKConfigControlDelegate>)delegate {
    if ([mConfigControlDelegates containsObject:delegate])
    {
        [mConfigControlDelegates removeObject:delegate];
    }
}
@end
