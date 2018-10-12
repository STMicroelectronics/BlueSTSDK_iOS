/*******************************************************************************
 * COPYRIGHT(c) 2016 STMicroelectronics
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

#import <UIKit/UIKit.h>
#import "BlueSTSDKFwVersion.h"
#import "BlueSTSDK_LocalizeUtil.h"

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
        return nil;

    for (NSTextCheckingResult *match in matches) {
        if([match numberOfRanges]!=6)
            @throw [NSException exceptionWithName:BLUESTSDK_LOCALIZE(@"Invalid Version",nil)
                                           reason:BLUESTSDK_LOCALIZE(@"Format not Recognized",nil)
                                         userInfo:nil];

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

-(nonnull NSString*) getVersionNumberStr{
    return [NSString stringWithFormat:@"%ld.%ld.%ld",
            (long)_major, (long)_minor, (long)_patch];
}


@end
