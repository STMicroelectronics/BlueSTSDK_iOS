//
//  NSData+NumberConversion.h
//  W2STApp
//
//  Created by Giovanni Visentini on 10/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  add to the NSData class the method for convert a little/big entian byte array
 *  to numbers
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

/**
 *  extract a uint16 from a little endian byte array
 *
 *  @param offset position where of the first byte
 *
 *  @return uint16 build with the byte self[offset] and self[offset+1]
 */
-(uint16_t) extractLeUInt16FromOffset:(NSUInteger)offset;

/**
 *  extract an int16 from a little endian byte array
 *
 *  @param offset position of the first byte
 *
 *  @return int16 build with the byte self[offset] and self[offset+1]
 */
-(int16_t) extractLeInt16FromOffset:(NSUInteger)offset;

/**
 *  extract an int32 from a little endian byte array
 *
 *  @param offset position of the first byte
 *
 *  @return int32 build with the byte self[offset], self[offset+1],
 *      self[offset+2], self[offset+3]
 */
-(int32_t) extractLeInt32FromOffset:(NSUInteger)offset;

/**
 *  extract an uint32 from a big endian byte array
 *
 *  @param offset position of the first byte
 *
 *  @return uint32 build with the byte self[offset], self[offset+1],
 *      self[offset+2], self[offset+3]
 */
-(uint32_t) extractBeUInt32FromOffset:(NSUInteger)offset;

/**
 *  extract a float (32bit) number from a little endian byte array
 *
 *  @param offset position of the first byte
 *
 *  @return float build with the byte self[offset], self[offset+1],
 *      self[offset+2], self[offset+3]
 */
-(float) extractLeFloatFromOffset:(NSUInteger)offset;


@end
