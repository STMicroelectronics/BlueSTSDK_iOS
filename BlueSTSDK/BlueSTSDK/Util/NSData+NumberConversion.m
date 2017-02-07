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

#import "NSData+NumberConversion.h"

@implementation NSData(NumberConversion)

-(uint8_t) extractUInt8FromOffset:(NSUInteger)offset{
    NSRange range = NSMakeRange(offset, 1);
    uint8_t temp;
    [self getBytes:&temp range:range];
    return temp;
}

-(int8_t) extractInt8FromOffset:(NSUInteger)offset{
    return (int8_t)[self extractUInt8FromOffset:offset];
}

-(uint16_t) extractLeUInt16FromOffset:(NSUInteger)offset{
    NSRange range = NSMakeRange(offset, 2);
    uint16_t temp;
    [self getBytes:&temp range:range];
    return temp;
}

-(int16_t) extractLeInt16FromOffset:(NSUInteger)offset{
    return (int16_t)[self extractLeUInt16FromOffset:offset];
}

-(uint16_t) extractBeUInt16FromOffset:(NSUInteger)offset{
    NSRange range = NSMakeRange(offset, 2);
    uint16_t leInt;
    [self getBytes:&leInt range:range];
    uint16_t beInt=0;
    beInt |= (0x00FF & leInt) << 8;
    beInt |= (0xFF00 & leInt) >> 8;
    return beInt;
}

-(int16_t) extractBeInt16FromOffset:(NSUInteger)offset{
    return (int16_t)[self extractLeUInt16FromOffset:offset];
}

-(uint32_t) extractBeUInt32FromOffset:(NSUInteger)offset{
    NSRange range = NSMakeRange(offset, 4);
    uint32_t leInt;
    [self getBytes:&leInt range:range];
    
    uint32_t beInt=0;
    beInt |= (0x000000FF & leInt) << 24;
    beInt |= (0x0000FF00 & leInt) << 8;
    beInt |= (0x00FF0000 & leInt) >> 8;
    beInt |= (0xFF000000 & leInt) >> 24;
    return beInt;
}

-(int32_t) extractBeInt32FromOffset:(NSUInteger)offset{
    return (int32_t) [self extractBeUInt32FromOffset:offset];
}

-(int32_t) extractLeInt32FromOffset:(NSUInteger)offset{
    NSRange range = NSMakeRange(offset, 4);
    int32_t temp;
    [self getBytes:&temp range:range];
    return temp;
}

-(uint32_t) extractLeUInt32FromOffset:(NSUInteger)offset{
    return (uint32_t)[self extractLeInt32FromOffset:offset];
}

-(float) extractLeFloatFromOffset:(NSUInteger)offset{
    NSRange range = NSMakeRange(offset, 4);
    float temp;
    [self getBytes:&temp range:range];
    return temp;
}

- (NSData *)int16ChangeEndianes {
    NSMutableData *out = [NSMutableData dataWithCapacity:self.length];
    NSUInteger nByte = out.length;
    const uint8_t *inBuf = self.bytes;
    uint8_t *outBuf = out.mutableBytes;
    for(int i=0;i<nByte;i+=2){
        outBuf[i+1]=inBuf[i];
        outBuf[i]=inBuf[i+1];
    }
    return out;
}


@end

