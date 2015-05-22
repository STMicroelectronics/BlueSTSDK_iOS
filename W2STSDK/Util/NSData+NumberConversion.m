//
//  NSData+NumberConversion.m
//  W2STApp
//
//  Created by Giovanni Visentini on 10/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "NSData+NumberConversion.h"

@implementation NSData(NumberConversion)

-(uint8_t) extractUInt8FromOffset:(NSUInteger)offset{
    NSRange range = NSMakeRange(offset, 1);
    uint8_t temp;
    [self getBytes:&temp range:range];
    return temp;
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

-(int32_t) extractLeInt32FromOffset:(NSUInteger)offset{
    NSRange range = NSMakeRange(offset, 4);
    int32_t temp;
    [self getBytes:&temp range:range];
    return temp;
}

-(float) extractLeFloatFromOffset:(NSUInteger)offset{
    NSRange range = NSMakeRange(offset, 4);
    float temp;
    [self getBytes:&temp range:range];
    return temp;
}

@end

