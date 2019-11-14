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

#import "BlueSTSDK/BlueSTSDK-Swift.h"
#import "BlueSTSDKDebug_prv.h"

#define MAX_MESSAGE_LENGTH 20

/**
 *  concurrent queue used for notify the update in different threads
 */
static dispatch_queue_t sNotificationQueue;

@interface BlueSTSDKDebug ()
/**
 *  set of delegate where notify the feature update
 */
@property(readonly,atomic,retain) NSMutableSet<id<BlueSTSDKDebugOutputDelegate>> *consoleDelegates;

@end

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
    NSMutableArray<NSData*> *mWriteMessageQueue;
    
    NSData *mLastFastSendMsg;
    
}

-(instancetype) initWithNode:(BlueSTSDKNode *)node periph:(CBPeripheral *)periph
         termChart:(CBCharacteristic*)termChar
          errChart:(CBCharacteristic*)errChar{
    static dispatch_once_t onceToken;
    //the first time we create the queue and the formatter that are sheared
    //between all the nodes
    dispatch_once(&onceToken, ^{
        sNotificationQueue = dispatch_queue_create("BlueSTSDKDebug", DISPATCH_QUEUE_SERIAL);
    });
    _parentNode=node;
    _consoleDelegates = [NSMutableSet set];
    mTermChar=termChar;
    mErrChar=errChar;
    mPeriph=periph;
    mWriteMessageQueue = [NSMutableArray<NSData*> array];
    return self;
}

-(void) addDebugOutputDelegate:(id<BlueSTSDKDebugOutputDelegate>)delegate{
    if(delegate==nil)
        return;
    @synchronized(_consoleDelegates){
        [_consoleDelegates addObject:delegate];
        if(_consoleDelegates.count==1){
            [mPeriph setNotifyValue:true forCharacteristic:mTermChar];
            [mPeriph setNotifyValue:true forCharacteristic:mErrChar];
        }
    }
}
-(void) removeDebugOutputDelegate:(id<BlueSTSDKDebugOutputDelegate>)delegate{
    if(delegate==nil)
        return;
    @synchronized(_consoleDelegates){
        [_consoleDelegates removeObject:delegate];
        if(_consoleDelegates.count==0){
            [mPeriph setNotifyValue:false forCharacteristic:mTermChar];
            [mPeriph setNotifyValue:false forCharacteristic:mErrChar];
        }
    }
    
}

-(void)sendFirstMessage{
    NSData *fistPart = mWriteMessageQueue.firstObject;
    [mPeriph writeValue:fistPart forCharacteristic:mTermChar type:CBCharacteristicWriteWithResponse];
}

-(NSUInteger) writeMessage:(NSString*)msg{
    NSData *tempData = [BlueSTSDKDebug stringToData:msg];
    return [self writeMessageData:tempData];
}

- (NSUInteger)writeMessageData:(NSData *)data {
    uint8_t packageData[MAX_MESSAGE_LENGTH];
    uint32_t offset =0;
    @synchronized (mWriteMessageQueue) {
        BOOL isEmptyQueue = mWriteMessageQueue.count==0;
        while(offset+MAX_MESSAGE_LENGTH < data.length){
            [data getBytes:packageData range:NSMakeRange(offset, MAX_MESSAGE_LENGTH)];
            NSData *dataToSend = [NSData dataWithBytes:packageData length:MAX_MESSAGE_LENGTH];
            offset+=MAX_MESSAGE_LENGTH;
            [mWriteMessageQueue addObject:dataToSend];
        }

        NSUInteger length=data.length - offset;
        if(length!=0) {
            [data getBytes:packageData range:NSMakeRange(offset, length)];
            NSData *dataToSend = [NSData dataWithBytes:packageData length:length];
            [mWriteMessageQueue addObject:dataToSend];
        }
        if(isEmptyQueue) {
            [self sendFirstMessage];
        }
    }
    return data.length;
}

- (BOOL)writeMessageDataFast:(NSData *)data {
    mLastFastSendMsg = data;
    NSString *sentMsgStr = [BlueSTSDKDebug dataToString:data];
    if(_parentNode.state==BlueSTSDKNodeStateConnected) {
        [mPeriph writeValue:data forCharacteristic:mTermChar type:CBCharacteristicWriteWithoutResponse];
        @synchronized (_consoleDelegates) {
            for(id<BlueSTSDKDebugOutputDelegate> delegate in _consoleDelegates){
                dispatch_async(sNotificationQueue, ^{
                    [delegate debug:self didStdInSend:sentMsgStr error:nil];
                });
            }//for
        }//sync
        return true;
    } else{
        return false;
    }
}


///////////////////DEPRECATED///////////////////////////////////////////////////
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
        if(enable)
           [self addDebugOutputDelegate:delegate];
        else
           [self removeDebugOutputDelegate:delegate];
    }//setDelegate
}

///////////////////END DEPRECATED///////////////////////////////////////////////

#pragma mark - BlueSTSDKDebug(Prv)

-(void)receiveCharacteristicsWriteUpdate:(CBCharacteristic*)termChar
                                   error:(NSError *)error{
    if(_consoleDelegates.count == 0)
        return;
    //if the write comes from an our characteristics
    if(termChar.isDebugTermCharacteristic){
        //remove the message from the queue and sent the callback
        NSData *sentMsg=nil;
       
        @synchronized (mWriteMessageQueue) {
            if(mWriteMessageQueue.count!=0){
                sentMsg = mWriteMessageQueue.firstObject;
                [mWriteMessageQueue removeObjectAtIndex:0];
                if (mWriteMessageQueue.count != 0)
                    [self sendFirstMessage];
            }else{
                sentMsg=mLastFastSendMsg;
            }
        }
        if(sentMsg==nil)
            return;
         
        NSString *sentMsgStr = [BlueSTSDKDebug dataToString:sentMsg];
        if(_consoleDelegates.count==0)
            return;
        @synchronized (_consoleDelegates) {
            for(id<BlueSTSDKDebugOutputDelegate> delegate in _consoleDelegates){
                dispatch_async(sNotificationQueue,^{
                    [delegate debug:self didStdInSend:sentMsgStr error:error];
                });
            }//for
        }//sync
    }
}

-(void)receiveCharacteristicsUpdate:(CBCharacteristic*)termChar{
    if(_consoleDelegates.count==0)
        return;
    NSString *temp = [BlueSTSDKDebug dataToString:termChar.value];
    if(termChar.isDebugTermCharacteristic){
        @synchronized (_consoleDelegates) {
            for(id<BlueSTSDKDebugOutputDelegate> delegate in _consoleDelegates){
                dispatch_async(sNotificationQueue,^{
                    [delegate debug:self didStdOutReceived: temp];
                });
            }//for
        }//sync
    }else if(termChar.isDebugErrorCharacteristic){
        @synchronized (_consoleDelegates) {
            for(id<BlueSTSDKDebugOutputDelegate> delegate in _consoleDelegates){
                dispatch_async(sNotificationQueue,^{
                    [delegate debug:self didStdErrReceived: temp];
                });
            }//for
        }//sync
    }//if-else
}
@end
