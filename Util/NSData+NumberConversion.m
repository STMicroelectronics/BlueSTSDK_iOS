//
//  NSData+NumberConversion.m
//  W2STApp
//
//  Created by Giovanni Visentini on 10/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "NSData+NumberConversion.h"

@implementation NSData(NumberConversion)

-(uint16_t) extractLeUInt16FromOffset:(NSUInteger)offset{
    NSRange range = NSMakeRange(offset, 2);
    uint16_t temp;
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

