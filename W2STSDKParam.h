//
//  W2STSDKParam.h
//  W2STSDK-CB
//
//  Created by Antonino Raucea on 30/04/14.
//  Copyright (c) 2014 STMicroelectronics. All rights reserved.
//

#import "W2STSDKDefine.h"
#import "W2STSDKFeature.h"

@class W2STSDKNode;
@class W2STSDKFeature;

@interface W2STSDKParam : NSObject

/*
typedef NS_ENUM(NSUInteger, W2STSDKNodeParam) {
    W2STSDKNodeParamInvalid = 0xFFFFF,
    
    W2STSDKNodeParamHWAccX = (W2STSDKNodeFeatureHWAcce<<4) | 0x0, //Accelerometer X
    W2STSDKNodeParamHWAccY = (W2STSDKNodeFeatureHWAcce<<4) | 0x1, //Accelerometer Y
    W2STSDKNodeParamHWAccZ = (W2STSDKNodeFeatureHWAcce<<4) | 0x2, //Accelerometer Z
    W2STSDKNodeParamHWGyrX = (W2STSDKNodeFeatureHWGyro<<4) | 0x0, //Gyroscope X
    W2STSDKNodeParamHWGyrY = (W2STSDKNodeFeatureHWGyro<<4) | 0x1, //Gyroscope Y
    W2STSDKNodeParamHWGyrZ = (W2STSDKNodeFeatureHWGyro<<4) | 0x2, //Gyroscope Z
    W2STSDKNodeParamHWMagX = (W2STSDKNodeFeatureHWMagn<<4) | 0x0, //Magnetometer X
    W2STSDKNodeParamHWMagY = (W2STSDKNodeFeatureHWMagn<<4) | 0x1, //Magnetometer Y
    W2STSDKNodeParamHWMagZ = (W2STSDKNodeFeatureHWMagn<<4) | 0x2, //Magnetometer Z
    W2STSDKNodeParamHWPres = (W2STSDKNodeFeatureHWPres<<4) | 0x0, //Pressure
    W2STSDKNodeParamHWHumd = (W2STSDKNodeFeatureHWHumd<<4) | 0x0, //Humidity
    W2STSDKNodeParamHWTemp = (W2STSDKNodeFeatureHWTemp<<4) | 0x0, //Temperature
    W2STSDKNodeParamHWGgas = (W2STSDKNodeFeatureHWGgas<<4) | 0x0, //Gauge ??? Battery charger
    W2STSDKNodeParamHWRfid = (W2STSDKNodeFeatureHWRfid<<4) | 0x0, //RFID
    
    W2STSDKNodeParamSWAHRSX = (W2STSDKNodeFeatureSWAHRS<<4) | 0x0, //AHRS X
    W2STSDKNodeParamSWAHRSY = (W2STSDKNodeFeatureSWAHRS<<4) | 0x1, //AHRS Y
    W2STSDKNodeParamSWAHRSZ = (W2STSDKNodeFeatureSWAHRS<<4) | 0x2, //AHRS Z
    W2STSDKNodeParamSWAHRSW = (W2STSDKNodeFeatureSWAHRS<<4) | 0x3, //AHRS W
    W2STSDKNodeParamSWComp = (W2STSDKNodeFeatureSWComp<<4) | 0x0, //Compass
    W2STSDKNodeParamSWAltm = (W2STSDKNodeFeatureSWAltm<<4) | 0x0, //Altimeter
};
*/

typedef NS_ENUM(NSUInteger, W2STSDKNodeParam) {
    W2STSDKNodeParamInvalid = 0xFFFFF,
    
    W2STSDKNodeParamHWAccX = 0x10, //Accelerometer X
    W2STSDKNodeParamHWAccY = 0x11, //Accelerometer Y
    W2STSDKNodeParamHWAccZ = 0x12, //Accelerometer Z
    W2STSDKNodeParamHWGyrX = 0x20, //Gyroscope X
    W2STSDKNodeParamHWGyrY = 0x21, //Gyroscope Y
    W2STSDKNodeParamHWGyrZ = 0x22, //Gyroscope Z
    W2STSDKNodeParamHWMagX = 0x30, //Magnetometer X
    W2STSDKNodeParamHWMagY = 0x31, //Magnetometer Y
    W2STSDKNodeParamHWMagZ = 0x32, //Magnetometer Z
    W2STSDKNodeParamHWPres = 0x40, //Pressure
    W2STSDKNodeParamHWHumd = 0x50, //Humidity
    W2STSDKNodeParamHWTemp = 0x60, //Temperature
    W2STSDKNodeParamHWGgas = 0x70, //Gauge ??? Battery charger
    W2STSDKNodeParamHWRfid = 0x80, //RFID
    
    W2STSDKNodeParamSWAHRSX = 0x90, //AHRS X
    W2STSDKNodeParamSWAHRSY = 0x91, //AHRS Y
    W2STSDKNodeParamSWAHRSZ = 0x92, //AHRS Z
    W2STSDKNodeParamSWAHRSW = 0x93, //AHRS W
    W2STSDKNodeParamSWComp = 0xA0, //Compass
    W2STSDKNodeParamSWAltm = 0xB0, //Altimeter
};

W2STSDK_EXTERN NSString * const W2STSDKNodeParamInvalidKey;

W2STSDK_EXTERN NSString * const W2STSDKNodeParamHWAccelerometerXKey;
W2STSDK_EXTERN NSString * const W2STSDKNodeParamHWAccelerometerYKey;
W2STSDK_EXTERN NSString * const W2STSDKNodeParamHWAccelerometerZKey;
W2STSDK_EXTERN NSString * const W2STSDKNodeParamHWGyroscopeXKey;
W2STSDK_EXTERN NSString * const W2STSDKNodeParamHWGyroscopeYKey;
W2STSDK_EXTERN NSString * const W2STSDKNodeParamHWGyroscopeZKey;
W2STSDK_EXTERN NSString * const W2STSDKNodeParamHWMagnetometerXKey;
W2STSDK_EXTERN NSString * const W2STSDKNodeParamHWMagnetometerYKey;
W2STSDK_EXTERN NSString * const W2STSDKNodeParamHWMagnetometerZKey;
W2STSDK_EXTERN NSString * const W2STSDKNodeParamHWPressureKey;
W2STSDK_EXTERN NSString * const W2STSDKNodeParamHWHumidityKey;
W2STSDK_EXTERN NSString * const W2STSDKNodeParamHWTemperatureKey;
W2STSDK_EXTERN NSString * const W2STSDKNodeParamHWGasKey;
W2STSDK_EXTERN NSString * const W2STSDKNodeParamHWRfidKey;

W2STSDK_EXTERN NSString * const W2STSDKNodeParamSWAHRSXKey;
W2STSDK_EXTERN NSString * const W2STSDKNodeParamSWAHRSYKey;
W2STSDK_EXTERN NSString * const W2STSDKNodeParamSWAHRSZKey;
W2STSDK_EXTERN NSString * const W2STSDKNodeParamSWAHRSWKey;
W2STSDK_EXTERN NSString * const W2STSDKNodeParamSWCompassKey;
W2STSDK_EXTERN NSString * const W2STSDKNodeParamSWAltimeterKey;


@property (readonly, assign, nonatomic) NSDate * lastUpdate __deprecated;

@property (readonly, assign, nonatomic) double value __deprecated;
@property (readonly, assign, nonatomic) NSInteger rawValue __deprecated;
@property (readonly, assign, nonatomic) NSInteger time __deprecated;

@property (retain, nonatomic) NSData *data __deprecated;

@property (retain, nonatomic) NSString *name __deprecated;
@property (retain, nonatomic) NSString *shortName __deprecated;

@property (retain, nonatomic) NSString *key __deprecated;
@property (assign, readonly) W2STSDKNodeParam map __deprecated;
@property (retain, nonatomic) W2STSDKFeature *feature __deprecated;
//@property (retain, nonatomic) NSString *keyFeature;
@property (retain, nonatomic) W2STSDKNode * node __deprecated;


-(id)init:(NSString *)key feature:(W2STSDKFeature *)feature node:(W2STSDKNode *)node __deprecated;
-(NSUInteger)updateData:(NSData *)data position:(NSUInteger)pos time:(NSUInteger)time __deprecated;
-(NSNumber *)numberValue:(BOOL)rawDataMode __deprecated;
-(NSString *)stringValue __deprecated;

+(void)initStatic __deprecated;
+(NSArray *)allKeys __deprecated;

+(NSString *)keyFeature:(NSString *)key __deprecated;
+(NSString *)nameByKey:(NSString *)key mode:(NSString *)mode __deprecated; 
+(W2STSDKNodeParam)mapLookup:(NSString *)key __deprecated;

@end
