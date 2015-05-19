//
//  W2STSDKDebug.m
//  W2STApp
//
//  Created by Giovanni Visentini on 21/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "W2STSDKDebug_prv.h"

#import "Util/W2STSDKBleNodeDefines.h"

@implementation W2STSDKDebug{
    CBPeripheral *mDevice;
    CBCharacteristic* mTermChar;
    CBCharacteristic* mErrChar;
    NSMutableArray *mWriteMessageQueue;
}

-(id) initWithNode:(W2STSDKNode *)node device:(CBPeripheral *)device
         termChart:(CBCharacteristic*)termChar
          errChart:(CBCharacteristic*)errChar{
    _node=node;
    mTermChar=termChar;
    mErrChar=errChar;
    mDevice=device;
    mWriteMessageQueue = [NSMutableArray array];
    return self;
}

-(void) writeMessage:(NSString*)msg{
    [mWriteMessageQueue addObject:msg];
    NSData *tempData = [msg dataUsingEncoding:NSASCIIStringEncoding];
    [mDevice writeValue:tempData forCharacteristic:mTermChar type:CBCharacteristicWriteWithResponse];
}

@synthesize delegate = _delegate;

-(id<W2STSDKDebugOutputDelegate>) getDelegate{
    id<W2STSDKDebugOutputDelegate> ret=nil;
    @synchronized(self){
        ret = _delegate;
    }
    return ret;
}

-(void) setDelegate:(id<W2STSDKDebugOutputDelegate>)delegate{
    @synchronized(self){
        _delegate=delegate;
        BOOL enable = delegate!=nil;
        [mDevice setNotifyValue:enable forCharacteristic:mTermChar];
        [mDevice setNotifyValue:enable forCharacteristic:mErrChar];
    }
}

//package method
-(void)receiveCharacteristicsWriteUpdate:(CBCharacteristic*)termChar error:(NSError *)error{
    if(self.delegate == nil)
        return;
    NSString *temp = mWriteMessageQueue.firstObject;
    [mWriteMessageQueue removeObjectAtIndex:0];
    if([termChar.UUID isEqual:W2STSDKServiceDebug.termUuid]){
        [self.delegate debug:self didStdInSend: temp error:error];
    }
}
-(void)receiveCharacteristicsUpdate:(CBCharacteristic*)termChar{
    if(self.delegate == nil)
        return;
    NSString *temp = [[NSString alloc]initWithData:termChar.value encoding:NSUTF8StringEncoding];
    if([termChar.UUID isEqual:W2STSDKServiceDebug.termUuid]){
        [self.delegate debug:self didStdOutRecived: temp];
    }else if([termChar.UUID isEqual:W2STSDKServiceDebug.stdErrUuid]){
        [self.delegate debug:self didStdErrRecived: temp];
    }
}
@end
