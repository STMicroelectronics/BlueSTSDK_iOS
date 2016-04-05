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

#import "BlueSTSDKDebug_prv.h"

#import "Util/BlueSTSDKBleNodeDefines.h"

#define MAX_MESSAGE_LENGTH 20

@implementation BlueSTSDKDebug{
    /**
     *  peripheral that will send the information
     */
    CBPeripheral *mPeriph;
    
    /**
     *  characteristic where we will read the stdout message
     */
    CBCharacteristic* mTermChar;
    
    /**
     *  characteristics where we will read the error message
     */
    CBCharacteristic* mErrChar;
    
    /**
     *  fifo structure that will contain the message that we will send until 
     *  we don't have a write ack
     */
    NSMutableArray *mWriteMessageQueue;
}

-(instancetype) initWithNode:(BlueSTSDKNode *)node periph:(CBPeripheral *)periph
         termChart:(CBCharacteristic*)termChar
          errChart:(CBCharacteristic*)errChar{
    _parentNode=node;
    mTermChar=termChar;
    mErrChar=errChar;
    mPeriph=periph;
    mWriteMessageQueue = [NSMutableArray array];
    return self;
}

-(NSUInteger) writeMessage:(NSString*)msg{
    NSData *tempData = [msg dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t data[MAX_MESSAGE_LENGTH];
    NSUInteger length=MIN(MAX_MESSAGE_LENGTH,tempData.length);
    [tempData getBytes:data range:NSMakeRange(0, length)];
    NSData *dataToSend = [NSData dataWithBytes:data length:length];
    [mPeriph writeValue:dataToSend forCharacteristic:mTermChar type:CBCharacteristicWriteWithResponse];
    [mWriteMessageQueue addObject:[NSString stringWithUTF8String:dataToSend.bytes]];
    return length;
}

@synthesize delegate = _delegate;

-(id<BlueSTSDKDebugOutputDelegate>) getDelegate{
    id<BlueSTSDKDebugOutputDelegate> ret=nil;
    //made the operation atomic
    @synchronized(self){
        ret = _delegate;
    }//synchronized
    return ret;
}//getDelegate

/**
 *  set the new delegate and enable/disable the notification
 */
-(void) setDelegate:(id<BlueSTSDKDebugOutputDelegate>)delegate{
    //made the operation atomic
    @synchronized(self){
        _delegate=delegate;
        BOOL enable = delegate!=nil; //enable if !=nil, disable if ==nil
        [mPeriph setNotifyValue:enable forCharacteristic:mTermChar];
        [mPeriph setNotifyValue:enable forCharacteristic:mErrChar];
    }//setDelegate
}

#pragma mark - BlueSTSDKDebug(Prv)

-(void)receiveCharacteristicsWriteUpdate:(CBCharacteristic*)termChar
                                   error:(NSError *)error{
    if(self.delegate == nil)
        return;
    //if the write comes from an our characteristics
    if([termChar.UUID isEqual:BlueSTSDKServiceDebug.termUuid]){
        //remove the message from the queue and sent the callback
        NSString *temp = mWriteMessageQueue.firstObject;
        [mWriteMessageQueue removeObjectAtIndex:0];
        [self.delegate debug:self didStdInSend: temp error:error];
    }
}

-(void)receiveCharacteristicsUpdate:(CBCharacteristic*)termChar{
    if(self.delegate == nil)
        return;
    NSString *temp = [[NSString alloc]initWithData:termChar.value encoding:NSUTF8StringEncoding];
    if([termChar.UUID isEqual:BlueSTSDKServiceDebug.termUuid]){
        [self.delegate debug:self didStdOutReceived: temp];
    }else if([termChar.UUID isEqual:BlueSTSDKServiceDebug.stdErrUuid]){
        [self.delegate debug:self didStdErrReceived: temp];
    }
}
@end
