//
//  W2STSDKCommand.c
//
//  Created by Antonino Raucea on 06/15/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "W2STSDKCommand.h"
#import "W2STSDKCommand_prv.h"

@implementation W2STSDKCommand


-(id)initWithRegister:(W2STSDKRegister *)reg target:(W2STSDKRegisterTarget_e)target  data:(NSData *)data {
    self = [[W2STSDKCommand alloc] init];
    self.registerField = reg;
    self.target = target;
    self.data = data;
    return self;
}

+(id)commandWithRegister:(W2STSDKRegister *)reg target:(W2STSDKRegisterTarget_e)target  data:(NSData *)data {
    return [[W2STSDKCommand alloc] initWithRegister:reg target:target data:data];
}

+(id)commandWithRegisterName:(W2STSDKRegisterName_e)name target:(W2STSDKRegisterTarget_e)target  data:(NSData *)data {
    return [W2STSDKCommand commandWithRegister:[W2STSDKRegisterDefines lookUpWithRegisterName:name] target:target data:data];
}

+(id)commandWithRegister:(W2STSDKRegister *)reg target:(W2STSDKRegisterTarget_e)target {
    return [W2STSDKCommand commandWithRegister:reg target:target data:nil];
}
+(id)commandWithRegisterName:(W2STSDKRegisterName_e)name target:(W2STSDKRegisterTarget_e)target {
    return [W2STSDKCommand commandWithRegister:[W2STSDKRegisterDefines lookUpWithRegisterName:name] target:target];
}
+(id)commandWithRegister:(W2STSDKRegister *)reg target:(W2STSDKRegisterTarget_e)target value:(NSInteger)value byteSize:(NSInteger)byteSize {
    NSData *locdata = [NSData dataWithBytes:(const void *)&value length:(byteSize <= 4 ? byteSize : 4)];
    return [W2STSDKCommand commandWithRegister:reg target:target data:locdata];
}

+(id)commandWithRegisterName:(W2STSDKRegisterName_e)name target:(W2STSDKRegisterTarget_e)target value:(NSInteger)value byteSize:(NSInteger)byteSize {
    return [W2STSDKCommand commandWithRegister:[W2STSDKRegisterDefines lookUpWithRegisterName:name] target:target value:value byteSize:byteSize];
}

+(id)commandWithRegister:(W2STSDKRegister *)reg target:(W2STSDKRegisterTarget_e)target valueFloat:(float)value {
    NSData *locdata = [NSData dataWithBytes:(const void *)&value length:sizeof(float)];
    return [W2STSDKCommand commandWithRegister:reg target:target data:locdata];
}

+(id)commandWithRegisterName:(W2STSDKRegisterName_e)name target:(W2STSDKRegisterTarget_e)target valueFloat:(float)value {
    return [W2STSDKCommand commandWithRegister:[W2STSDKRegisterDefines lookUpWithRegisterName:name] target:target valueFloat:value];
}

+(id)commandWithRegister:(W2STSDKRegister *)reg target:(W2STSDKRegisterTarget_e)target valueString:(NSString *)str {
    NSData *locdata = [str dataUsingEncoding:NSASCIIStringEncoding];
    return [W2STSDKCommand commandWithRegister:reg target:target data:locdata];
}

+(id)commandWithRegisterName:(W2STSDKRegisterName_e)name target:(W2STSDKRegisterTarget_e)target valueString:(NSString *)str {
    return [W2STSDKCommand commandWithRegister:[W2STSDKRegisterDefines lookUpWithRegisterName:name] target:target valueString:str];
}

+(id)commandWithData:(NSData *)dataReceived{
    W2STSDKRegister *reg = [W2STSDKRegister registerWithData:dataReceived];
    W2STSDKRegisterTarget_e target = [W2STSDKRegister getTargetFromData:dataReceived];
    NSData *payload = [W2STSDKRegister getPayloadFromData:dataReceived];
    
    return [W2STSDKCommand commandWithRegister:reg target:target data:payload];
}

-(NSData *)toWritePacket {
    return [self.registerField toWritePacketWithTarget:self.target payloadData:self.data];
}
-(NSData *)toReadPacket {
    return [self.registerField toReadPacketWithTarget:self.target];
}
@end