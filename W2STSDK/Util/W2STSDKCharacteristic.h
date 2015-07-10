//
//  W2STSDKCharacteristics.h
//  W2STApp
//
//  Created by Giovanni Visentini on 02/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import "../W2STSDKFeature.h"

/**
 *  A single ble characteristic can contains more than one feature, 
 * this class help to map a ble characteristic with its features
 */
@interface W2STSDKCharacteristic : NSObject

/**
 *  ble characteristic associated with this object
 */
@property(strong,nonatomic,readonly) CBCharacteristic* characteristic;

/**
 *  array of class that extend \link{W2STSDKFeature} that the characteristic export
 */
@property(strong,nonatomic,readonly) NSArray* features;

/**
 *  create a new characteristic manage by the sdk
 *
 *  @param charac   ble characteristic
 *  @param features array of W2STSDKFeature that are exported by this characteristic
 *
 *  @return object of type W2STSDKCharacteristic
 */
-(id) initWithChar:(CBCharacteristic*)charac features:(NSArray*)features;

/**
 *  find the features manage by a ble characteristic
 *
 *  @param characteristic   characteristic that we are serching
 *  @param CharFeatureArray array of W2STSDKCharacteristic where search
 *
 *  @return array W2STSDKFeature exported by that characteristic
 */
+(NSArray*) getFeaturesFromChar:(CBCharacteristic const*)characteristic
                             in:(NSArray*)CharFeatureArray;

/**
 *  find the characteristic that export a particular feature, if the feature is
 * exported by multiple characteristic we will return the characteristic that export
 * more features
 *
 *  @param feature          feature to search
 *  @param CharFeatureArray array of W2STSDKCharacteristic where search
 *
 *  @return ble characteristic that export that feature
 */
+(CBCharacteristic*) getCharFromFeature:(W2STSDKFeature*)feature
                                     in:(NSArray*)CharFeatureArray;
@end
