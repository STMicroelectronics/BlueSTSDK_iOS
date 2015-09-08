//
//  BlueSTSDKFeatureField.m
//  W2STApp
//
//  Created by Giovanni Visentini on 03/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "BlueSTSDKFeatureField.h"

@implementation BlueSTSDKFeatureField

+(instancetype)createWithName:(NSString *)name
                                  unit:(NSString *)unit
                                  type:(BlueSTSDKFeatureFieldType)type
                                   min:(NSNumber *)min
                                   max:(NSNumber *)max{
    
    return [[BlueSTSDKFeatureField alloc] initWithName:name
                                                unit:unit
                                                type:type
                                                 min:min
                                                 max:max];
}


-(instancetype) initWithName:(NSString *)name
              unit:(NSString*)unit
              type:(BlueSTSDKFeatureFieldType)type
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
