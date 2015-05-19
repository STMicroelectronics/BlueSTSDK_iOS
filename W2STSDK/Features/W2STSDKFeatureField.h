//
//  W2STSDKFeatureField.h
//  W2STApp
//
//  Created by Giovanni Visentini on 03/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, W2STSDKFeatureFieldType) {
    W2STSDKFeatureFieldTypeFloat,
    W2STSDKFeatureFieldTypeInt64,
    W2STSDKFeatureFieldTypeUInt32,
    W2STSDKFeatureFieldTypeInt32,
    W2STSDKFeatureFieldTypeUInt16,
    W2STSDKFeatureFieldTypeInt16,
    W2STSDKFeatureFieldTypeUInt8,
    W2STSDKFeatureFieldTypeInt8,
};

@interface W2STSDKFeatureField : NSObject

@property (readonly) NSString *name;
@property (readonly) NSString *unit;
@property (readonly) NSNumber *min;
@property (readonly) NSNumber *max;
@property (readonly) W2STSDKFeatureFieldType type;

+(W2STSDKFeatureField*)createWithName:(NSString *)name
                                     unit:(NSString*)unit
                                     type:(W2STSDKFeatureFieldType)type
                                      min:(NSNumber*)min
                                      max:(NSNumber*)max;

-(id) initWithName:(NSString *)name
              unit:(NSString*)unit
              type:(W2STSDKFeatureFieldType)type
               min:(NSNumber*)min
               max:(NSNumber*)max;


@end
