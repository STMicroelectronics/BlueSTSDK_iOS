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
#ifndef BlueSTSDK_NSData_NumberConversion_h
#define BlueSTSDK_NSData_NumberConversion_h

#import <Foundation/Foundation.h>

/**
 *  Add to the NSData class the method for convert a little endian byte array
 *  to numbers
 *
 * @author STMicroelectronics - Central Labs.
 */
@interface NSData(NumberConversion)

/**
 *  extract an uint8 from a byte array
 *
 *  @param offset byte position
 *
 *  @return (uint8_t)self[offset]
 */
-(uint8_t) extractUInt8FromOffset:(NSUInteger)offset;
-(int8_t) extractInt8FromOffset:(NSUInteger)offset;

/**
 *  extract a uint16 from a little endian byte array
 *
 *  @param offset position where of the first byte
 *
 *  @return uint16 build with the byte self[offset] and self[offset+1]
 */
-(uint16_t) extractLeUInt16FromOffset:(NSUInteger)offset;
-(uint16_t) extractBeUInt16FromOffset:(NSUInteger)offset;

/**
 *  extract an int16 from a little endian byte array
 *
 *  @param offset position of the first byte
 *
 *  @return int16 build with the byte self[offset] and self[offset+1]
 */
-(int16_t) extractLeInt16FromOffset:(NSUInteger)offset;

-(int16_t) extractBeInt16FromOffset:(NSUInteger)offset;

/**
 *  extract an int32 from a little endian byte array
 *
 *  @param offset position of the first byte
 *
 *  @return int32 build with the byte self[offset], self[offset+1],
 *      self[offset+2], self[offset+3]
 */
-(int32_t) extractLeInt32FromOffset:(NSUInteger)offset;
-(uint32_t) extractLeUInt32FromOffset:(NSUInteger)offset;

/**
 *  extract an uint32 from a big endian byte array
 *
 *  @param offset position of the first byte
 *
 *  @return uint32 build with the byte self[offset], self[offset+1],
 *      self[offset+2], self[offset+3]
 */
-(uint32_t) extractBeUInt32FromOffset:(NSUInteger)offset;
-(int32_t) extractBeInt32FromOffset:(NSUInteger)offset;

/**
 *  extract a float (32bit) number from a little endian byte array
 *
 *  @param offset position of the first byte
 *
 *  @return float build with the byte self[offset], self[offset+1],
 *      self[offset+2], self[offset+3]
 */
-(float) extractLeFloatFromOffset:(NSUInteger)offset;

-(NSData *)int16ChangeEndianes;

@end

#endif
