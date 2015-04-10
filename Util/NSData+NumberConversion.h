//
//  NSData+NumberConversion.h
//  W2STApp
//
//  Created by Giovanni Visentini on 10/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData(NumberConversion)

-(uint16_t) extractLeUInt16FromOffset:(NSUInteger)offset;
-(int32_t) extractLeInt32FromOffset:(NSUInteger)offset;

-(float) extractLeFloatFromOffset:(NSUInteger)offset;


@end
