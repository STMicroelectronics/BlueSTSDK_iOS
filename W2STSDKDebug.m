//
//  W2STSDKDebug.m
//  W2STApp
//
//  Created by Giovanni Visentini on 21/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "W2STSDKDebug.h"

#import "Util/W2STSDKBleNodeDefines.h"

@implementation W2STSDKDebug{
    CBPeripheral *mDevice;
    CBCharacteristic* mTermChar;
    CBCharacteristic* mErrChar;
}

-(id) initWithNode:(W2STSDKNode *)node device:(CBPeripheral *)device
         termChart:(CBCharacteristic*)termChar
          errChart:(CBCharacteristic*)errChar{
    _node=node;
    mTermChar=termChar;
    mErrChar=errChar;
    mDevice=device;
    return self;
}

-(void) writeMessage:(NSString*)msg{
    NSData *tempData = [msg dataUsingEncoding:NSUTF8StringEncoding];
    [mDevice writeValue:tempData forCharacteristic:mTermChar type:CBCharacteristicWriteWithResponse];
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
-(void)receiveCharacteristicsWriteUpdate:(CBCharacteristic*)termChar status:(BOOL) status{
    if(_delegate == nil)
        return;
    NSString *temp = [[NSString alloc]initWithData:termChar.value encoding:NSUTF8StringEncoding];
    if([termChar.UUID isEqual:W2STSDKServiceDebug.termUuid]){
        [_delegate debug:self didStdInSend: temp status:status];
    }
}
-(void)receiveCharacteristicsUpdate:(CBCharacteristic*)termChar{
    if(_delegate == nil)
        return;
    NSString *temp = [[NSString alloc]initWithData:termChar.value encoding:NSUTF8StringEncoding];
    if([termChar.UUID isEqual:W2STSDKServiceDebug.termUuid]){
        [_delegate debug:self didStdOutRecived: temp];
    }else if([termChar.UUID isEqual:W2STSDKServiceDebug.stdErrUuid]){
        [_delegate debug:self didStdErrRecived: temp];
    }
}
@end
