/*******************************************************************************
 * COPYRIGHT(c) 2015 STMicroelectronics
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

#ifndef BlueSTSDK_BlueSTSDKFeatureField_h
#define BlueSTSDK_BlueSTSDKFeatureField_h


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
    /**
     * Array of 8bit unsinged integer
     */
    BlueSTSDKFeatureFieldTypeUInt8Array,
    /**
     * Array of 16bit singed integer
     */
    BlueSTSDKFeatureFieldTypeInt16Array
};

/**
 *  field name
 */
@property (readonly) NSString * _Nonnull name;

/**
 *  data unit for the field
 */
@property (readonly)  NSString * _Nullable unit;

/**
 *  minimum field value
 */
@property (readonly) NSNumber * _Nonnull min;

/**
 *  maximum field value
 */
@property (readonly) NSNumber * _Nonnull max;

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
+(instancetype _Nonnull )createWithName:(NSString * _Nonnull)name
                                     unit:(NSString* _Nullable)unit
                                     type:(BlueSTSDKFeatureFieldType)type
                                      min:(NSNumber* _Nonnull)min
                                      max:(NSNumber* _Nonnull)max;

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
-(instancetype _Nonnull ) initWithName:(NSString *_Nonnull)name
              unit:(NSString* _Nullable)unit
              type:(BlueSTSDKFeatureFieldType)type
               min:(NSNumber* _Nonnull)min
               max:(NSNumber* _Nonnull)max;

-(BOOL)hasUnit;
@end

#endif
