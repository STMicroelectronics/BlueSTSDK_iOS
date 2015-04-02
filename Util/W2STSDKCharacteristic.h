//
//  W2STSDKCharacteristics.h
//  W2STApp
//
//  Created by Giovanni Visentini on 02/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface W2STSDKCharacteristic : NSObject

@property CBCharacteristic* characteristic;
@property NSArray* features;

-(id) initWithChar:(CBCharacteristic*)characteristics features:(NSArray*)features;

+(NSArray*) getFeaturesFromChar:(CBCharacteristic*)characteristic in:(NSArray*)CharFeatureArray;

@end
