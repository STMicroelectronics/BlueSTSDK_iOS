//
//  W2STSDKFeature.h
//  W2STSDK-CB
//
//  Created by Antonino Raucea on 30/04/14.
//  Copyright (c) 2014 STMicroelectronics. All rights reserved.
//
#ifndef W2STApp_W2STSDKFeature_h
#define W2STApp_W2STSDKFeature_h
#include "W2STSDKDefine.h"


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

@protocol W2STSDKFeatureDelegateOld;

@class W2STSDKParam;

///////////////////////////////NEW SDK//////////////////////////////////////
@protocol W2STSDKFeatureDelegate;
@protocol W2STSDKFeatureLogDelegate;

@class W2STSDKNode;

//////////////////////////////OLD SDK///////////////////////////////////////

@interface W2STSDKFeature : NSObject

/*!
 *  @property delegate
 *
 *  @discussion The delegate object that will receive node events.
 *
 */
@property (nonatomic) id<W2STSDKFeatureDelegateOld> delegate __deprecated;
@property (readonly, retain, nonatomic) NSString * key __deprecated;
@property (readonly, assign, nonatomic) W2STSDKNodeFeature map __deprecated;


@property (retain, nonatomic) NSString *shortName __deprecated;
@property (retain, nonatomic) NSString *format __deprecated;
@property (retain, nonatomic) NSString *unit __deprecated;
@property (assign, nonatomic) W2STSDKParamType type __deprecated;
@property (assign, nonatomic) NSUInteger size __deprecated;


@property (assign, nonatomic) float min __deprecated;
@property (assign, nonatomic) float max __deprecated;
@property (assign, nonatomic) float interval __deprecated;
@property (assign, nonatomic) NSUInteger decimal __deprecated;

@property (retain, nonatomic) NSMutableArray * params __deprecated;


+(void)initStatic __deprecated;
+(NSArray *)allKeys __deprecated;
+(NSString *)keyLookup:(W2STSDKNodeFeature)map __deprecated;
+(W2STSDKNodeFeature)mapLookup:(NSString *)key __deprecated;
+(NSString *)groupKeyFromKey:(NSString *)key __deprecated;
+(W2STSDKNodeFeatureGroup)groupMapFromMap:(W2STSDKNodeFeature)map __deprecated;
+(BOOL)checkAvailabilityInMap:(NSUInteger)val map:(W2STSDKNodeFeature)map __deprecated;
+(BOOL)isHardware:(W2STSDKNodeFeature)map __deprecated;
+(BOOL)isSoftware:(W2STSDKNodeFeature)map __deprecated;

-(W2STSDKNodeFeatureGroup)groupMap __deprecated;
-(NSString *)groupKey __deprecated;
-(id) init:(NSString *)key node:(W2STSDKNode *)node __deprecated;
-(NSUInteger)updateData:(NSData *)data position:(NSUInteger)pos time:(NSUInteger)time __deprecated;
-(W2STSDKParam *)paramAtIndex:(NSInteger)index __deprecated;
-(NSArray *)arrayValues:(BOOL)SampleMode __deprecated;

+(NSInteger)fieldByKeyIntValue:(NSString *)key field:(NSString *)field __deprecated;
+(NSNumber *)fieldByKeyNumber:(NSString *)key field:(NSString *)field __deprecated;
+(NSString *)fieldByKeyString:(NSString *)key field:(NSString *)field __deprecated;
+(NSObject *)fieldByKey:(NSString *)key field:(NSString *)field __deprecated;
+(NSDictionary *)configByKey:(NSString *)key __deprecated;

////////////////////////NEW SDK/////////////////////////////////////////////////
@property(readonly) bool enabled;
@property (readonly,retain, nonatomic) NSString *name;
@property (readonly,retain,nonatomic) W2STSDKNode *parentNode;
@property (readonly) NSDate* lastUpdate;

-(NSString*) description;
-(void) addFeatureDelegate:(id<W2STSDKFeatureDelegate>)delegate;
-(void) removeFeatureDelegate:(id<W2STSDKFeatureDelegate>)delegate;
-(void) addFeatureLoggerDelegate:(id<W2STSDKFeatureLogDelegate>)delegate;
-(void) removeFeatureLoggerDelegate:(id<W2STSDKFeatureLogDelegate>)delegate;

//abstact method
-(id) initWhitNode: (W2STSDKNode*)node;
-(NSArray*) getFieldsData;
-(NSArray*) getFieldsDesc;
-(uint32_t) getTimestamp;

/// protected method
-(id) initWhitNode: (W2STSDKNode*)node name:(NSString*)name;
-(void) notifyUpdate;
-(void) logFeatureUpdate:(NSData*)rawData data:(NSArray*)data;
-(BOOL) sendCommand:(uint8_t)commandType data:(NSData*)commandData;
-(void) parseCommandResponseWithTimestamp:(uint32_t)timestamp
                                 commandType:(uint8_t)commandType
                                        data:(NSData*)data;
-(void)writeData:(NSData*)data;

///////package method////////////
-(void) setEnabled:(bool)enabled;
-(uint32_t) update:(uint32_t)timestamp data:(NSData*)data dataOffset:(uint32_t)offset;
/////////////////////////END NEW SDK////////////////////////////////////////////
@end

/////////////////////////// NEW SDK ///////////////////////////////////////////
//Protocols definition
@protocol W2STSDKFeatureDelegate <NSObject>
@required
- (void)didUpdateFeature:(W2STSDKFeature *)feature;
@end
@protocol W2STSDKFeatureLogDelegate <NSObject>
@required
- (void)feature:(W2STSDKFeature *)feature rawData:(NSData*)raw data:(NSArray*)data;
@end

//Protocols definition
@protocol W2STSDKFeatureDelegateOld <NSObject>
@required
- (void)feature:(W2STSDKFeature *)feature paramsDidUpdate:(W2STSDKParam *)param; //nil for all
@end

#endif

