//
//  W2STSDKNode.h
//  W2STSDK-CB
//
//  Created by Antonino Raucea on 18/03/14.
//  Copyright (c) 2014 STMicroelectronics. All rights reserved.
//

#ifndef W2STApp_W2STSDKNode_h
#define W2STApp_W2STSDKNode_h

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
typedef NS_ENUM(NSInteger, W2STSDKNodeStatusOld) {
    W2STSDKNodeStatusOldError           = -1,
    W2STSDKNodeStatusOldInit            = 0,
    W2STSDKNodeStatusOldNormal          = 1,
    W2STSDKNodeStatusOldNormalNoCheck   = 2,
    W2STSDKNodeStatusOldDead            = 3,
    W2STSDKNodeStatusOldResumed         = 4,
    W2STSDKNodeStatusOldDeleted         = 5,
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



typedef NS_ENUM(NSInteger, W2STSDKNodeFrameGroup) {
    W2STSDKNodeFrameGroupUndefined    = 0,
    W2STSDKNodeFrameGroupMotion       = 1,
    W2STSDKNodeFrameGroupEnvironment  = 2,
    W2STSDKNodeFrameGroupAHRS         = 4,
    W2STSDKNodeFrameGroupAll          = W2STSDKNodeFrameGroupMotion | W2STSDKNodeFrameGroupEnvironment | W2STSDKNodeFrameGroupAHRS,
};

/////////////////// new sdk//////////////////

#import "W2STSDKManager.h"
@class W2STSDKFeature;
typedef NS_ENUM(NSInteger, W2STSDKNodeMode) {
    W2STSDKNodeModeUSB_DFU,
    W2STSDKNodeModeOTA_BLE_DFU,
    W2STSDKNodeModeApplication
};
typedef NS_ENUM(NSInteger, W2STSDKNodeState) {
    W2STSDKNodeStateInit          = 0,
    W2STSDKNodeStateIdle          = 1,
    W2STSDKNodeStateConnecting    = 2,
    W2STSDKNodeStateConnected     = 3,
    W2STSDKNodeStateDisconnecting = 4,
    W2STSDKNodeStateLost          = 5,
    W2STSDKNodeStateUnreachable   = 6,
    W2STSDKNodeStateDead          = 7,
};

typedef NS_ENUM(NSInteger, W2STSDKNodeType) {
    W2STSDKNodeTypeGeneric      = 0x00,
    W2STSDKNodeTypeWeSU         = 0x01,
    W2STSDKNodeTypeL1_Discovery = 0x02,
    W2STSDKNodeTypeNucleo       = 0x80,
};

@protocol W2STSDKNodeBleConnectionParamDelegate;
@protocol W2STSDKNodeStateDelegate;
/////////// end new sdk/////////////////////////

@protocol W2STSDKNodeDelegateOld;

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
@property (nonatomic) id<W2STSDKNodeDelegateOld> delegate __attribute__ ((deprecated));

/*!
 *  @property dbNode
 *
 *  @discussion .
 *
 */
@property (assign, nonatomic) W2STDBNode * dbNode __attribute__ ((deprecated));

/*!
 *  @property status
 *
 *  @discussion The current status of the node of the peripheral, initially set to <code>W2STSDKNodeStatusNew</code>. After the first connection the status change in <code>W2STSDKNodeStatusNormal</code>
 *
 */
@property (readonly) W2STSDKNodeStatusOld status __attribute__ ((deprecated));
/*!
 *  @property peripheral
 *
 *  @discussion
 */


/*!
 *  @property peripheral
 *
 *  @discussion
 */
@property (retain, nonatomic) NSMutableArray * notifiedCharacteristics __attribute__ ((deprecated));
@property (retain, nonatomic) CBCharacteristic * configCharacteristic __attribute__ ((deprecated));
@property (retain, nonatomic) CBCharacteristic * batteryCharacteristic __attribute__ ((deprecated));

/*!
 *  @property manager
 *
 *  @discussion
 */
@property (retain, nonatomic) W2STSDKManager * manager __attribute__ ((deprecated));

/******** BLE Properties ********/
/*!
 *  @property name
 *
 *  @discussion
 */


/*** configuration properties ****/
@property (retain, nonatomic) NSData * addressBLE __attribute__ ((deprecated)); //48bits
@property (assign, nonatomic) BOOL iNemoEngine __attribute__ ((deprecated));
@property (assign, nonatomic) NSUInteger led __attribute__ ((deprecated));
@property (assign, nonatomic) W2STSDKNodeMode mode __attribute__ ((deprecated));
@property (assign, nonatomic) NSUInteger boardFreq __attribute__ ((deprecated));
@property (assign, nonatomic) NSUInteger memsDivChar __attribute__ ((deprecated));
@property (assign, nonatomic) NSUInteger envDivChar __attribute__ ((deprecated));
@property (assign, nonatomic) NSUInteger ahrsDivChar __attribute__ ((deprecated));
@property (assign, nonatomic) NSInteger battery __attribute__ ((deprecated));
@property (assign, nonatomic) NSInteger rechargeStatus __attribute__ ((deprecated));

/*!
 *  @property RSSI
 *
 *  @discussion
 */


/*!
 *  @property txPower
 *
 *  @discussion
 */


/*!
 *  @property isConnectable
 *
 *  @discussion
 */
@property (assign, readonly) BOOL isConnectable __attribute__ ((deprecated));

/*!
 *  @property channel
 *
 *  @discussion
 */
@property (retain, readonly) NSNumber *channel __attribute__ ((deprecated));
/*!
 *  @property connectionStatus
 *
 *  @discussion The current status of the connection of the peripheral, initially set to <code>W2STSDKNodeConnectionStatusUnknown</code>. Updates are provided by required
 *              delegate method {@link connectionDidChange:}.
 *
 */
@property (assign, nonatomic) W2STSDKNodeConnectionStatus connectionStatus __attribute__ ((deprecated));

/*!
 *  @property local
 *
 *  @discussion
 */
@property (assign, readonly) BOOL local __attribute__ ((deprecated));

/******** bMESH Date ********/
@property (readonly) NSDate *leaveTime __attribute__ ((deprecated));
@property (readonly) NSDate *scanLastDone __attribute__ ((deprecated));
@property (readonly) NSDate *txPowerLastUpdate __attribute__ ((deprecated));

/******** bMESH Properties ********/
/*!
 *  @property boardNameCode
 *
 *  @discussion
 */
@property (assign, readonly) W2STSDKNodeBoardNameCode boardNameCode __attribute__ ((deprecated));
/*!
 *  @property hwFeatureByte
 *
 *  @discussion
 */
@property (assign, readonly) int8_t hwFeatureByte __attribute__ ((deprecated));
/*!
 *  @property swFeatureByte
 *
 *  @discussion
 */
@property (assign, readonly) int8_t swFeatureByte __attribute__ ((deprecated));
/*!
 *  @property featureByte
 *
 *  @discussion
 */
@property (assign, readonly) int16_t featureByte __attribute__ ((deprecated));

/******** Generic Properties ********/
/*!
 *  @property info
 *
 *  @discussion
 */
@property (retain, nonatomic) NSString *info __attribute__ ((deprecated));

/*!
 *  @property connectionStatus
 *
 *  @discussion
 */
@property (retain, nonatomic) NSData *advManuData __attribute__ ((deprecated));

/******** Data Properties ********/
/*!
 *  @property Features
 *
 *  @discussion
 */
@property (nonatomic, retain) NSMutableDictionary *features __attribute__ ((deprecated));
@property (nonatomic, retain) NSMutableArray *valueFeatures __attribute__ ((deprecated));
/*!
 *  @property Params
 *
 *  @discussion
 */
@property (nonatomic, retain) NSMutableDictionary *params __attribute__ ((deprecated));


/******** Methods ********/

/*!
 *  @method init:
 *
 *  @discussion     
 *
 */
-(id) init __attribute__ ((deprecated));

/*!
 *  @method initAsLocal:
 *
 *  @param manager  The manager
 *
 *  @discussion
 *
 */
-(id) initAsLocal:(W2STSDKManager *)manager __attribute__ ((deprecated));

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
-(id) init :(CBPeripheral *)peripheral manager:(W2STSDKManager *)manager local:(BOOL)local __attribute__ ((deprecated));


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
+(NSString *) stateStr:(CBPeripheral *)peripheral __attribute__ ((deprecated));

+(NSString *)configKeyFromCode:(W2STSDKNodeConfigCode)code __attribute__ ((deprecated));
+(W2STSDKNodeConfigCode)configCodeFromKey:(NSString *)key __attribute__ ((deprecated));

-(BOOL)isSupportedBoard __attribute__ ((deprecated));
-(NSString *)nameBoardGetString __attribute__ ((deprecated));


- (BOOL) toggleConnect __attribute__ ((deprecated));

- (BOOL) updateConnectionStatus __attribute__ ((deprecated));
- (BOOL) isConnectable __attribute__ ((deprecated));

- (BOOL)featureAvailable:(NSString *)featureKey __attribute__ ((deprecated));
- (W2STSDKFeature *)featureWithKey:(NSString *)featureKey __attribute__ ((deprecated));
- (BOOL)paramAvailable:(NSString *)paramKey __attribute__ ((deprecated));

- (BOOL) updateBLEProperties:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI enableDelegate:(BOOL)enableDelegate __attribute__ ((deprecated));
- (BOOL) updateAdvertisement:(NSDictionary *)advertisementData enableDelegate:(BOOL)enableDelegate __attribute__ ((deprecated));
- (BOOL) updateRSSI:(NSNumber *)RSSI enableDelegate:(BOOL)enableDelegate __attribute__ ((deprecated));

-(void)updateLiveTime __attribute__ ((deprecated));
-(BOOL)checkLiveTime __attribute__ ((deprecated));

//Reading
-(BOOL) isReading __attribute__ ((deprecated));
-(void) reading:(BOOL)enable __attribute__ ((deprecated));
-(void) readingSync __attribute__ ((deprecated));
-(void) startReading __attribute__ ((deprecated));
-(void) stopReading __attribute__ ((deprecated));
-(void) toggleReading __attribute__ ((deprecated));

//config
-(NSString *)config:(NSString *)what __attribute__ ((deprecated));
-(void)forceReadingConfig __attribute__ ((deprecated));
-(W2STSDKCommand *)sendConfig:(W2STSDKCommand *)controlService __attribute__ ((deprecated));

-(NSString *)writeConfig:(NSString *)what param:(NSString *)param __attribute__ ((deprecated));
-(void)getAllConfig __attribute__ ((deprecated));
-(void)getConfig:(NSString *)what __attribute__ ((deprecated));
-(void)getConfigWithReg:(unsigned char)regEnum __attribute__ ((deprecated));

//-(W2STSDKCommand *)bleGetFirmwareVersion;
//-(W2STSDKCommand *)bleSetLed:(BOOL)state;
//-(W2STSDKCommand *)bleGetLed;

////////////////////////////NEW SDK ///////////////////////////
@property (assign, nonatomic) W2STSDKNodeState state;
@property (assign, nonatomic) W2STSDKNodeType type;
@property (readonly) NSDate *rssiLastUpdate;
@property (retain, readonly) NSString *name;
@property (retain, readonly) NSString *tag;
@property (retain, readonly) NSNumber *RSSI;
@property (retain, readonly) NSNumber *txPower;

-(id) init :(CBPeripheral *)peripheral rssi:(NSNumber*)rssi advertise:(NSDictionary*)advertisementData;
-(void) addBleConnectionParamiterDelegate:(id<W2STSDKNodeBleConnectionParamDelegate>)delegate;
-(void) removeBleConnectionParamiterDelegate:(id<W2STSDKNodeBleConnectionParamDelegate>)delegate;
-(void) addNodeStatusDelegate:(id<W2STSDKNodeStateDelegate>)delegate;
-(void) removeNodeStatusDelegate:(id<W2STSDKNodeStateDelegate>)delegate;
-(BOOL) equals:(W2STSDKNode *)node;
-(NSArray*) getFeatures;
-(void) readRssi;
-(void) connect;
-(BOOL) isConnected;
-(void) disconnect;
-(BOOL) readFeature:(W2STSDKFeature*)feature;

//////////////// start internal/package methods ///////////////////////
-(void)updateRssi:(NSNumber*)rssi;
-(void)updateTxPower:(NSNumber*)txPower;
-(void)completeConnection;
-(void)connectionError:(NSError*)error;
-(void)updateNodeStatus:(W2STSDKNodeState)newState;
-(void)characteristicUpdate:(CBCharacteristic*)characteristics;


//////////////// end internal/package methods ///////////////////////
@end

//Protocols definition
@protocol W2STSDKNodeStateDelegate <NSObject>
@required
- (void) node:(W2STSDKNode *)node didChangeState:(W2STSDKNodeState)newState prevState:(W2STSDKNodeState)prevState;
@end
////////////////////////END NEW SDK/////////////////////////////////
//Protocols definition
@protocol W2STSDKNodeDelegateOld <NSObject>
@required
- (void)node:(W2STSDKNode *)node statusDidChange:(W2STSDKNodeStatusOld)status;
- (void)node:(W2STSDKNode *)node connectionDidChange:(W2STSDKNodeConnectionStatus)connectionStatus;
- (void)node:(W2STSDKNode *)node readingDidChange:(BOOL)readingStatus;
- (void)node:(W2STSDKNode *)node dataDidUpdate:(NSString *)what param:(NSString *)param;
- (void)node:(W2STSDKNode *)node configurationDidChange:(NSString *)what;
@end

@protocol W2STSDKNodeBleConnectionParamDelegate <NSObject>
@required
- (void) node:(W2STSDKNode *)node didChangeRssi:(NSInteger)newRssi;
- (void) node:(W2STSDKNode *)node didChangeTxPower:(NSInteger)newPower;

@end

#endif

