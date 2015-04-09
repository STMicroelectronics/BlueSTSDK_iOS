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

@interface W2STSDKCharacteristic : NSObject

@property CBCharacteristic const* characteristic;
@property NSArray* features;

-(id) initWithChar:(CBCharacteristic const*)charac features:(NSArray*)features;

+(NSArray*) getFeaturesFromChar:(CBCharacteristic const*)characteristic in:(NSArray*)CharFeatureArray;
+(CBCharacteristic const*) getCharFromFeature:(W2STSDKFeature*)feature in:(NSArray*)CharFeatureArray;
@end
