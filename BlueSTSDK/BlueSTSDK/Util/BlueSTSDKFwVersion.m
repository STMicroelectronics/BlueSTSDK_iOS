//
// Created by Giovanni Visentini on 07/07/16.
// Copyright (c) 2016 STMicroelectronics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlueSTSDKFwVersion.h"

#define PARSE_FW_VERSION @"(.*)_(.*)_(\\d+)\\.(\\d+)\\.(\\d+)"

@implementation BlueSTSDKFwVersion {

}
+ (instancetype)version:(NSString *)string {
    return [[BlueSTSDKFwVersion alloc] initWithVersion:string];
}

+(instancetype) versionMajor:(NSInteger)major
                       minor:(NSInteger)minor
                       patch:(NSInteger)patch{
    return [BlueSTSDKFwVersion versionWithName:nil
                                       mcuType:nil
                                         major:major
                                         minor:minor
                                         patch:patch];
}

+ (instancetype)versionWithName:(NSString *)name mcuType:(NSString *)mcuType major:(NSInteger)major minor:(NSInteger)minor patch:(NSInteger)patch {
    return [[BlueSTSDKFwVersion alloc] initWithName:name mcuType:mcuType major:major minor:minor patch:patch];
}

- (NSComparisonResult)compareVersion:(BlueSTSDKFwVersion *)version {
    long diff = _major-version.major;
    if(diff!=0)
        return diff>0 ? NSOrderedDescending : NSOrderedAscending;
    diff = _minor-version.minor;
    if(diff!=0)
        return diff>0 ? NSOrderedDescending : NSOrderedAscending;
    diff= _patch-version.patch;
    if(diff==0)
        return NSOrderedSame;
    else
        return diff>0 ? NSOrderedDescending : NSOrderedAscending;
}


-(instancetype)initWithName:(NSString *)name mcuType:(NSString *)mcuType major:(NSInteger)major minor:(NSInteger)minor patch:(NSInteger)patch {
    self = [super init];
    _name = name;
    _mcuType = mcuType;
    _major = major;
    _minor = minor;
    _patch = patch;
    return self;
}

-(instancetype)initWithVersion:(NSString *)str{
    self = [super init];
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:PARSE_FW_VERSION
                                                                           options:0
                                                                             error:&error];

    NSArray *matches = [regex matchesInString:str
                                      options:0
                                        range:NSMakeRange(0, [str length])];
    if([matches count]==0)
        @throw [NSException exceptionWithName:@"Invalid Version" reason:@"Format not Recognized" userInfo:nil];

    for (NSTextCheckingResult *match in matches) {
        if([match numberOfRanges]!=6)
            @throw [NSException exceptionWithName:@"Invalid Version" reason:@"Format not Recognized" userInfo:nil];

        NSRange fwTypeRange = [match rangeAtIndex:1];
        NSRange fwNameRage = [match rangeAtIndex:2];
        NSRange majoirRange = [match rangeAtIndex:3];
        NSRange minorRange = [match rangeAtIndex:4];
        NSRange patchRange = [match rangeAtIndex:5];
        _name = [str substringWithRange:fwNameRage];
        _mcuType = [str substringWithRange:fwTypeRange];
        _major = [[str substringWithRange:majoirRange] integerValue];
        _minor = [[str substringWithRange:minorRange] integerValue];
        _patch = [[str substringWithRange:patchRange] integerValue];
    }
    return self;
}

@end
