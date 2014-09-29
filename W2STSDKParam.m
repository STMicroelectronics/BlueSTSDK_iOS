//
//  W2STSDKParam.m
//  W2STSDK-CB
//
//  Created by Antonino Raucea on 30/04/14.
//  Copyright (c) 2014 STMicroelectronics. All rights reserved.
//

#import "W2STSDKParam.h"

@implementation W2STSDKParam

static NSArray * W2STSDKNodeParamKeys = nil;
static NSDictionary * W2STSDKNodeParamShortNames = nil;

NSString * const W2STSDKNodeParamInvalidKey = @"InvalidKey";

NSString * const W2STSDKNodeParamHWAccelerometerXKey = @"AccelerometerXKey";
NSString * const W2STSDKNodeParamHWAccelerometerYKey = @"AccelerometerYKey";
NSString * const W2STSDKNodeParamHWAccelerometerZKey = @"AccelerometerZKey";
NSString * const W2STSDKNodeParamHWGyroscopeXKey = @"GyroscopeXKey";
NSString * const W2STSDKNodeParamHWGyroscopeYKey = @"GyroscopeYKey";
NSString * const W2STSDKNodeParamHWGyroscopeZKey = @"GyroscopeZKey";
NSString * const W2STSDKNodeParamHWMagnetometerXKey = @"MagnetometerXKey";
NSString * const W2STSDKNodeParamHWMagnetometerYKey = @"MagnetometerYKey";
NSString * const W2STSDKNodeParamHWMagnetometerZKey = @"MagnetometerZKey";
NSString * const W2STSDKNodeParamHWPressureKey = @"PressureKey";
NSString * const W2STSDKNodeParamHWHumidityKey = @"HumidityKey";
NSString * const W2STSDKNodeParamHWTemperatureKey = @"TemperatureKey";
NSString * const W2STSDKNodeParamHWGasKey = @"GasKey";
NSString * const W2STSDKNodeParamHWRfidKey = @"RfidKey";

NSString * const W2STSDKNodeParamSWAHRSXKey = @"AHRSXKey";
NSString * const W2STSDKNodeParamSWAHRSYKey = @"AHRSYKey";
NSString * const W2STSDKNodeParamSWAHRSZKey = @"AHRSZKey";
NSString * const W2STSDKNodeParamSWAHRSWKey = @"AHRSWKey";
NSString * const W2STSDKNodeParamSWCompassKey = @"CompassKey";
NSString * const W2STSDKNodeParamSWAltimeterKey = @"AltimeterKey";


-(id)init:(NSString *)key feature:(W2STSDKFeature *)feature node:(W2STSDKNode *)node {
    
    //static dispatch_once_t onceToken;
    
    self = [super init];
    
    //dispatch_once(&onceToken, ^{ [W2STSDKParam initStatic]; });
    
    _feature = feature;
    _node = node;
    
    _value = 0;
    _rawValue = 0;
    _lastUpdate = nil;
    _data = nil;
    _key = key;
    _name = [W2STSDKParam nameByKey:key mode:@"norm"];
    _shortName = [W2STSDKParam nameByKey:key mode:@"short"];
    
    return self;
}

- (void)setKey:(NSString *)key {
    _key = key;
    _map = [W2STSDKParam mapLookup:key];
}
+(W2STSDKNodeParam)mapLookup:(NSString *)key {
    static NSMutableDictionary *dic =  nil;

    if (dic) {
        dic = [[NSMutableDictionary alloc] init];

        [dic setValue:[NSNumber numberWithInt:W2STSDKNodeParamHWAccX] forKey:W2STSDKNodeParamHWAccelerometerXKey];
        [dic setValue:[NSNumber numberWithInt:W2STSDKNodeParamHWAccY] forKey:W2STSDKNodeParamHWAccelerometerYKey];
        [dic setValue:[NSNumber numberWithInt:W2STSDKNodeParamHWAccZ] forKey:W2STSDKNodeParamHWAccelerometerZKey];
        [dic setValue:[NSNumber numberWithInt:W2STSDKNodeParamHWGyrX] forKey:W2STSDKNodeParamHWGyroscopeXKey];
        [dic setValue:[NSNumber numberWithInt:W2STSDKNodeParamHWGyrY] forKey:W2STSDKNodeParamHWGyroscopeYKey];
        [dic setValue:[NSNumber numberWithInt:W2STSDKNodeParamHWGyrZ] forKey:W2STSDKNodeParamHWGyroscopeZKey];
        [dic setValue:[NSNumber numberWithInt:W2STSDKNodeParamHWMagX] forKey:W2STSDKNodeParamHWMagnetometerXKey];
        [dic setValue:[NSNumber numberWithInt:W2STSDKNodeParamHWMagY] forKey:W2STSDKNodeParamHWMagnetometerYKey];
        [dic setValue:[NSNumber numberWithInt:W2STSDKNodeParamHWMagZ] forKey:W2STSDKNodeParamHWMagnetometerZKey];
        [dic setValue:[NSNumber numberWithInt:W2STSDKNodeParamHWPres] forKey:W2STSDKNodeParamHWPressureKey];
        [dic setValue:[NSNumber numberWithInt:W2STSDKNodeParamHWHumd] forKey:W2STSDKNodeParamHWHumidityKey];
        [dic setValue:[NSNumber numberWithInt:W2STSDKNodeParamHWTemp] forKey:W2STSDKNodeParamHWTemperatureKey];
        [dic setValue:[NSNumber numberWithInt:W2STSDKNodeParamHWGgas] forKey:W2STSDKNodeParamHWGasKey];
        [dic setValue:[NSNumber numberWithInt:W2STSDKNodeParamHWRfid] forKey:W2STSDKNodeParamHWRfidKey];
        
        [dic setValue:[NSNumber numberWithInt:W2STSDKNodeParamSWAHRSX] forKey:W2STSDKNodeParamSWAHRSXKey];
        [dic setValue:[NSNumber numberWithInt:W2STSDKNodeParamSWAHRSY] forKey:W2STSDKNodeParamSWAHRSYKey];
        [dic setValue:[NSNumber numberWithInt:W2STSDKNodeParamSWAHRSZ] forKey:W2STSDKNodeParamSWAHRSZKey];
        [dic setValue:[NSNumber numberWithInt:W2STSDKNodeParamSWAHRSW] forKey:W2STSDKNodeParamSWAHRSWKey];
        [dic setValue:[NSNumber numberWithInt:W2STSDKNodeParamSWComp] forKey:W2STSDKNodeParamSWCompassKey];
        [dic setValue:[NSNumber numberWithInt:W2STSDKNodeParamSWAltm] forKey:W2STSDKNodeParamSWAltimeterKey];
    }
    
    return (W2STSDKNodeParam)[dic[key] intValue];
}

+(void)initStatic {
    W2STSDKNodeParamKeys = @[
                        W2STSDKNodeParamHWAccelerometerXKey,
                        W2STSDKNodeParamHWAccelerometerYKey,
                        W2STSDKNodeParamHWAccelerometerZKey,
                        W2STSDKNodeParamHWGyroscopeXKey,
                        W2STSDKNodeParamHWGyroscopeYKey,
                        W2STSDKNodeParamHWGyroscopeZKey,
                        W2STSDKNodeParamHWMagnetometerXKey,
                        W2STSDKNodeParamHWMagnetometerYKey,
                        W2STSDKNodeParamHWMagnetometerZKey,
                        W2STSDKNodeParamHWPressureKey,
                        W2STSDKNodeParamHWHumidityKey,
                        W2STSDKNodeParamHWTemperatureKey,
                        W2STSDKNodeParamHWGasKey,
                        W2STSDKNodeParamHWRfidKey,
                        
                        W2STSDKNodeParamSWAHRSXKey,
                        W2STSDKNodeParamSWAHRSYKey,
                        W2STSDKNodeParamSWAHRSZKey,
                        W2STSDKNodeParamSWAHRSWKey,
                        W2STSDKNodeParamSWCompassKey,
                        W2STSDKNodeParamSWAltimeterKey,
                        
                        
                        ];
    W2STSDKNodeParamShortNames = @{
                        W2STSDKNodeParamHWAccelerometerXKey : @"Acc X",
                        W2STSDKNodeParamHWAccelerometerYKey : @"Acc Y",
                        W2STSDKNodeParamHWAccelerometerZKey : @"Acc Z",
                        W2STSDKNodeParamHWGyroscopeXKey : @"Gyro X",
                        W2STSDKNodeParamHWGyroscopeYKey : @"Gyro Y",
                        W2STSDKNodeParamHWGyroscopeZKey : @"Gyro Z",
                        W2STSDKNodeParamHWMagnetometerXKey : @"Magn X",
                        W2STSDKNodeParamHWMagnetometerYKey : @"Magn Y",
                        W2STSDKNodeParamHWMagnetometerZKey : @"Magn Z",
                        W2STSDKNodeParamHWPressureKey : @"Pressure",
                        W2STSDKNodeParamHWHumidityKey : @"Humidity",
                        W2STSDKNodeParamHWTemperatureKey : @"Temp",
                        W2STSDKNodeParamHWGasKey : @"GAS",
                        W2STSDKNodeParamHWRfidKey : @"RFID",
                        
                        W2STSDKNodeParamSWAHRSXKey : @"AHRS X",
                        W2STSDKNodeParamSWAHRSYKey : @"AHRS Y",
                        W2STSDKNodeParamSWAHRSZKey : @"AHRS Z",
                        W2STSDKNodeParamSWAHRSWKey : @"AHRS W",
                        W2STSDKNodeParamSWCompassKey : @"Compass",
                        W2STSDKNodeParamSWAltimeterKey : @"Altimeter",
                        };
}

-(NSUInteger)updateData:(NSData *)data position:(NSUInteger)pos time:(NSUInteger)time {
    //get Size bytes from this data
    //NSUInteger size = 0;
    //NSUInteger bufferdata_size = 0;
    
    unsigned char buffer[BUFFER_SIZE];
    const unsigned char *bufferdata;
    unsigned long s = 0;       

    if (data != nil) {
        

        //bufferdata_size = data.length;
        bufferdata = (const unsigned char *)[data bytes];
        //hp there're need bytes
        //from available bytes get almost _size bytes
        //size = bufferdata_size > pos ? MIN(_size, bufferdata_size - pos) : 0;
        
        //copy size bytes to the buffer
        s = _feature.size;
        memcpy((void *)buffer, (const void *)&bufferdata[pos], s);
        
        _data = [[NSData alloc] initWithBytes:buffer length:s];
        _time = time;
        [self updateValues];
        
        //add sample to data log
        //[[W2STSDKManager sharedInstance].dataLog addParam:self];
    }
    return s;
}

//update all values from data
-(BOOL)updateValues {
    BOOL ret = YES;
    unsigned char size = (unsigned char)_feature.size;
    unsigned char buffer[BUFFER_SIZE];
    memset((void *)buffer, 0, BUFFER_SIZE);
    
    //int temp_value = 0x00; //temporary var
    //int size = MIN((unsigned int)sizeof(temp_value), (unsigned int)[_data length]);
    
    memcpy((void *)buffer, [_data bytes], size);
    //memcpy((void *)&temp_value, (void *)pdata, size);
    
    BOOL managed = NO;
    //check if the param has a specific update formula

    switch (_feature.map) {
        case W2STSDKNodeFeatureHWPres:
        {
            int val = *((int *)buffer);
            _rawValue = val;
            _value = (double)val / 4096.0;
            managed = YES;
        }
            break;
        case W2STSDKNodeFeatureHWTemp:
        {
            short val = *((short *)buffer);
            _rawValue = val;
            _value = ((double)val / 480.0f) + 42.5f;
            managed = YES;
        }
            break;
        case W2STSDKNodeFeatureInvalid:
        case W2STSDKNodeFeatureHWAcce:
        case W2STSDKNodeFeatureHWGyro:
        case W2STSDKNodeFeatureHWMagn:
        case W2STSDKNodeFeatureHWHumd:
        case W2STSDKNodeFeatureHWGgas:
        case W2STSDKNodeFeatureHWRfid:
        case W2STSDKNodeFeatureSWAHRS:
        case W2STSDKNodeFeatureSWComp:
        case W2STSDKNodeFeatureSWAltm:
            //nothing
            break;
        defaul:
            //nothing
            break;
    }

    //update through the type of the feature
    if (!managed) {
        switch (_feature.type) {
            case W2STSDKNodeParamTypeInt16: //2 bytes
            {
                short val = *((short *)buffer);
                _rawValue = val;
                _value = val;
            }
                break;
            case W2STSDKNodeParamTypeInt32: //4 bytes
            {
                int val = *((int *)buffer);
                _rawValue = val;
                _value = val;
            }
                break;
            case W2STSDKNodeParamTypeFloat:
            {
                float val = *((float *)buffer);
                _rawValue = val;
                _value = val;
            }
                break;
            default:
            {
                int val = *((int *)buffer);
                _rawValue = val;
                _value = val;
            }
                break;
        }

    }
    return ret;
}

//update all values from data
-(NSString *)valueStr {
    NSString * ret = @"na";
    switch([W2STSDKFeature mapLookup:_feature.key]) {
        case W2STSDKNodeFeatureInvalid: ret = @"inv"; break;
            
        case W2STSDKNodeFeatureHWAcce:
        case W2STSDKNodeFeatureHWGyro:
        case W2STSDKNodeFeatureHWMagn:
             ret = [NSString stringWithFormat:@"%d", (int)_rawValue];
            break;
        case W2STSDKNodeFeatureHWPres:
            //ret = [NSString stringWithFormat:@"%d", (int)(_rawValue>>12)];
            ret = [NSString stringWithFormat:@"%0.2f", _value];
            break;
        case W2STSDKNodeFeatureHWTemp:
            ret = [NSString stringWithFormat:@"%0.2f", _value];
            break;
        case W2STSDKNodeFeatureHWHumd:
            ret = [NSString stringWithFormat:@"%d", (int)_rawValue];
            break;
        case W2STSDKNodeFeatureHWGgas:
            break;
        case W2STSDKNodeFeatureHWRfid:
            break;
        case W2STSDKNodeFeatureSWAHRS:
            ret = [NSString stringWithFormat:@"%0.3f", _value];
            break;
        case W2STSDKNodeFeatureSWComp:
            break;
        case W2STSDKNodeFeatureSWAltm:
            break;
    }
    return ret;
}

+(NSArray *)allKeys {
    return W2STSDKNodeParamKeys;
}
+(NSString *)keyFeature:(NSString *)key {
    NSString * ret = W2STSDKNodeFeatureInvalidKey;
    if ([key isEqualToString:W2STSDKNodeParamHWAccelerometerXKey] ||
        [key isEqualToString:W2STSDKNodeParamHWAccelerometerYKey] ||
        [key isEqualToString:W2STSDKNodeParamHWAccelerometerZKey]) {
        ret = W2STSDKNodeFeatureHWAccelerometerKey;
    }
    else if ([key isEqualToString:W2STSDKNodeParamHWGyroscopeXKey] ||
             [key isEqualToString:W2STSDKNodeParamHWGyroscopeYKey] ||
             [key isEqualToString:W2STSDKNodeParamHWGyroscopeZKey]) {
        ret = W2STSDKNodeFeatureHWGyroscopeKey;
    }
    else if ([key isEqualToString:W2STSDKNodeParamHWMagnetometerXKey] ||
             [key isEqualToString:W2STSDKNodeParamHWMagnetometerYKey] ||
             [key isEqualToString:W2STSDKNodeParamHWMagnetometerZKey]) {
        ret = W2STSDKNodeFeatureHWMagnetometerKey;
    }
    else if ([key isEqualToString:W2STSDKNodeParamHWPressureKey]) {
        ret = W2STSDKNodeFeatureHWPressureKey;
    }
    else if ([key isEqualToString:W2STSDKNodeParamHWHumidityKey]) {
        ret = W2STSDKNodeFeatureHWHumidityKey;
    }
    else if ([key isEqualToString:W2STSDKNodeParamHWTemperatureKey]) {
        ret = W2STSDKNodeFeatureHWTemperatureKey;
    }
    else if ([key isEqualToString:W2STSDKNodeParamHWGasKey]) {
        ret = W2STSDKNodeFeatureHWGasKey;
    }
    else if ([key isEqualToString:W2STSDKNodeParamHWRfidKey]) {
        ret = W2STSDKNodeFeatureHWRfidKey;
    }
    else if ([key isEqualToString:W2STSDKNodeParamSWAHRSXKey] ||
             [key isEqualToString:W2STSDKNodeParamSWAHRSYKey] ||
             [key isEqualToString:W2STSDKNodeParamSWAHRSZKey] ||
             [key isEqualToString:W2STSDKNodeParamSWAHRSWKey]) {
        ret = W2STSDKNodeFeatureSWAHRSKey;
    }
    else if ([key isEqualToString:W2STSDKNodeParamSWCompassKey]) {
        ret = W2STSDKNodeFeatureSWCompassKey;
    }
    else if ([key isEqualToString:W2STSDKNodeParamSWAltimeterKey]) {
        ret = W2STSDKNodeFeatureSWAltimeterKey;
    }
    return ret;
    
}

/*
 shor | long (def)
 */
+(NSString *)nameByKey:(NSString *)key mode:(NSString *)mode {
    NSString * name = @"na";
    
    if ([mode isEqualToString:@"short"] && [[W2STSDKNodeParamShortNames allKeys] containsObject:key]) {
        name = W2STSDKNodeParamShortNames[key];
    }
    else {
        name = [key stringByReplacingOccurrencesOfString:@"Key" withString:@""];
    }
        
    return  name;
}

@end
