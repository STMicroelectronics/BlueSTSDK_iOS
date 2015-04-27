//
//  W2STSDKFeature.m
//  W2STSDK-CB
//
//  Created by Antonino Raucea on 30/04/14.
//  Copyright (c) 2014 STMicroelectronics. All rights reserved.
//

#import "W2STSDKFeature.h"
///////////////// NEW SDK///////////////////
#import "W2STSDKFeatureField.h"

@interface W2STSDKFeature()

@end

static dispatch_queue_t sNotificationQueue;

@implementation W2STSDKFeature{
    NSMutableSet *mFeatureDelegates;
    NSMutableSet *mFeatureLogDelegates;

}
/////////////////END NEW SDK/////////////////


static NSDictionary * W2STSDKNodeFeatureGroupKeys = nil;
static NSDictionary * W2STSDKNodeFeatureConfig = nil;
static NSArray * W2STSDKNodeFeatureAllKeys = nil;

NSString * const W2STSDKNodeFeatureInvalidKey = @"InvalidKey";

NSString * const W2STSDKNodeFeatureHWAccelerometerKey = @"AccelerometerKey";
NSString * const W2STSDKNodeFeatureHWGyroscopeKey = @"GyroscopeKey";
NSString * const W2STSDKNodeFeatureHWMagnetometerKey = @"MagnetometerKey";
NSString * const W2STSDKNodeFeatureHWPressureKey = @"PressureKey";
NSString * const W2STSDKNodeFeatureHWHumidityKey = @"HumidityKey";
NSString * const W2STSDKNodeFeatureHWTemperatureKey = @"TemperatureKey";
NSString * const W2STSDKNodeFeatureHWGasKey = @"GasKey";
NSString * const W2STSDKNodeFeatureHWRfidKey = @"RfidKey";

NSString * const W2STSDKNodeFeatureSWAHRSKey = @"AHRSKey";
NSString * const W2STSDKNodeFeatureSWCompassKey = @"CompassKey";
NSString * const W2STSDKNodeFeatureSWAltimeterKey = @"AltimeterKey";

NSString * const W2STSDKNodeFeatureGroupHWInertialKey = @"GroupInertialKey";
NSString * const W2STSDKNodeFeatureGroupHWEnvironmentKey = @"GroupEnvironmentKey";
NSString * const W2STSDKNodeFeatureGroupHWUtilityKey = @"GroupKeyHWUtility";
NSString * const W2STSDKNodeFeatureGroupSWUtilityKey = @"GroupKeySWUtility";
NSString * const W2STSDKNodeFeatureGroupInvalidKey = @"GroupInvalidKey";

+(NSArray *)allKeys {
    return W2STSDKNodeFeatureAllKeys;
}


+(BOOL)isHardware:(W2STSDKNodeFeature)map {
    return W2STSDK_NODE_BRD_FEA_IS_HARDWARE(map);
}
+(BOOL)isSoftware:(W2STSDKNodeFeature)map {
    return W2STSDK_NODE_BRD_FEA_IS_SOFTWARE(map);
}



+(NSString *)keyLookup:(W2STSDKNodeFeature)map {
    NSString * ret = W2STSDKNodeFeatureInvalidKey;
    NSNumber * fea = [NSNumber numberWithInt:map];
    for(NSString * key in [W2STSDKNodeFeatureConfig allKeys]) {
        if ([W2STSDKNodeFeatureConfig[key][map] isEqualToNumber:fea]) {
            ret = key;
            break;
        }
    }
    return ret;
}

+(NSString *)groupKeyLookup:(W2STSDKNodeFeatureGroup)mapGroup {
    NSString * ret = W2STSDKNodeFeatureGroupInvalidKey;
    NSNumber * val = [NSNumber numberWithInt:mapGroup];
    for(NSString * key in [W2STSDKNodeFeatureGroupKeys allKeys]) {
        if ([W2STSDKNodeFeatureGroupKeys[key] isEqualToNumber:val]) {
            ret = key;
            break;
        }
    }
    return ret;
}
+(W2STSDKNodeFeatureGroup)groupMapLookup:(NSString *)keyGroup {
    W2STSDKNodeFeatureGroup ret = W2STSDKNodeFeatureGroupInvalid;
    NSNumber *num = @0;
    if ([[W2STSDKNodeFeatureGroupKeys allKeys] containsObject:keyGroup]) {
        num = W2STSDKNodeFeatureGroupKeys[keyGroup];
        ret = (W2STSDKNodeFeatureGroup)[num intValue];
    }
    return ret;
}
+(BOOL)checkAvailabilityInMap:(NSUInteger)val map:(W2STSDKNodeFeature)map {
    NSUInteger localMap = (int)map & 0xFF;
    return (val & localMap) == localMap;
}



-(void)setKey:(NSString *)key {
    _key = key;
    _map = [W2STSDKFeature mapLookup:key];
}
-(void)setMap:(W2STSDKNodeFeature)map {
    _map = map;
    _key = [W2STSDKFeature keyLookup:map];
}
-(W2STSDKNodeFeatureGroup)groupMap {
    return [W2STSDKFeature groupMapFromMap:_map];
}
-(NSString *)groupKey {
    return [W2STSDKFeature groupKeyLookup:[self groupMap]];
}
- (id)init {
    self = [super init];
    _parentNode = nil;
    _key = W2STSDKNodeFeatureInvalidKey;
    
    [self initializeFromKey];
    
    _params = [[NSMutableArray alloc] init];
    
    return self;
}
-(id) init:(NSString *)key node:(W2STSDKNode *)node {
    
    self = [super init];
    
    _parentNode = node;
    _key = key;
    [self initializeFromKey];
    
    _params = [[NSMutableArray alloc] init];
    
    return self;
}
+(void)initStatic {
     W2STSDKNodeFeatureGroupKeys = @{ W2STSDKNodeFeatureGroupHWInertialKey   : [NSNumber numberWithInt:W2STSDKNodeFeatureGroupHWIner],
                                W2STSDKNodeFeatureGroupHWEnvironmentKey: [NSNumber numberWithInt:W2STSDKNodeFeatureGroupHWEnvm],
                                W2STSDKNodeFeatureGroupHWUtilityKey  : [NSNumber numberWithInt:W2STSDKNodeFeatureGroupHWUtil],
                                W2STSDKNodeFeatureGroupSWUtilityKey  : [NSNumber numberWithInt:W2STSDKNodeFeatureGroupSWUtil],
                                W2STSDKNodeFeatureGroupInvalidKey    : [NSNumber numberWithInt:W2STSDKNodeFeatureGroupInvalid],
                                };
    W2STSDKNodeFeatureAllKeys = @[
                               W2STSDKNodeFeatureHWAccelerometerKey,
                               W2STSDKNodeFeatureHWGyroscopeKey,
                               W2STSDKNodeFeatureHWMagnetometerKey,
                               W2STSDKNodeFeatureHWPressureKey,
                               W2STSDKNodeFeatureHWHumidityKey,
                               W2STSDKNodeFeatureHWTemperatureKey,
                               W2STSDKNodeFeatureHWGasKey,
                               W2STSDKNodeFeatureHWRfidKey,
                               
                               W2STSDKNodeFeatureSWAHRSKey,
                               W2STSDKNodeFeatureSWCompassKey,
                               W2STSDKNodeFeatureSWAltimeterKey
                               ];

    W2STSDKNodeFeatureConfig = @{
                            W2STSDKNodeFeatureHWAccelerometerKey : @{@"name" : @"Accelerometer",   @"shortName" : @"Acc",       @"key" : W2STSDKNodeFeatureHWAccelerometerKey,  @"map" : [NSNumber numberWithInt:W2STSDKNodeFeatureHWAcce], @"min" : @-2000,  @"max" : @2000,     @"interval" : @200, @"unit" : @"mg",   @"format" : @"%04X", @"decimal" : @0, @"size" : @2, @"type" : W2STSDKNodeParamTypeInt16Number  },
                            W2STSDKNodeFeatureHWGyroscopeKey     : @{@"name" : @"Gyroscope",       @"shortName" : @"Gyro",      @"key" : W2STSDKNodeFeatureHWGyroscopeKey,      @"map" : [NSNumber numberWithInt:W2STSDKNodeFeatureHWGyro], @"min" : @-800,   @"max" : @800,      @"interval" : @20,  @"unit" : @"dps",  @"format" : @"%04X", @"decimal" : @0, @"size" : @2, @"type" : W2STSDKNodeParamTypeInt16Number  },
                            W2STSDKNodeFeatureHWMagnetometerKey  : @{@"name" : @"Magnetometer",    @"shortName" : @"Magn",      @"key" : W2STSDKNodeFeatureHWMagnetometerKey,   @"map" : [NSNumber numberWithInt:W2STSDKNodeFeatureHWMagn], @"min" : @-800,   @"max" : @800,      @"interval" : @50,  @"unit" : @"mGa",  @"format" : @"%04X", @"decimal" : @0, @"size" : @2, @"type" : W2STSDKNodeParamTypeInt16Number  },
                            W2STSDKNodeFeatureHWPressureKey      : @{@"name" : @"Pressure",        @"shortName" : @"Press",     @"key" : W2STSDKNodeFeatureHWPressureKey,       @"map" : [NSNumber numberWithInt:W2STSDKNodeFeatureHWPres], @"min" : @980,    @"max" : @1080,     @"interval" : @10,  @"unit" : @"mbar", @"format" : @"%04X", @"decimal" : @0, @"size" : @4, @"type" : W2STSDKNodeParamTypeInt32Number  },
                            W2STSDKNodeFeatureHWHumidityKey      : @{@"name" : @"Humidity",        @"shortName" : @"Hum",       @"key" : W2STSDKNodeFeatureHWHumidityKey,       @"map" : [NSNumber numberWithInt:W2STSDKNodeFeatureHWHumd], @"min" : @15,     @"max" : @100,      @"interval" : @5,   @"unit" : @"%",    @"format" : @"%04X", @"decimal" : @0, @"size" : @2, @"type" : W2STSDKNodeParamTypeInt16Number  },
                            W2STSDKNodeFeatureHWTemperatureKey   : @{@"name" : @"Temperature",     @"shortName" : @"Temp",      @"key" : W2STSDKNodeFeatureHWTemperatureKey,    @"map" : [NSNumber numberWithInt:W2STSDKNodeFeatureHWTemp], @"min" : @0,      @"max" : @100,      @"interval" : @10,  @"unit" : @"°C",   @"format" : @"%04X", @"decimal" : @0, @"size" : @2, @"type" : W2STSDKNodeParamTypeInt16Number  },
                            W2STSDKNodeFeatureHWGasKey           : @{@"name" : @"GAS",             @"shortName" : @"GAS",       @"key" : W2STSDKNodeFeatureHWGasKey,            @"map" : [NSNumber numberWithInt:W2STSDKNodeFeatureHWGgas], @"min" : @0,      @"max" : @100,      @"interval" : @10,  @"unit" : @"%",    @"format" : @"%04X", @"decimal" : @0, @"size" : @0, @"type" : W2STSDKNodeParamTypeUnknownNumber},
                            W2STSDKNodeFeatureHWRfidKey          : @{@"name" : @"RFID",            @"shortName" : @"RFID",      @"key" : W2STSDKNodeFeatureHWRfidKey,           @"map" : [NSNumber numberWithInt:W2STSDKNodeFeatureHWRfid], @"min" : @0,      @"max" : @100,      @"interval" : @10,  @"unit" : @"%",    @"format" : @"%04X", @"decimal" : @0, @"size" : @0, @"type" : W2STSDKNodeParamTypeUnknownNumber},
                            
                            W2STSDKNodeFeatureSWAHRSKey          : @{@"name" : @"AHRS",            @"shortName" : @"AHRS",      @"key" : W2STSDKNodeFeatureSWAHRSKey,           @"map" : [NSNumber numberWithInt:W2STSDKNodeFeatureSWAHRS], @"min" : @-1,     @"max" : @1,        @"interval" : @0.2, @"unit" : @"",     @"format" : @"%04X", @"decimal" : @0, @"size" : @4, @"type" : W2STSDKNodeParamTypeFloatNumber  },
                            W2STSDKNodeFeatureSWCompassKey       : @{@"name" : @"Compass",         @"shortName" : @"Compass",   @"key" : W2STSDKNodeFeatureSWCompassKey,        @"map" : [NSNumber numberWithInt:W2STSDKNodeFeatureSWComp], @"min" : @-1,     @"max" : @1,        @"interval" : @0.2, @"unit" : @"",     @"format" : @"%04X", @"decimal" : @0, @"size" : @0, @"type" : W2STSDKNodeParamTypeUnknownNumber},
                            W2STSDKNodeFeatureSWAltimeterKey     : @{@"name" : @"Altimeter",       @"shortName" : @"Altimeter", @"key" : W2STSDKNodeFeatureSWAltimeterKey,      @"map" : [NSNumber numberWithInt:W2STSDKNodeFeatureSWAltm], @"min" : @-1,     @"max" : @1,        @"interval" : @0.2, @"unit" : @"",     @"format" : @"%04X", @"decimal" : @0, @"size" : @0, @"type" : W2STSDKNodeParamTypeUnknownNumber},
                            
                            W2STSDKNodeFeatureInvalidKey         : @{@"name" : @"na",              @"shortName" : @"na",        @"key" : W2STSDKNodeFeatureInvalidKey,          @"map" : [NSNumber numberWithInt:W2STSDKNodeFeatureInvalid],@"min" : @-1,     @"max" : @1,        @"interval" : @0.2, @"unit" : @"",     @"format" : @"%04X", @"decimal" : @0, @"size" : @0, @"type" : W2STSDKNodeParamTypeUnknownNumber},
                            };

}
-(void)initializeFromKey {
    _map        = (W2STSDKNodeFeature)[W2STSDKFeature fieldByKeyIntValue:_key field:@"map"];
    _name       = [W2STSDKFeature fieldByKeyString:_key field:@"name"];
    _shortName  = [W2STSDKFeature fieldByKeyString:_key field:@"shortName"];
    _format     = [W2STSDKFeature fieldByKeyString:_key field:@"format"];
    _unit       = [W2STSDKFeature fieldByKeyString:_key field:@"unit"];
    _type       = (W2STSDKParamType)[W2STSDKFeature fieldByKeyIntValue:_key field:@"type"];
    _size       = [W2STSDKFeature fieldByKeyIntValue:_key field:@"size"];
    _min        = [W2STSDKFeature fieldByKeyFloatValue:_key field:@"min"];
    _max        = [W2STSDKFeature fieldByKeyFloatValue:_key field:@"max"];
    _interval   = [W2STSDKFeature fieldByKeyFloatValue:_key field:@"interval"];
    _decimal    = [W2STSDKFeature fieldByKeyIntValue:_key field:@"decimal"];
}

-(NSUInteger)updateData:(NSData *)data position:(NSUInteger)pos time:(NSUInteger)time {
    NSUInteger s = 0;
    
    //_timeStamp = time;
    for(W2STSDKParam *prm in _params)
    {
        s += [prm updateData:data position:(pos+s) time:time];
    }

    [_delegate feature:self paramsDidUpdate:nil];
        
    return s;
    
}

-(W2STSDKParam *)paramAtIndex:(NSInteger)index {
    return index >= 0 && index < _params.count ? (W2STSDKParam *)_params[index] : nil;
}

-(NSArray *)arrayValues:(BOOL)rawDataMode {
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    for(int i = 0; i < _params.count; i++) {
        [ret addObject:[((W2STSDKParam *)_params[i]) numberValue:rawDataMode]];
    }
    return ret;
}

/**** groups management ****/
+(NSString *)groupKeyFromKey:(NSString *)key {
    W2STSDKNodeFeature map = [W2STSDKFeature mapLookup:key];
    W2STSDKNodeFeatureGroup groupMap = [W2STSDKFeature groupMapFromMap:map];
    NSString *groupKey = [W2STSDKFeature groupKeyLookup:groupMap];
    return groupKey;
}
+(W2STSDKNodeFeatureGroup)groupMapFromMap:(W2STSDKNodeFeature)map {
    return (W2STSDKNodeFeatureGroup)(map & W2STSDK_NODE_BRD_FEA_MASK_GROUP);
}


/**** fields management ****/
+(W2STSDKNodeFeature)mapLookup:(NSString *)key {
    return (W2STSDKNodeFeature)[W2STSDKFeature fieldByKeyIntValue:key field:@"map"];
}

+(float)fieldByKeyFloatValue:(NSString *)key field:(NSString *)field {
    return [[W2STSDKFeature fieldByKeyNumber:key field:field] floatValue];
}
+(NSInteger)fieldByKeyIntValue:(NSString *)key field:(NSString *)field {
    return [[W2STSDKFeature fieldByKeyNumber:key field:field] intValue];
}
+(NSNumber *)fieldByKeyNumber:(NSString *)key field:(NSString *)field {
    return (NSNumber *)[W2STSDKFeature fieldByKey:key field:field];
}
+(NSString *)fieldByKeyString:(NSString *)key field:(NSString *)field {
    return (NSString *)[W2STSDKFeature fieldByKey:key field:field];
}
+(NSObject *)fieldByKey:(NSString *)key field:(NSString *)field {
    NSDictionary * configDic = [W2STSDKFeature configByKey:key];
    NSObject * ret = nil;
    BOOL foundField = NO;
    if (configDic != nil) {
        foundField = [[configDic allKeys] containsObject:field];
        if (foundField) {
            ret = configDic[field];
        }
    }
    assert(ret != nil);
    return ret;
}
+(NSDictionary *)configByKey:(NSString *)key {
    NSDictionary * ret = nil;
    BOOL foundKey = [[W2STSDKNodeFeatureConfig allKeys] containsObject:key];
    if (foundKey) {
        ret = W2STSDKNodeFeatureConfig[key];
    }
    assert(ret != nil);
    return ret;
}


///////////////////////////NEW SDK/////////////////////////////////////////////

-(id) initWhitNode: (W2STSDKNode*)node{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must overide %@ in a subclass]",
                                           NSStringFromSelector(_cmd)]
                                 userInfo:nil];
    return nil;
}

-(id) initWhitNode: (W2STSDKNode*)node name:(NSString *)name{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sNotificationQueue = dispatch_queue_create("W2STSDKFeature", DISPATCH_QUEUE_CONCURRENT);
    });
    
    
    mFeatureDelegates = [[NSMutableSet alloc] init];
    mFeatureLogDelegates = [[NSMutableSet alloc] init];
    _parentNode=node;
    _enabled=false;
    _name=name;
    return self;
}

-(void) setEnabled:(bool)enabled{
    _enabled=enabled;
}

-(void) addFeatureDelegate:(id<W2STSDKFeatureDelegate>)delegate{
    [mFeatureDelegates addObject:delegate];
}
-(void) removeFeatureDelegate:(id<W2STSDKFeatureDelegate>)delegate{
    [mFeatureDelegates removeObject:delegate];
}

-(void) addFeatureLoggerDelegate:(id<W2STSDKFeatureLogDelegate>)delegate{
    [mFeatureLogDelegates addObject:delegate];
}
-(void) removeFeatureLoggerDelegate:(id<W2STSDKFeatureLogDelegate>)delegate{
    [mFeatureLogDelegates removeObject:delegate];
}

-(NSArray*)getFieldsData{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must overide %@ in a subclass]",
                                           NSStringFromSelector(_cmd)]
                                 userInfo:nil];
    return nil;
}

-(NSArray*)getFieldsDesc{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must overide %@ in a subclass]",
                                           NSStringFromSelector(_cmd)]
                                 userInfo:nil];
    return nil;
}

-(uint32_t)getTimestamp{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must overide %@ in a subclass]",
                                           NSStringFromSelector(_cmd)]
                                 userInfo:nil];
    return -1;
}

-(uint32_t) update:(uint32_t)timestamp data:(NSData*)data dataOffset:(uint32_t)offset{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must overide %@ in a subclass]",
                                           NSStringFromSelector(_cmd)]
                                 userInfo:nil];
    return 0;
}

-(void) notifyUpdate{
    for (id<W2STSDKFeatureDelegate> delegate in mFeatureDelegates) {
        dispatch_async(sNotificationQueue,^{
            [delegate didUpdateFeature:self];
        });
    }//for
}

-(void) logFeatureUpdate:(NSData*)rawData data:(NSArray*)data{
    for (id<W2STSDKFeatureLogDelegate> delegate in mFeatureLogDelegates) {
        dispatch_async(sNotificationQueue,^{
            [delegate feature:self rawData:rawData data:data];
        });
    }//for
}

-(BOOL) sendCommand:(uint8_t)commandType data:(NSData*)commandData{
    return [_parentNode sendCommandMessageToFeature: self type:commandType data:commandData];
}

//optinal abstract method -> default implementation is an empty method
-(void) parseCommandResponseWithTimestamp:(uint32_t)timestamp
                                 commandType:(uint8_t)commandType
                                        data:(NSData*)data{
    
}

-(void) writeData:(NSData *)data{
    [_parentNode writeDataToFeature:self data:data];
}


-(NSString*) description{
    NSMutableString *s = [NSMutableString stringWithString:@"Timestamp:"];
    [s appendFormat:@"%d ",[self getTimestamp] ];
    NSArray *fields = [self getFieldsDesc];
    NSArray *datas = [self getFieldsData ];
    for (int i = 0; i < fields.count; i++) {
        W2STSDKFeatureField *field =(W2STSDKFeatureField*)[fields objectAtIndex:i];
        NSNumber *data = (NSNumber*)[datas objectAtIndex:i];
        [s appendFormat:@"%@: %@ ",field.name,data.stringValue];
        if(field.unit.length!=0){
            [s appendFormat:@"(%@) ", field.unit ];
        }
    }//for
    return s;
}

//////////////////////// END NEW SDK///////////////////////////////////////////

@end
