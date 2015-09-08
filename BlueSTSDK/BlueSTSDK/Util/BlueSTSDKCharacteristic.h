//
//  BlueSTSDKCharacteristics.h
//  W2STApp
//
//  Created by Giovanni Visentini on 02/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import "../BlueSTSDKFeature.h"

/**
 *  A single ble characteristic can contains more than one feature, 
 * this class help to map a ble characteristic with its features
 * @author STMicroelectronics - Central Labs.
 */
@interface BlueSTSDKCharacteristic : NSObject

/**
 *  ble characteristic associated with this object
 */
@property(strong,nonatomic,readonly) CBCharacteristic* characteristic;

/**
 *  array of class that extend {@link BlueSTSDKFeature} that the characteristic export
 */
@property(strong,nonatomic,readonly) NSArray* features;

/**
 *  create a new characteristic manage by the sdk
 *
 *  @param charac   ble characteristic
 *  @param features array of BlueSTSDKFeature that are exported by this characteristic
 *
 *  @return object of type BlueSTSDKCharacteristic
 */
-(id) initWithChar:(CBCharacteristic*)charac features:(NSArray*)features;

/**
 *  find the features manage by a ble characteristic
 *
 *  @param characteristic   characteristic that we are searching
 *  @param CharFeatureArray array of BlueSTSDKCharacteristic where search
 *
 *  @return array BlueSTSDKFeature exported by that characteristic
 */
+(NSArray*) getFeaturesFromChar:(CBCharacteristic const*)characteristic
                             in:(NSArray*)CharFeatureArray;

/**
 *  find the characteristic that export a particular feature, if the feature is
 * exported by multiple characteristic we will return the characteristic that export
 * more features
 *
 *  @param feature          feature to search
 *  @param CharFeatureArray array of BlueSTSDKCharacteristic where search
 *
 *  @return ble characteristic that export that feature
 */
+(CBCharacteristic*) getCharFromFeature:(BlueSTSDKFeature*)feature
                                     in:(NSArray*)CharFeatureArray;
@end
