//
//  BlueSTSDKFeatureField.h
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
@interface BlueSTSDKFeatureField : NSObject

/**
 *  enum with the possible data type exported by a feature
 */
typedef NS_ENUM(NSInteger, BlueSTSDKFeatureFieldType){
    /**
     *  32bit float number ieee 754 format
     */
    BlueSTSDKFeatureFieldTypeFloat,
    /**
     *  64bit float number ieee 754 format
     */
    BlueSTSDKFeatureFieldTypeDouble,
    /**
     *  64bit signed integer
     */
    BlueSTSDKFeatureFieldTypeInt64,
    /**
     *  32 bit unsigned integer
     */
    BlueSTSDKFeatureFieldTypeUInt32,
    /**
     *  32 bit signed integer
     */
    BlueSTSDKFeatureFieldTypeInt32,
    /**
     *  16bit unsigned integer
     */
    BlueSTSDKFeatureFieldTypeUInt16,
    /**
     *  16bit signed integer
     */
    BlueSTSDKFeatureFieldTypeInt16,
    /**
     *  8bit unsigned integer
     */
    BlueSTSDKFeatureFieldTypeUInt8,
    /**
     *  8bit signed integer
     */
    BlueSTSDKFeatureFieldTypeInt8,
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
@property (readonly) BlueSTSDKFeatureFieldType type;

/**
 *  instanziate an object of type BlueSTSDKFeatureFieldType
 *
 *  @param name field name
 *  @param unit field unit
 *  @param type numeric type used for store the field
 *  @param min  field min value
 *  @param max  field max value
 *
 *  @return object of type BlueSTSDKFeatureFieldType
 */
+(instancetype)createWithName:(NSString *)name
                                     unit:(NSString*)unit
                                     type:(BlueSTSDKFeatureFieldType)type
                                      min:(NSNumber*)min
                                      max:(NSNumber*)max;

/**
 *  initialize an object of type BlueSTSDKFeatureFieldType
 *
 *  @param name field name
 *  @param unit field unit
 *  @param type numeric type used for store the field
 *  @param min  field min value
 *  @param max  field max value
 *
 *  @return object of type BlueSTSDKFeatureFieldType
 */
-(instancetype) initWithName:(NSString *)name
              unit:(NSString*)unit
              type:(BlueSTSDKFeatureFieldType)type
               min:(NSNumber*)min
               max:(NSNumber*)max;


@end
