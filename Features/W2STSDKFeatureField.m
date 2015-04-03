//
//  W2STSDKFeatureField.m
//  W2STApp
//
//  Created by Giovanni Visentini on 03/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "W2STSDKFeatureField.h"

@implementation W2STSDKFeatureField

+(W2STSDKFeatureField *)createWithName:(NSString *)name unit:(NSString *)unit type:(W2STSDKFeatureFieldType)type min:(NSNumber *)min max:(NSNumber *)max{
    W2STSDKFeatureField *temp = [W2STSDKFeatureField alloc];
    return [temp initWithName:name unit:unit type:type min:min max:max];
}


-(id) initWithName:(NSString *)name
              unit:(NSString*)unit
              type:(W2STSDKFeatureFieldType)type
               min:(NSNumber*)min
               max:(NSNumber*)max{
    _name=name;
    _unit=unit;
    _type=type;
    _min=min;
    _max=max;
    return self;
}

@end
