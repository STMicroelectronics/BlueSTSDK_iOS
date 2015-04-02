//
//  W2STSDKFeature.h
//  W2STSDK-CB
//
//  Created by Antonino Raucea on 30/04/14.
//  Copyright (c) 2014 STMicroelectronics. All rights reserved.
//

#import "W2STSDKDefine.h"

#define W2STSDK_NODE_BRD_FEA_HW 0x000 // 0xxx -.-
#define W2STSDK_NODE_BRD_FEA_SW 0x800 // 1xxx -.-

#define W2STSDK_NODE_BRD_FEA_INER 0x000 // x00x -.-
#define W2STSDK_NODE_BRD_FEA_ENVM 0x200 // x01x -.-
#define W2STSDK_NODE_BRD_FEA_UTIL 0x400 // x10x -.-

#define W2STSDK_NODE_BRD_FEA_MASK_HW_VALID (0x0FF & ~(W2STSDKNodeFeatureHWRfid | W2STSDKNodeFeatureHWGgas | W2STSDKNodeFeatureHWHumd))  //removing umidity by def //0x0FC
#define W2STSDK_NODE_BRD_FEA_MASK_SW_VALID 0x080

#define W2STSDK_NODE_BRD_FEA_MASK_GROUP 0xE00

#define W2STSDK_NODE_BRD_FEA_IS_HARDWARE(map) (((map) != W2STSDKNodeFeatureInvalid) && (((map) & W2STSDK_NODE_BRD_FEA_SW) == 0))
#define W2STSDK_NODE_BRD_FEA_IS_SOFTWARE(map) (((map) != W2STSDKNodeFeatureInvalid) && (((map) & W2STSDK_NODE_BRD_FEA_SW) != 0))
typedef NS_ENUM(NSUInteger, W2STSDKNodeFeature) {
    W2STSDKNodeFeatureInvalid = 0xFFFF,
    
    W2STSDKNodeFeatureHWAcce = W2STSDK_NODE_BRD_FEA_HW | W2STSDK_NODE_BRD_FEA_INER | 0x80, //Accelerometer
    W2STSDKNodeFeatureHWGyro = W2STSDK_NODE_BRD_FEA_HW | W2STSDK_NODE_BRD_FEA_INER | 0x40, //Gyroscope
    W2STSDKNodeFeatureHWMagn = W2STSDK_NODE_BRD_FEA_HW | W2STSDK_NODE_BRD_FEA_INER | 0x20, //Magnetometer
    W2STSDKNodeFeatureHWPres = W2STSDK_NODE_BRD_FEA_HW | W2STSDK_NODE_BRD_FEA_ENVM | 0x10, //Pressure
    W2STSDKNodeFeatureHWHumd = W2STSDK_NODE_BRD_FEA_HW | W2STSDK_NODE_BRD_FEA_ENVM | 0x08, //Humidity
    W2STSDKNodeFeatureHWTemp = W2STSDK_NODE_BRD_FEA_HW | W2STSDK_NODE_BRD_FEA_ENVM | 0x04, //Temperature
    W2STSDKNodeFeatureHWGgas = W2STSDK_NODE_BRD_FEA_HW | W2STSDK_NODE_BRD_FEA_UTIL | 0x02, //Gauge ??? Battery charger
    W2STSDKNodeFeatureHWRfid = W2STSDK_NODE_BRD_FEA_HW | W2STSDK_NODE_BRD_FEA_UTIL | 0x01, //RFID
    
    W2STSDKNodeFeatureSWAHRS = W2STSDK_NODE_BRD_FEA_SW | W2STSDK_NODE_BRD_FEA_UTIL | 0x80, //AHRS
    W2STSDKNodeFeatureSWComp = W2STSDK_NODE_BRD_FEA_SW | W2STSDK_NODE_BRD_FEA_UTIL | 0x40, //Compass
    W2STSDKNodeFeatureSWAltm = W2STSDK_NODE_BRD_FEA_SW | W2STSDK_NODE_BRD_FEA_UTIL | 0x20, //Altimeter
};

typedef NS_ENUM(NSUInteger, W2STSDKNodeFeatureGroup) {
    W2STSDKNodeFeatureGroupInvalid = 0xFFFF,

    W2STSDKNodeFeatureGroupHWIner = W2STSDK_NODE_BRD_FEA_HW | W2STSDK_NODE_BRD_FEA_INER ,
    W2STSDKNodeFeatureGroupHWEnvm = W2STSDK_NODE_BRD_FEA_HW | W2STSDK_NODE_BRD_FEA_ENVM ,
    W2STSDKNodeFeatureGroupHWUtil = W2STSDK_NODE_BRD_FEA_HW | W2STSDK_NODE_BRD_FEA_UTIL ,
    W2STSDKNodeFeatureGroupSWUtil = W2STSDK_NODE_BRD_FEA_SW | W2STSDK_NODE_BRD_FEA_UTIL ,
};

typedef NS_ENUM(NSUInteger, W2STSDKNodeFeatureGroupItems) {
    W2STSDKNodeFeatureGroupItemsInvalid = 0xFFFF,
    
    W2STSDKNodeFeatureGroupItemsHWIner = W2STSDKNodeFeatureGroupHWIner | (W2STSDKNodeFeatureHWAcce | W2STSDKNodeFeatureHWGyro | W2STSDKNodeFeatureHWMagn),
    W2STSDKNodeFeatureGroupItemsHWEnvm = W2STSDKNodeFeatureGroupHWEnvm | (W2STSDKNodeFeatureHWPres | W2STSDKNodeFeatureHWHumd | W2STSDKNodeFeatureHWTemp),
    W2STSDKNodeFeatureGroupItemsHWUtil = W2STSDKNodeFeatureGroupHWUtil | (W2STSDKNodeFeatureHWGgas | W2STSDKNodeFeatureHWRfid),
    
    W2STSDKNodeFeatureGroupItemsSWUtil = W2STSDKNodeFeatureGroupSWUtil | (W2STSDKNodeFeatureSWAHRS | W2STSDKNodeFeatureSWComp | W2STSDKNodeFeatureSWAltm),
};


W2STSDK_EXTERN NSString * const W2STSDKNodeFeatureInvalidKey;

W2STSDK_EXTERN NSString * const W2STSDKNodeFeatureHWAccelerometerKey;
W2STSDK_EXTERN NSString * const W2STSDKNodeFeatureHWGyroscopeKey;
W2STSDK_EXTERN NSString * const W2STSDKNodeFeatureHWMagnetometerKey;
W2STSDK_EXTERN NSString * const W2STSDKNodeFeatureHWPressureKey;
W2STSDK_EXTERN NSString * const W2STSDKNodeFeatureHWHumidityKey;
W2STSDK_EXTERN NSString * const W2STSDKNodeFeatureHWTemperatureKey;
W2STSDK_EXTERN NSString * const W2STSDKNodeFeatureHWGasKey;
W2STSDK_EXTERN NSString * const W2STSDKNodeFeatureHWRfidKey;

W2STSDK_EXTERN NSString * const W2STSDKNodeFeatureSWAHRSKey;
W2STSDK_EXTERN NSString * const W2STSDKNodeFeatureSWCompassKey;
W2STSDK_EXTERN NSString * const W2STSDKNodeFeatureSWAltimeterKey;

W2STSDK_EXTERN NSString * const W2STSDKNodeFeatureGroupHWInertialKey;
W2STSDK_EXTERN NSString * const W2STSDKNodeFeatureGroupHWEnvironmentKey;
W2STSDK_EXTERN NSString * const W2STSDKNodeFeatureGroupHWUtilityKey;
W2STSDK_EXTERN NSString * const W2STSDKNodeFeatureGroupSWUtilityKey;
W2STSDK_EXTERN NSString * const W2STSDKNodeFeatureGroupInvalidKey;

@protocol W2STSDKFeatureDelegate;
@class W2STSDKNode;
@class W2STSDKParam;

@interface W2STSDKFeature : NSObject

/*!
 *  @property delegate
 *
 *  @discussion The delegate object that will receive node events.
 *
 */
@property (nonatomic) id<W2STSDKFeatureDelegate> delegate;
@property (readonly, retain, nonatomic) NSString * key;
@property (readonly, retain, nonatomic) W2STSDKNode * node;
@property (readonly, assign, nonatomic) W2STSDKNodeFeature map;

@property (retain, nonatomic) NSString *name;
@property (retain, nonatomic) NSString *shortName;
@property (retain, nonatomic) NSString *format;
@property (retain, nonatomic) NSString *unit;
@property (assign, nonatomic) W2STSDKParamType type;
@property (assign, nonatomic) NSUInteger size;
@property (readonly, assign, nonatomic) NSInteger time;

@property (assign, nonatomic) float min;
@property (assign, nonatomic) float max;
@property (assign, nonatomic) float interval;
@property (assign, nonatomic) NSUInteger decimal;

@property (retain, nonatomic) NSMutableArray * params;


+(void)initStatic;
+(NSArray *)allKeys;
+(NSString *)keyLookup:(W2STSDKNodeFeature)map;
+(W2STSDKNodeFeature)mapLookup:(NSString *)key;
+(NSString *)groupKeyFromKey:(NSString *)key;
+(W2STSDKNodeFeatureGroup)groupMapFromMap:(W2STSDKNodeFeature)map;
+(BOOL)checkAvailabilityInMap:(NSUInteger)val map:(W2STSDKNodeFeature)map;
+(BOOL)isHardware:(W2STSDKNodeFeature)map;
+(BOOL)isSoftware:(W2STSDKNodeFeature)map;

-(W2STSDKNodeFeatureGroup)groupMap;
-(NSString *)groupKey;
-(id) init:(NSString *)key node:(W2STSDKNode *)node;
-(NSUInteger)updateData:(NSData *)data position:(NSUInteger)pos time:(NSUInteger)time;
-(W2STSDKParam *)paramAtIndex:(NSInteger)index;
-(NSArray *)arrayValues:(BOOL)SampleMode;

+(NSInteger)fieldByKeyIntValue:(NSString *)key field:(NSString *)field;
+(NSNumber *)fieldByKeyNumber:(NSString *)key field:(NSString *)field;
+(NSString *)fieldByKeyString:(NSString *)key field:(NSString *)field;
+(NSObject *)fieldByKey:(NSString *)key field:(NSString *)field;
+(NSDictionary *)configByKey:(NSString *)key;

////////////////////////NEW SDK/////////////////////////////////////////////////
@property(readonly) bool enabled;

-(id) initWhitNode: (W2STSDKNode*)node;

///////package methdo////////////
-(void) setEnabled:(bool)enabled;

/////////////////////////END NEW SDK////////////////////////////////////////////
@end

//Protocols definition
@protocol W2STSDKFeatureDelegate <NSObject>
@required
- (void)feature:(W2STSDKFeature *)feature paramsDidUpdate:(W2STSDKParam *)param; //nil for all
@end
