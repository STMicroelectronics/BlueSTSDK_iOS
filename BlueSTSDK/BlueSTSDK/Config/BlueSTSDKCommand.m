//
//  BlueSTSDKCommand.c
//
//  Created by Antonino Raucea on 06/15/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "BlueSTSDKCommand.h"
#import "BlueSTSDKCommand_prv.h"

@implementation BlueSTSDKCommand


-(instancetype)initWithRegister:(BlueSTSDKRegister *)reg
                         target:(BlueSTSDKRegisterTarget_e)target
                           data:(NSData *)data {
    self = [[BlueSTSDKCommand alloc] init];
    self.registerField = reg;
    self.target = target;
    self.data = data;
    return self;
}

+(instancetype)commandWithRegister:(BlueSTSDKRegister *)reg
                            target:(BlueSTSDKRegisterTarget_e)target
                              data:(NSData *)data {
    return [[BlueSTSDKCommand alloc] initWithRegister:reg target:target data:data];
}

+(instancetype)commandWithRegisterName:(BlueSTSDKRegisterName_e)name
                                target:(BlueSTSDKRegisterTarget_e)target
                                  data:(NSData *)data {
    return [BlueSTSDKCommand commandWithRegister:
            [BlueSTSDKRegisterDefines lookUpWithRegisterName:name]
                                        target:target
                                          data:data];
}

+(instancetype)commandWithRegister:(BlueSTSDKRegister *)reg
                            target:(BlueSTSDKRegisterTarget_e)target {
    return [BlueSTSDKCommand commandWithRegister:reg target:target data:nil];
}
+(instancetype)commandWithRegisterName:(BlueSTSDKRegisterName_e)name
                                target:(BlueSTSDKRegisterTarget_e)target {
    return [BlueSTSDKCommand commandWithRegister:
            [BlueSTSDKRegisterDefines lookUpWithRegisterName:name] target:target];
}
+(instancetype)commandWithRegister:(BlueSTSDKRegister *)reg
                            target:(BlueSTSDKRegisterTarget_e)target
                             value:(NSInteger)value
                          byteSize:(NSInteger)byteSize {
    NSData *locdata = [NSData dataWithBytes:(const void *)&value
                                     length:(byteSize <= 4 ? byteSize : 4)];
    return [BlueSTSDKCommand commandWithRegister:reg target:target data:locdata];
}

+(instancetype)commandWithRegisterName:(BlueSTSDKRegisterName_e)name
                                target:(BlueSTSDKRegisterTarget_e)target
                                 value:(NSInteger)value
                              byteSize:(NSInteger)byteSize {
    return [BlueSTSDKCommand commandWithRegister:
            [BlueSTSDKRegisterDefines lookUpWithRegisterName:name]
                                        target:target
                                         value:value
                                      byteSize:byteSize];
}

+(instancetype)commandWithRegister:(BlueSTSDKRegister *)reg
                            target:(BlueSTSDKRegisterTarget_e)target
                        valueFloat:(float)value {
    NSData *locdata = [NSData dataWithBytes:(const void *)&value
                                     length:sizeof(float)];
    return [BlueSTSDKCommand commandWithRegister:reg target:target data:locdata];
}

+(instancetype)commandWithRegisterName:(BlueSTSDKRegisterName_e)name
                                target:(BlueSTSDKRegisterTarget_e)target
                            valueFloat:(float)value {
    return [BlueSTSDKCommand commandWithRegister:
            [BlueSTSDKRegisterDefines lookUpWithRegisterName:name]
                                        target:target
                                    valueFloat:value];
}

+(instancetype)commandWithRegister:(BlueSTSDKRegister *)reg
                            target:(BlueSTSDKRegisterTarget_e)target
                       valueString:(NSString *)str {
    NSData *locdata = [str dataUsingEncoding:NSASCIIStringEncoding];
    return [BlueSTSDKCommand commandWithRegister:reg target:target data:locdata];
}

+(instancetype)commandWithRegisterName:(BlueSTSDKRegisterName_e)name
                                target:(BlueSTSDKRegisterTarget_e)target
                           valueString:(NSString *)str {
    return [BlueSTSDKCommand commandWithRegister:
            [BlueSTSDKRegisterDefines lookUpWithRegisterName:name]
                                        target:target
                                   valueString:str];
}

+(instancetype)commandWithData:(NSData *)dataReceived{
    BlueSTSDKRegister *reg = [BlueSTSDKRegister registerWithData:dataReceived];
    BlueSTSDKRegisterTarget_e target = [BlueSTSDKRegister getTargetFromData:dataReceived];
    NSData *payload = [BlueSTSDKRegister getPayloadFromData:dataReceived];
    
    return [BlueSTSDKCommand commandWithRegister:reg target:target data:payload];
}

-(NSData *)toWritePacket {
    return [self.registerField toWritePacketWithTarget:self.target payloadData:self.data];
}
-(NSData *)toReadPacket {
    return [self.registerField toReadPacketWithTarget:self.target];
}
@end
