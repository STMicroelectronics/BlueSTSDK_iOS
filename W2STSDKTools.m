//
//  W2STSDKTools.m
//  W2STSDK
//
//  Created by Antonino Raucea on 06/06/14.
//  Copyright (c) 2014 STMicroelectronics. All rights reserved.
//

#import "W2STSDKTools.h"

NSString * const W2STSDKNodeChangeGenericKey   = @"";
NSString * const W2STSDKNodeChangeAddedKey     = @"Added";
NSString * const W2STSDKNodeChangeUpdatedKey   = @"Updated";
NSString * const W2STSDKNodeChangeDeadKey      = @"Dead";
NSString * const W2STSDKNodeChangeResumedKey   = @"Resumed";
NSString * const W2STSDKNodeChangeDeletedKey   = @"Deleted";

NSString * const W2STSDKNodeChangeRSSIVal      = @"RSSI";
NSString * const W2STSDKNodeChangeDataVal      = @"Data";
NSString * const W2STSDKNodeChangeConfigVal    = @"Config";
NSString * const W2STSDKNodeChangeAdvertisementVal = @"Advertisement";
NSString * const W2STSDKNodeChangeAllVal       = @"All";
NSString * const W2STSDKNodeChangeTxPowerVal   = @"TxPower";


@implementation W2STSDKTools

//tools
+(void) trace:(CBPeripheral *)peripheral text:(NSString *)text {
    NSLog(@"%@ %@ %@", text, peripheral.name, [W2STSDKNode stateStr:peripheral]);
}
+(void) tracePeripherals:(NSArray *)peripherals text:(NSString *)text {
    NSLog(@"Peripherals");
    for (CBPeripheral * peripheral in peripherals)
    {
        NSLog(@"%@ %@ %@", text, peripheral.name, [W2STSDKNode stateStr:peripheral]);
    }
}

// field = key,val
+(NSString *)nodeChangeComponentsStr:(NSString *)str field:(NSString *)field {
    BOOL keyRequired = [field isEqual:@"key"];
    NSString *ret = keyRequired ? W2STSDKNodeChangeGenericKey : @"";
    if (![str isEqual:@""]) {
        NSArray *components = [str componentsSeparatedByString:@":"];
        ret = keyRequired ? components[0] : @"";
        if (!keyRequired && ([components count] > 1)) {
            ret = components[1];
        }
    }
    return ret;
}
+(NSString *)nodeChangeMakeStr:(NSString *)key val:(NSString *)val {
    NSString *ret = [[NSString alloc] initWithFormat:@"%@:%@", key, val];
    return ret;
}

@end
