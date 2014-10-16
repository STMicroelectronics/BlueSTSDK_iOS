//
//  W2STSDKNode.h
//  W2STSDK-CB
//
//  Created by Antonino Raucea on 18/03/14.
//  Copyright (c) 2014 STMicroelectronics. All rights reserved.
//

#import "W2STSDKDefine.h"
#import "W2STSDKCommand.h"

W2STSDK_EXTERN NSString *W2STSDKMotionServiceUUIDString;          // 02366E80-CF3A-11E1-9AB4-0002A5D5C51B     Service UUID
W2STSDK_EXTERN NSString *W2STSDKMotionCharacteristicUUIDString;   // 230A1B80-CF4B-11E1-AC36-0002A5D5C51B     Motion Characteristic
W2STSDK_EXTERN NSString *W2STSDKAHRSCharacteristicUUIDString;     // 240A1B80-CF4B-11E1-AC36-0002A5D5C51B     AHRS Characteristic
W2STSDK_EXTERN NSString *W2STSDKEnvCharacteristicUUIDString;      // 250A1B80-CF4B-11E1-AC36-0002A5D5C51B     Environment Characteristic
W2STSDK_EXTERN NSString *W2STSDKConfCharacteristicUUIDString;      // 360A1B80-CF4B-11E1-AC36-0002A5D5C51B     Config Characteristic
W2STSDK_EXTERN NSString *W2STSDKBatteryCharacteristicUUIDString;      // 350A1B80-CF4B-11E1-AC36-0002A5D5C51B     Battery Characteristic

W2STSDK_EXTERN NSString *W2STSDKNodeConfigGeneric;
W2STSDK_EXTERN NSString *W2STSDKNodeConfigParamName;
W2STSDK_EXTERN NSString *W2STSDKNodeConfigParamAddrBLE;
W2STSDK_EXTERN NSString *W2STSDKNodeConfigParamMode;
W2STSDK_EXTERN NSString *W2STSDKNodeConfigParamINEMO;
W2STSDK_EXTERN NSString *W2STSDKNodeConfigFreqBoard;
W2STSDK_EXTERN NSString *W2STSDKNodeConfigFreqMEMS;
W2STSDK_EXTERN NSString *W2STSDKNodeConfigFreqEnv;
W2STSDK_EXTERN NSString *W2STSDKNodeConfigFreqAHRS;
W2STSDK_EXTERN NSString *W2STSDKNodeConfigToolCalibr;
W2STSDK_EXTERN NSString *W2STSDKNodeConfigToolFWUpdt;

/*!
 *  @enum W2STSDKNodeConfigParamCode
 *
 *  @discussion
 *
 *  @constant
 *
 */
typedef NS_ENUM(NSInteger, W2STSDKNodeConfigCode) {
    W2STSDKNodeConfigGenericCode = 0,
    W2STSDKNodeConfigParamNameCode,
    W2STSDKNodeConfigParamAddrBLECode,
    W2STSDKNodeConfigParamModeCode,
    W2STSDKNodeConfigParamINEMOCode,
    W2STSDKNodeConfigFreqBoardCode,
    W2STSDKNodeConfigFreqMEMSCode,
    W2STSDKNodeConfigFreqEnvCode,
    W2STSDKNodeConfigFreqAHRSCode,
    W2STSDKNodeConfigToolCalibrCode,
    W2STSDKNodeConfigToolFWUpdtCode,
};

/*!
 *  @enum W2STSDKNodeStatus
 *
 *  @discussion Represents the current connection status of a node.
 *
 *  @constant W2STSDKNodeStatusNew     Node is new
 *  @constant W2STSDKNodeStatusNormal  Node is normal
 *  @constant W2STSDKNodeStatusDead    Node is dead
 *  @constant W2STSDKNodeStatusResumed Node is resumed
 *
 */
typedef NS_ENUM(NSInteger, W2STSDKNodeStatus) {
    W2STSDKNodeStatusError           = -1,
    W2STSDKNodeStatusInit            = 0,
    W2STSDKNodeStatusNormal          = 1,
    W2STSDKNodeStatusNormalNoCheck   = 2,
    W2STSDKNodeStatusDead            = 3,
    W2STSDKNodeStatusResumed         = 4,
    W2STSDKNodeStatusDeleted         = 5,
};
/*!
 *  @enum W2STSDKNodeConnectionStatus
 *
 *  @discussion Represents the current connection status of a node.
 *
 *  @constant W2STSDKNodeConnectionStatusUnknown       Status unknown
 *  @constant W2STSDKNodeConnectionStatusDisconnected  Node disconnected
 *  @constant W2STSDKNodeConnectionStatusConnected     Node connected
 *  @constant W2STSDKNodeConnectionStatusConnecting    Node is connecting
 *  @constant W2STSDKNodeConnectionStatusDisconnecting Node is disconnecting
 *
 */
typedef NS_ENUM(NSInteger, W2STSDKNodeConnectionStatus) {
    W2STSDKNodeConnectionStatusUnknown       = 0,
    W2STSDKNodeConnectionStatusDisconnected  = 1,
    W2STSDKNodeConnectionStatusConnected     = 2,
    W2STSDKNodeConnectionStatusConnecting    = 3,
    W2STSDKNodeConnectionStatusDisconnecting = 4,
};

/*!
 *  @enum W2STSDKNodeBoardNameCode
 *
 *  @discussion Represents the name (type) of the board.
 *
 *  @constant W2STSDKNodeBoardNameCodeNone     Board none or not applicable
 *  @constant W2STSDKNodeBoardNameCodeUnknown  Board unknown
 *  @constant W2STSDKNodeBoardNameCodeGeneric  Board Generic
 *  @constant W2STSDKNodeBoardNameCodeWeSU     Board WeSU
 *  @constant W2STSDKNodeBoardNameCodeL1Disco  Board L1 Discovery
 *  @constant W2STSDKNodeBoardNameCodeLocal    Board Local
 *
 */
typedef NS_ENUM(NSUInteger, W2STSDKNodeBoardNameCode) {
    W2STSDKNodeBoardNameCodeNone     = 0xFFE,
    W2STSDKNodeBoardNameCodeUnknown  = 0xFFF,
    W2STSDKNodeBoardNameCodeGeneric  = 0x000,
    W2STSDKNodeBoardNameCodeWeSU     = 0x001,
    W2STSDKNodeBoardNameCodeL1Disco  = 0x002,
    W2STSDKNodeBoardNameCodeWeSU2    = 0x003,
    W2STSDKNodeBoardNameCodeLocal    = 0x100,
};

typedef NS_ENUM(NSInteger, W2STSDKNodeMode) {
    W2STSDKNodeModeUndefined         = -1,
    W2STSDKNodeModeDebug             = 0,
    W2STSDKNodeModeHighPerformance   = 1,
    W2STSDKNodeModeLowPower          = 2,
};

typedef NS_ENUM(NSInteger, W2STSDKNodeFrameGroup) {
    W2STSDKNodeFrameGroupUndefined    = 0,
    W2STSDKNodeFrameGroupMotion       = 1,
    W2STSDKNodeFrameGroupEnvironment  = 2,
    W2STSDKNodeFrameGroupAHRS         = 4,
    W2STSDKNodeFrameGroupAll          = W2STSDKNodeFrameGroupMotion | W2STSDKNodeFrameGroupEnvironment | W2STSDKNodeFrameGroupAHRS,
};

@protocol W2STSDKNodeDelegate;
@class W2STSDKManager;
@class W2STSDKCommand;
@class W2STDBNode;

NS_CLASS_AVAILABLE(10_7, 5_0)
@interface W2STSDKNode : NSObject <CBPeripheralDelegate>

/*!
 *  @property delegate
 *
 *  @discussion The delegate object that will receive node events.
 *
 */
@property (nonatomic) id<W2STSDKNodeDelegate> delegate;

/*!
 *  @property dbNode
 *
 *  @discussion .
 *
 */
@property (assign, nonatomic) W2STDBNode * dbNode;

/*!
 *  @property status
 *
 *  @discussion The current status of the node of the peripheral, initially set to <code>W2STSDKNodeStatusNew</code>. After the first connection the status change in <code>W2STSDKNodeStatusNormal</code>
 *
 */
@property (assign, nonatomic) W2STSDKNodeStatus status;
/*!
 *  @property peripheral
 *
 *  @discussion
 */
@property (retain, nonatomic) CBPeripheral * peripheral;

/*!
 *  @property peripheral
 *
 *  @discussion
 */
@property (retain, nonatomic) NSMutableArray * notifiedCharacteristics;
@property (retain, nonatomic) CBCharacteristic * configCharacteristic;
@property (retain, nonatomic) CBCharacteristic * batteryCharacteristic;

/*!
 *  @property manager
 *
 *  @discussion
 */
@property (retain, nonatomic) W2STSDKManager * manager;

/******** BLE Properties ********/
/*!
 *  @property name
 *
 *  @discussion
 */
@property (retain, readonly) NSString *name;
/*!
 *  @property localName
 *
 *  @discussion
 */
@property (retain, readonly) NSString *peripheralName;
/*!
 *  @property localName
 *
 *  @discussion
 */
@property (retain, readonly) NSString *localName;

/*!
 *  @property UUID
 *
 *  @discussion
 */
@property (assign, readonly) NSUUID *identifier;

/*** configuration properties ****/
@property (retain, nonatomic) NSData * addressBLE; //48bits
@property (assign, nonatomic) BOOL iNemoEngine;
@property (assign, nonatomic) NSUInteger led;
@property (assign, nonatomic) W2STSDKNodeMode mode;
@property (assign, nonatomic) NSUInteger boardFreq;
@property (assign, nonatomic) NSUInteger memsDivChar;
@property (assign, nonatomic) NSUInteger envDivChar;
@property (assign, nonatomic) NSUInteger ahrsDivChar;
@property (assign, nonatomic) NSInteger battery;
@property (assign, nonatomic) NSInteger rechargeStatus;

/*!
 *  @property RSSI
 *
 *  @discussion
 */
@property (retain, readonly) NSNumber *RSSI;

/*!
 *  @property txPower
 *
 *  @discussion
 */
@property (retain, readonly) NSNumber *txPower;

/*!
 *  @property isConnectable
 *
 *  @discussion
 */
@property (assign, readonly) BOOL isConnectable;

/*!
 *  @property channel
 *
 *  @discussion
 */
@property (retain, readonly) NSNumber *channel;
/*!
 *  @property connectionStatus
 *
 *  @discussion The current status of the connection of the peripheral, initially set to <code>W2STSDKNodeConnectionStatusUnknown</code>. Updates are provided by required
 *              delegate method {@link connectionDidChange:}.
 *
 */
@property (assign, nonatomic) W2STSDKNodeConnectionStatus connectionStatus;

/*!
 *  @property local
 *
 *  @discussion
 */
@property (assign, readonly) BOOL local;

/******** bMESH Date ********/
@property (readonly) NSDate *leaveTime;
@property (readonly) NSDate *scanLastDone;
@property (readonly) NSDate *rssiLastUpdate;
@property (readonly) NSDate *txPowerLastUpdate;

/******** bMESH Properties ********/
/*!
 *  @property boardNameCode
 *
 *  @discussion
 */
@property (assign, readonly) W2STSDKNodeBoardNameCode boardNameCode;
/*!
 *  @property hwFeatureByte
 *
 *  @discussion
 */
@property (assign, readonly) int8_t hwFeatureByte;
/*!
 *  @property swFeatureByte
 *
 *  @discussion
 */
@property (assign, readonly) int8_t swFeatureByte;
/*!
 *  @property featureByte
 *
 *  @discussion
 */
@property (assign, readonly) int16_t featureByte;

/******** Generic Properties ********/
/*!
 *  @property info
 *
 *  @discussion
 */
@property (retain, nonatomic) NSString *info;

/*!
 *  @property connectionStatus
 *
 *  @discussion
 */
@property (retain, nonatomic) NSData *advManuData;

/******** Data Properties ********/
/*!
 *  @property Features
 *
 *  @discussion
 */
@property (nonatomic, retain) NSMutableDictionary *features;
@property (nonatomic, retain) NSMutableArray *valueFeatures;
/*!
 *  @property Params
 *
 *  @discussion
 */
@property (nonatomic, retain) NSMutableDictionary *params;


/******** Methods ********/

/*!
 *  @method init:
 *
 *  @discussion     
 *
 */
-(id) init;

/*!
 *  @method initAsLocal:
 *
 *  @param manager  The manager
 *
 *  @discussion
 *
 */
-(id) initAsLocal:(W2STSDKManager *)manager;

/*!
 *  @method init:
 *
 *  @param peripheral   The peripheral
 *  @param manager      The manager
 *  @param local        The local
 *
 *  @discussion
 *
 */
-(id) init :(CBPeripheral *)peripheral manager:(W2STSDKManager *)manager local:(BOOL)local;
/*!
 *  @method initStatus:
 *
 *  @param status   W2STSDKNodeStatus
 *  @param cstatus  W2STSDKNodeConnectionStatus
 *
 *  @discussion
 *
 */
//-(id) initStatus:(W2STSDKNodeStatus)status cstatus:(W2STSDKNodeConnectionStatus)cstatus;
+(NSString *) stateStr:(CBPeripheral *)peripheral;

+(NSString *)configKeyFromCode:(W2STSDKNodeConfigCode)code;
+(W2STSDKNodeConfigCode)configCodeFromKey:(NSString *)key;

-(BOOL)isSupportedBoard;
-(NSString *)nameBoardGetString;
-(NSString *)UUIDGetString;

- (BOOL) connectAndReading;
- (BOOL) connect;
- (BOOL) disconnect;
- (BOOL) toggleConnect;
- (BOOL) isConnected;
- (BOOL) updateConnectionStatus;
- (BOOL) isConnectable;

- (BOOL)featureAvailable:(NSString *)featureKey;
- (W2STSDKFeature *)featureWithKey:(NSString *)featureKey;
- (BOOL)paramAvailable:(NSString *)paramKey;

- (BOOL) updateBLEProperties:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI enableDelegate:(BOOL)enableDelegate;
- (BOOL) updateAdvertisement:(NSDictionary *)advertisementData enableDelegate:(BOOL)enableDelegate;
- (BOOL) updateRSSI:(NSNumber *)RSSI enableDelegate:(BOOL)enableDelegate;

-(void)updateLiveTime;
-(BOOL)checkLiveTime;

//Reading
-(BOOL) isReading;
-(void) reading:(BOOL)enable;
-(void) readingSync;
-(void) startReading;
-(void) stopReading;
-(void) toggleReading;

//config
-(NSString *)config:(NSString *)what;
-(void)forceReadingConfig;
-(W2STSDKCommand *)sendConfig:(W2STSDKCommand *)controlService;

-(NSString *)writeConfig:(NSString *)what param:(NSString *)param;
-(void)getAllConfig;
-(void)getConfig:(NSString *)what;
-(void)getConfigWithReg:(unsigned char)regEnum;

//-(W2STSDKCommand *)bleGetFirmwareVersion;
//-(W2STSDKCommand *)bleSetLed:(BOOL)state;
//-(W2STSDKCommand *)bleGetLed;

@end

//Protocols definition
@protocol W2STSDKNodeDelegate <NSObject>
@required
- (void)node:(W2STSDKNode *)node statusDidChange:(W2STSDKNodeStatus)status;
- (void)node:(W2STSDKNode *)node connectionDidChange:(W2STSDKNodeConnectionStatus)connectionStatus;
- (void)node:(W2STSDKNode *)node readingDidChange:(BOOL)readingStatus;
- (void)node:(W2STSDKNode *)node dataDidUpdate:(NSString *)what param:(NSString *)param;
- (void)node:(W2STSDKNode *)node configurationDidChange:(NSString *)what;
@end


