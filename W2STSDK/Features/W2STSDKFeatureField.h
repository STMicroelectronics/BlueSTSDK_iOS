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

/**
 *  this class describe a feature data field
 */
@interface W2STSDKFeatureField : NSObject

/**
 *  field name
 */
@property (readonly) NSString *name;

/**
 *  data unit for the field
 */
@property (readonly) NSString *unit;

/**
 *  minimum field value
 */
@property (readonly) NSNumber *min;

/**
 *  maximum field value
 */
@property (readonly) NSNumber *max;

/**
 *  type used for store the field value
 */
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
