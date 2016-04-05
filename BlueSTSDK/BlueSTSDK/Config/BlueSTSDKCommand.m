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


+(instancetype)commandWithRegister:(BlueSTSDKRegister *)reg
                            target:(BlueSTSDKRegisterTarget_e)target {
    return [BlueSTSDKCommand commandWithRegister:reg target:target data:nil];
}

+(instancetype)commandWithRegister:(BlueSTSDKRegister *)reg
                            target:(BlueSTSDKRegisterTarget_e)target
                             value:(NSInteger)value
                          byteSize:(NSInteger)byteSize {
    NSData *locdata = [NSData dataWithBytes:(const void *)&value
                                     length:(byteSize <= 4 ? byteSize : 4)];
    return [BlueSTSDKCommand commandWithRegister:reg target:target data:locdata];
}


+(instancetype)commandWithRegister:(BlueSTSDKRegister *)reg
                            target:(BlueSTSDKRegisterTarget_e)target
                        valueFloat:(float)value {
    NSData *locdata = [NSData dataWithBytes:(const void *)&value
                                     length:sizeof(float)];
    return [BlueSTSDKCommand commandWithRegister:reg target:target data:locdata];
}


+(instancetype)commandWithRegister:(BlueSTSDKRegister *)reg
                            target:(BlueSTSDKRegisterTarget_e)target
                       valueString:(NSString *)str {
    NSData *locdata = [str dataUsingEncoding:NSASCIIStringEncoding];
    return [BlueSTSDKCommand commandWithRegister:reg target:target data:locdata];
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
