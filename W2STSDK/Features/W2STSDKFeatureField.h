//
//  W2STSDKFeatureField.h
//  W2STApp
//
//  Created by Giovanni Visentini on 03/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import <Foundation/Foundation.h>



/**
 * This class describe a feature data field
 * @author STMicroelectronics - Central Labs.
 */
@interface W2STSDKFeatureField : NSObject

/**
 *  enum with the possible data type exported by a feature
 */
typedef NS_ENUM(NSInteger, W2STSDKFeatureFieldType){
    /**
     *  32bit float number ieee 754 format
     */
    W2STSDKFeatureFieldTypeFloat,
    /**
     *  64bit signed integer
     */
    W2STSDKFeatureFieldTypeInt64,
    /**
     *  32 bit unsigned integer
     */
    W2STSDKFeatureFieldTypeUInt32,
    /**
     *  32 bit signed integer
     */
    W2STSDKFeatureFieldTypeInt32,
    /**
     *  16bit unsigned integer
     */
    W2STSDKFeatureFieldTypeUInt16,
    /**
     *  16bit signed integer
     */
    W2STSDKFeatureFieldTypeInt16,
    /**
     *  8bit unsigned integer
     */
    W2STSDKFeatureFieldTypeUInt8,
    /**
     *  8bit signed integer
     */
    W2STSDKFeatureFieldTypeInt8,
};

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

/**
 *  instanziate an object of type W2STSDKFeatureFieldType
 *
 *  @param name field name
 *  @param unit field unit
 *  @param type numeric type used for store the field
 *  @param min  field min value
 *  @param max  field max value
 *
 *  @return object of type W2STSDKFeatureFieldType
 */
+(instancetype)createWithName:(NSString *)name
                                     unit:(NSString*)unit
                                     type:(W2STSDKFeatureFieldType)type
                                      min:(NSNumber*)min
                                      max:(NSNumber*)max;

/**
 *  initialize an object of type W2STSDKFeatureFieldType
 *
 *  @param name field name
 *  @param unit field unit
 *  @param type numeric type used for store the field
 *  @param min  field min value
 *  @param max  field max value
 *
 *  @return object of type W2STSDKFeatureFieldType
 */
-(instancetype) initWithName:(NSString *)name
              unit:(NSString*)unit
              type:(W2STSDKFeatureFieldType)type
               min:(NSNumber*)min
               max:(NSNumber*)max;


@end
