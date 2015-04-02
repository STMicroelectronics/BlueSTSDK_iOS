//
//  W2STSDKNode.m
//  W2STSDK-CB
//
//  Created by Antonino Raucea on 18/03/14.
//  Copyright (c) 2014 STMicroelectronics. All rights reserved.
//

/////////////new sdk///////////////////
@import ObjectiveC;
@import CoreFoundation;

#import "W2STSDKNode.h"
#import "W2STSDKFeature.h"
#import "Util/W2STSDKBleAdvertiseParser.h"
#import "Util/W2STSDKBleNodeDefines.h"

@interface W2STSDKNode()
-(void)buildAvailableFeatures:(featureMask_t)mask maskFeatureMap:(NSDictionary*)maskFeatureMap;

-(W2STSDKFeature*) buildFeatureFromClass:(Class)featureClass;
@end

//private static variable
static dispatch_queue_t sNotificationQueue;

@implementation W2STSDKNode {
    //NSMutableArray *_notifiedCharacteristics;
    //CBCharacteristic *_controlCharacteristic;
    CBPeripheral *mPeripheral;
    NSMutableSet *mBleConnectionDelegates;
    NSMutableSet *mNodeStatusDelegates;
    
    NSMutableDictionary *mMaskToFeature;
    CFMutableDictionaryRef mCharFeatureMap;
    NSMutableArray *mAvailableFeature;
    
    BOOL _notifiedReading;
    BOOL _connectAndReading;
    NSTimer *_readingBatteryStatusTimer;
    BOOL _readingBatteryRequired;
    NSTimer *_readingRSSIStatusTimer;
}
////////////////////////////////////

#define WORKAROUND_READLENGTHFIELD 1

static int nodeCount = 0;

NSString *W2STSDKMotionServiceUUIDString         = @"02366E80-CF3A-11E1-9AB4-0002A5D5C51B"; //Motion service
NSString *W2STSDKEnvironmentalServiceUUIDString  = @"42821A40-E477-11E2-82D0-0002A5D5C51B"; //Environment service
NSString *W2STSDKCommandServiceUUIDString        = @"03366E80-CF3A-11E1-9AB4-0002A5D5C51B"; //Config service

NSString *W2STSDKMotionCharacteristicUUIDString  = @"230A1B80-CF4B-11E1-AC36-0002A5D5C51B"; //Motion char
NSString *W2STSDKAHRSCharacteristicUUIDString    = @"240A1B80-CF4B-11E1-AC36-0002A5D5C51B"; //AHRS char
NSString *W2STSDKEnvCharacteristicUUIDString     = @"250A1B80-CF4B-11E1-AC36-0002A5D5C51B"; //Environment char

NSString *W2STSDKConfCharacteristicUUIDString    = @"360A1B80-CF4B-11E1-AC36-0002A5D5C51B"; //Config char
NSString *W2STSDKBatteryCharacteristicUUIDString    = @"350A1B80-CF4B-11E1-AC36-0002A5D5C51B"; //Battery char

NSString *W2STSDKAllGroup     = @"AllData";
NSString *W2STSDKMotionGroup  = @"MotionData";
NSString *W2STSDKAHRSGroup    = @"AHRSData";
NSString *W2STSDKEnvGroup     = @"EnvData";


NSString *W2STSDKNodeConfigGeneric   = @"generic";
NSString *W2STSDKNodeConfigParamName      = @"param:name";
NSString *W2STSDKNodeConfigParamAddrBLE   = @"param:address ble";
NSString *W2STSDKNodeConfigParamMode      = @"param:mode";
NSString *W2STSDKNodeConfigParamINEMO     = @"param:inemo engine";
NSString *W2STSDKNodeConfigFreqBoard      = @"freq:board";
NSString *W2STSDKNodeConfigFreqMEMS       = @"freq:mems char";
NSString *W2STSDKNodeConfigFreqEnv        = @"freq:env char";
NSString *W2STSDKNodeConfigFreqAHRS       = @"freq:ahrs char";
NSString *W2STSDKNodeConfigToolCalibr     = @"tool:calibration";
NSString *W2STSDKNodeConfigToolFWUpdt     = @"tool:firmware update";

static NSDictionary * boardNames = nil;
static NSDictionary * uuid2group = nil;
static NSDictionary * group2map = nil;

-(void)startReadingBatteryStatusTimer {
    if (_readingBatteryStatusTimer != nil && [_readingBatteryStatusTimer isValid]) {
        [_readingBatteryStatusTimer invalidate];
        _readingBatteryStatusTimer = nil;
    }
    _readingBatteryRequired = NO;
    _readingBatteryStatusTimer = [NSTimer timerWithTimeInterval:5.0f target:self selector:@selector(readingBatteryStatusTimerTick:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_readingBatteryStatusTimer forMode:NSDefaultRunLoopMode];
}

-(void)stopReadingBatteryStatusTimer {
    _readingBatteryRequired = NO;
    if (_readingBatteryStatusTimer != nil && [_readingBatteryStatusTimer isValid]) {
        [_readingBatteryStatusTimer invalidate];
    }
    _readingBatteryStatusTimer = nil;
}

-(void)readingBatteryStatusTimerTick:(NSTimer *)timer {
    if (!_local) {
        _readingBatteryRequired = YES;
        NSLog(@"Reading Battery Timer REQUIRED for node (%d) %@", nodeCount, self.name);
//        if (self.isConnected && self.peripheral) {
//            //NSLog(@"Reading Battery Timer node (%d) %@", nodeCount, self.name);
//            if (_batteryCharacteristic) {
//                [self.peripheral readValueForCharacteristic:_batteryCharacteristic];
//            }
//        }
    }
}

-(void)startReadingRSSIStatusTimer {
    if (_readingRSSIStatusTimer != nil && [_readingRSSIStatusTimer isValid]) {
        [_readingRSSIStatusTimer invalidate];
        _readingRSSIStatusTimer = nil;
    }
    _readingRSSIStatusTimer = [NSTimer timerWithTimeInterval:2.0f target:self selector:@selector(readingRSSIStatusTimerTick:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_readingRSSIStatusTimer forMode:NSDefaultRunLoopMode];
}

-(void)stopReadingRSSIStatusTimer {
    if (_readingRSSIStatusTimer != nil && [_readingRSSIStatusTimer isValid]) {
        [_readingRSSIStatusTimer invalidate];
    }
    _readingRSSIStatusTimer = nil;
}
-(void)readingRSSIStatusTimerTick:(NSTimer *)timer {
    if (!_local) {
        if (self.isConnected && mPeripheral) {
            //NSLog(@"Reading RSSI Timer node (%d) RSSI:%@db", nodeCount, self.RSSI);
            [mPeripheral readRSSI];
        }
    }
}
/*
-(id) initStatus:(W2STSDKNodeStatus)status cstatus:(W2STSDKNodeConnectionStatus)cstatus {
    //self = [self init:nil manager:nil local:YES];
    self = [super init];
    self.status = status;
    self.connectionStatus = cstatus;
    return self;
}
*/
-(id) init:(CBPeripheral *)peripheral manager:(W2STSDKManager *)manager local:(BOOL)local {
    static dispatch_once_t onceToken;
    
    _notifiedReading = NO;
    _connectAndReading = NO;
    
    self = [super init];
    
    nodeCount++;
    
    _readingBatteryStatusTimer = nil;
    _readingRSSIStatusTimer = nil;
    
    dispatch_once(&onceToken, ^{
        boardNames = @{ [[NSNumber alloc] initWithInt:W2STSDKNodeBoardNameCodeUnknown    ] : @"Unknown",
                        [[NSNumber alloc] initWithInt:W2STSDKNodeBoardNameCodeNone       ] : @"None",
                        [[NSNumber alloc] initWithInt:W2STSDKNodeBoardNameCodeGeneric    ] : @"Generic",
                        [[NSNumber alloc] initWithInt:W2STSDKNodeBoardNameCodeWeSU       ] : @"WeSU",
                        [[NSNumber alloc] initWithInt:W2STSDKNodeBoardNameCodeL1Disco    ] : @"L1-discovery",
                        [[NSNumber alloc] initWithInt:W2STSDKNodeBoardNameCodeWeSU2      ] : @"WeSU2",
                        [[NSNumber alloc] initWithInt:W2STSDKNodeBoardNameCodeLocal      ] : @"Local",
                        };
        
        uuid2group = @{W2STSDKMotionCharacteristicUUIDString  : W2STSDKMotionGroup,
                       W2STSDKAHRSCharacteristicUUIDString    : W2STSDKAHRSGroup,
                       W2STSDKEnvCharacteristicUUIDString     : W2STSDKEnvGroup,
                       };
        group2map = @{W2STSDKMotionGroup : [NSNumber numberWithInt:W2STSDKNodeFrameGroupMotion],
                      W2STSDKAHRSGroup   : [NSNumber numberWithInt:W2STSDKNodeFrameGroupAHRS],
                      W2STSDKEnvGroup    : [NSNumber numberWithInt:W2STSDKNodeFrameGroupEnvironment],
                      };
    });
    
   /* if (manager == nil)
    {
        @throw [NSException
                exceptionWithName:@"InvalidArgumentException"
                reason:@"Manager can't be null"
                userInfo:nil];
    }
    */
    
    _notifiedCharacteristics = [[NSMutableArray alloc] init];
    _configCharacteristic = nil;
    
    //data initialization
    _features = [[NSMutableDictionary alloc] init];
    _valueFeatures = [[NSMutableArray alloc] init];
    _params = [[NSMutableDictionary alloc] init];
    
    //node initialization
    _status = W2STSDKNodeStatusOldInit;
    _connectionStatus = W2STSDKNodeConnectionStatusUnknown;
    _local = local;

    _manager = manager;
    _tag= peripheral.identifier.UUIDString;
    
    //ble properties
    _name = @"noname";
    
    _txPowerLastUpdate = nil;
    _rssiLastUpdate = nil;
    _scanLastDone = nil;
    
    //bmesh initialitation
    _hwFeatureByte = 0x00;
    _swFeatureByte = 0x00;
    _boardNameCode = W2STSDKNodeBoardNameCodeUnknown;
    
    //init as local
    _advManuData = nil;
    _RSSI = @0;
    _battery = -1;
    _rechargeStatus = 0;
    if (_local == NO)
    {
        
        if (peripheral == nil)
        {
            @throw [NSException
                    exceptionWithName:@"InvalidArgumentException"
                    reason:@"Peripheral can't be null"
                    userInfo:nil];
        }

        mPeripheral = peripheral;
        mPeripheral.delegate = self;
        _boardNameCode = W2STSDKNodeBoardNameCodeNone;
        _info = @"";
        [self startReadingBatteryStatusTimer];
        [self startReadingRSSIStatusTimer];
        
    }
    else {
        [self configureAsLocal];
    }

    return self;
}
-(id) init {
    return [self init:nil manager:nil local:YES];
}
-(id) initAsLocal:(W2STSDKManager *)manager {
    return [self init:nil manager:manager local:YES];
}


- (int16_t)featureByte {
    return ((_hwFeatureByte<<8) | _swFeatureByte);
}
-(void)configureAsLocal {
    //bmesh initialitation
    //_hwFeatureByte = (int)W2STSDKNodeFeatureHWAcce | (int)W2STSDKNodeFeatureHWGyro | (int)W2STSDKNodeFeatureHWMagn | (int)W2STSDKNodeFeatureHWTemp;
    //_swFeatureByte = (int)W2STSDKNodeFeatureSWAHRS;
    _hwFeatureByte = 0xF4; //0xC0; //0xFF;
    _swFeatureByte = 0x80; //0xFF;
    
    _name = @"your device"; //get the name of device
    _boardNameCode = W2STSDKNodeBoardNameCodeLocal;
    _info = @"none";
    
    [self populateFeatures];
}
+(NSString *)configKeyFromCode:(W2STSDKNodeConfigCode)code {
    NSString * ret = W2STSDKNodeConfigGeneric;
    
    switch(code) {
        case W2STSDKNodeConfigGenericCode:       ret = W2STSDKNodeConfigGeneric; break;
        case W2STSDKNodeConfigParamNameCode:     ret = W2STSDKNodeConfigParamName; break;
        case W2STSDKNodeConfigParamAddrBLECode:  ret = W2STSDKNodeConfigParamAddrBLE; break;
        case W2STSDKNodeConfigParamModeCode:     ret = W2STSDKNodeConfigParamMode; break;
        case W2STSDKNodeConfigParamINEMOCode:    ret = W2STSDKNodeConfigParamINEMO; break;
        case W2STSDKNodeConfigFreqBoardCode:     ret = W2STSDKNodeConfigFreqBoard; break;
        case W2STSDKNodeConfigFreqMEMSCode:      ret = W2STSDKNodeConfigFreqMEMS; break;
        case W2STSDKNodeConfigFreqEnvCode:       ret = W2STSDKNodeConfigFreqEnv; break;
        case W2STSDKNodeConfigFreqAHRSCode:      ret = W2STSDKNodeConfigFreqAHRS; break;
        case W2STSDKNodeConfigToolCalibrCode:    ret = W2STSDKNodeConfigToolCalibr; break;
        case W2STSDKNodeConfigToolFWUpdtCode:    ret = W2STSDKNodeConfigToolFWUpdt; break;
    }
    return ret;
}

+(W2STSDKNodeConfigCode)configCodeFromKey:(NSString *)key {
    W2STSDKNodeConfigCode ret = W2STSDKNodeConfigGenericCode;
    
    if (key == W2STSDKNodeConfigGeneric) {
        ret = W2STSDKNodeConfigGenericCode;
    }
    else if (key == W2STSDKNodeConfigParamName) {
        ret = W2STSDKNodeConfigParamNameCode;
    }
    else if (key == W2STSDKNodeConfigParamAddrBLE) {
        ret = W2STSDKNodeConfigParamAddrBLECode;
    }
    else if (key == W2STSDKNodeConfigParamMode) {
        ret = W2STSDKNodeConfigParamModeCode;
    }
    else if (key == W2STSDKNodeConfigParamINEMO) {
        ret = W2STSDKNodeConfigParamINEMOCode;
    }
    else if (key == W2STSDKNodeConfigFreqBoard) {
        ret = W2STSDKNodeConfigFreqBoardCode;
    }
    else if (key == W2STSDKNodeConfigFreqMEMS) {
        ret = W2STSDKNodeConfigFreqMEMSCode;
    }
    else if (key == W2STSDKNodeConfigFreqEnv) {
        ret = W2STSDKNodeConfigFreqEnvCode;
    }
    else if (key == W2STSDKNodeConfigFreqAHRS) {
        ret = W2STSDKNodeConfigFreqAHRSCode;
    }
    else if (key == W2STSDKNodeConfigToolCalibr) {
        ret = W2STSDKNodeConfigToolCalibrCode;
    }
    else if (key == W2STSDKNodeConfigToolFWUpdt) {
        ret = W2STSDKNodeConfigToolFWUpdtCode;
    }
    return ret;
}
+(W2STSDKNodeBoardNameCode)nameBoardFromCode:(NSInteger)code {
    W2STSDKNodeBoardNameCode ret = W2STSDKNodeBoardNameCodeUnknown;
    
    if (code == (int)W2STSDKNodeBoardNameCodeGeneric || code == (int)W2STSDKNodeBoardNameCodeWeSU || code == (int)W2STSDKNodeBoardNameCodeL1Disco)
    {
        ret = (W2STSDKNodeBoardNameCode)code;
    }
    return ret;
}

+(NSString *)nameBoard:(W2STSDKNodeBoardNameCode)code {
    NSString * ret = @"Invalid";
    
    switch (code) {
        case W2STSDKNodeBoardNameCodeUnknown:
        case W2STSDKNodeBoardNameCodeNone:
        case W2STSDKNodeBoardNameCodeLocal:
        case W2STSDKNodeBoardNameCodeGeneric:
        case W2STSDKNodeBoardNameCodeWeSU:
        case W2STSDKNodeBoardNameCodeL1Disco:
        {
            ret = boardNames[[[NSNumber alloc ] initWithInt:code]];
        }
            break;
        default:
            break;
    }
    return ret;
}
+(NSString *)stateStr:(CBPeripheral *)peripheral {
    NSString * res = @"";
    switch (peripheral.state) {
        case CBPeripheralStateConnected:
            res = @"Connected";
            break;
        case CBPeripheralStateConnecting:
            res = @"Connecting";
            break;
        case CBPeripheralStateDisconnected:
            res = @"Disconnected";
            break;
        default:
            res = @"Unknown";
            break;
    }
    return res;
}
+(NSString *)uuid2groupSafe:(NSString *)uuid {
    return [[uuid2group allKeys] containsObject:uuid] ? uuid2group[uuid] : @"";
}
+(W2STSDKNodeFrameGroup)group2mapSafe:(NSString *)group {
    return [[group2map allKeys] containsObject:group] ? (W2STSDKNodeFrameGroup)[(NSNumber*)group2map[group] intValue] : W2STSDKNodeFrameGroupUndefined;
}
-(BOOL)isSupportedBoard {
    return (int)_boardNameCode <= (int)W2STSDKNodeBoardNameCodeLocal || _boardNameCode == W2STSDKNodeBoardNameCodeUnknown ? YES : NO;
}
-(NSString *)nameBoardGetString {
    return [[self class] nameBoard:_boardNameCode];
}


-(BOOL)updateBLEProperties:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI enableDelegate:(BOOL)enableDelegate {
    BOOL changed,changed_advr, changed_rssi;
    changed_advr = [self updateAdvertisement:advertisementData enableDelegate:NO];
    changed_rssi = [self updateRSSI:RSSI enableDelegate:NO];

    changed = changed_advr || changed_rssi;
    if (enableDelegate && changed) {
        [_delegate node:self dataDidUpdate:W2STSDKNodeChangeAllVal param:@""];
    }
    return changed;
}
-(BOOL)updateAdvertisement:(NSDictionary *)advertisementData enableDelegate:(BOOL)enableDelegate {
    BOOL featureDidchange = NO;
    int hw_feature = 0x00;
    int sw_feature = 0x00;

    if (advertisementData != nil)
    {
        NSLog(@"Advertisement %@", [advertisementData description]);
        
        //set last advertise received, to remove boards if no long time communication (ie turned-off, connected, ...)
        _scanLastDone = [NSDate date];

        if ([[advertisementData allKeys] containsObject:CBAdvertisementDataManufacturerDataKey])
        {
            //there are manufactured data
            _advManuData = [[NSData  alloc] initWithData:advertisementData[CBAdvertisementDataManufacturerDataKey]];
            if ([_advManuData length] == 3)
            {
                unsigned char boardData[10];
                [_advManuData getBytes:boardData length:10];
            
                //the manufactured data are 3 bytes (correctly)
                //I know only 3 boards, but I suppose other boards suppoorting the same protocol (future release)
                 _boardNameCode = [W2STSDKNode nameBoardFromCode:boardData[1]];
                hw_feature = boardData[0] & W2STSDK_NODE_BRD_FEA_MASK_HW_VALID;
                sw_feature = boardData[2] & W2STSDK_NODE_BRD_FEA_MASK_SW_VALID;
            }
            else
            {
                _boardNameCode = W2STSDKNodeBoardNameCodeNone;
                hw_feature = 0x00; //no hw features
                sw_feature = 0x00; //no sw features
            }
            
            featureDidchange = _hwFeatureByte != hw_feature || _swFeatureByte != sw_feature;
            if (featureDidchange) {
                _hwFeatureByte = hw_feature;
                _swFeatureByte = sw_feature;
                [self populateFeatures];
            }
        }
                
        if ([[advertisementData allKeys] containsObject:CBAdvertisementDataTxPowerLevelKey])
        {
            _txPower = advertisementData[CBAdvertisementDataTxPowerLevelKey];
        }
        
        if ([[advertisementData allKeys] containsObject:CBAdvertisementDataIsConnectable])
        {
            //NSString * v = advertisementData[CBAdvertisementDataIsConnectable];
            //_isConnectable = [v isEqual:@"1"] ? YES : NO;
            _isConnectable = YES;
        }
        
        if ([[advertisementData allKeys] containsObject:@"kCBAdvDataChannel"])
        {
            _channel = advertisementData[@"kCBAdvDataChannel"];
        }
    }
    //_info = [[NSString alloc] initWithFormat:@"0x%02X 0x%02X", _hwFeatureByte, _swFeatureByte];
    
    //_invoke the delegate for update
    if (enableDelegate) {
        [_delegate node:self dataDidUpdate:W2STSDKNodeChangeAdvertisementVal param:@""];
    }
    return YES;
}
-(BOOL)updateRSSI:(NSNumber *)RSSI enableDelegate:(BOOL)enableDelegate {
    BOOL changed = (int)_RSSI != (int)RSSI;
    //NSTimeInterval ti = _rssiLastUpdate == nil ? 1000.0 : [_rssiLastUpdate timeIntervalSinceNow];
    
    if (changed)
    {
        _RSSI = RSSI;
        _rssiLastUpdate = [NSDate date];
        
        //generate a delegate if changed
        if (enableDelegate) {
            [_delegate node:self dataDidUpdate:W2STSDKNodeChangeRSSIVal param:@""];
        }
    }
    
    return changed;
}

-(void)updateLiveTime {
    _leaveTime = [NSDate date];
}
-(BOOL)checkLiveTime {
    if (_local) {
        return YES;
    }
    
    BOOL changed = NO;
    W2STSDKNodeStatusOld nextStatus = _status;
    if (_status != W2STSDKNodeStatusOldDead) {
        //if no check
        nextStatus = W2STSDKNodeStatusOldNormalNoCheck;
        if (_leaveTime != nil) {
            //check enable
            //if connect then the node is always in normal state
            //else check if in dead state
            nextStatus = W2STSDKNodeStatusOldNormal;
            if (_status == W2STSDKNodeStatusOldNormal) {
                if (![self isConnected]) {
                    NSDate *now = [NSDate date];
                    NSDate *lst = _leaveTime;
                    NSTimeInterval t_sec = [now timeIntervalSinceDate:lst];
                    if (t_sec > DEAD_TIME) {
                        NSLog(@"Dead node: %@ %0.2f %@", _name, t_sec, lst);
                        nextStatus = W2STSDKNodeStatusOldDead;
                    }
                }
            }
            
        }
    }
    else {
        //check advertise
        NSDate *now = [NSDate date];
        NSDate *lst = _leaveTime;
        NSTimeInterval t_sec = [now timeIntervalSinceDate:lst];
        
        if (t_sec < DEAD_TIME) {
            NSLog(@"Resumed node: %@ %0.2f %@", _name, t_sec, lst);
            nextStatus = W2STSDKNodeStatusOldResumed;
        }
    }
    changed = nextStatus != _status;
    if (changed) {
        _status = nextStatus;
            
        [_delegate node:self statusDidChange:_status];
    }
    return changed;
}

- (BOOL)featureAvailable:(NSString *)featureKey {
    BOOL ret = NO;
    
//    BOOL is_hw_fea = ((uint)fea & 0x100) == 0x100 ? NO : YES;
//    uint map = is_hw_fea ? _hwFeatureByte : _swFeatureByte;
//    uint bit = fea & 0x00ff;
//    ret = (map & bit) == bit ? YES : NO;
    
    ret = [[_features allKeys] containsObject:featureKey];
    return ret;
}
- (W2STSDKFeature *)featureWithKey:(NSString *)featureKey {
    return [self featureAvailable:featureKey] ? _features[featureKey] : nil;
}
- (BOOL)paramAvailable:(NSString *)paramKey {
    BOOL ret = NO;
    
    ret = [[_params allKeys] containsObject:paramKey];
    return ret;
}

// have to call on each advertisement and not connected
- (BOOL)populateFeatures {
    BOOL ret = NO;
    //if (![self isConnected]) {
        ret = YES;
        [_features removeAllObjects];
        [_valueFeatures removeAllObjects];
        //[_params removeAllObjects];
        
        W2STSDKNodeFeature mapFea;
        int valFea = 0;
        
        for(NSString * key in [W2STSDKFeature allKeys]) {
            mapFea = [W2STSDKFeature mapLookup:key];
            if (mapFea != W2STSDKNodeFeatureInvalid) {
                valFea = [W2STSDKFeature isHardware:mapFea] ? _hwFeatureByte : _swFeatureByte;
                
                if ([W2STSDKFeature checkAvailabilityInMap:valFea map:mapFea]) {
                    W2STSDKFeature *feature = [[W2STSDKFeature alloc] init:key node:self];
                    [_features setObject:feature forKey:key];
                    [_valueFeatures addObject:feature];
                }
            }
        }
        
        [self populateParams];
    //}
    return ret;
}

// have to call on connect (on disconnect remove all object)
- (BOOL)populateParams {
    BOOL ret = NO;
    W2STSDKParam *param = nil;
    NSString *keyFeature = @"";
    W2STSDKFeature *feature = nil;
    
    [_params removeAllObjects];
    for(W2STSDKFeature *fea in [_features allValues]) {
        [fea.params removeAllObjects];
    }
    
    //if ([self isConnected]) {
        ret = YES;
        
        for(NSString *key in [W2STSDKParam allKeys])
        {
            //check if this feature is available for the this board
            keyFeature =[W2STSDKParam keyFeature:key]; //get the key of the feature (derived from the key of the param)
            feature = nil;
            if ([[_features allKeys] containsObject:keyFeature]) {
                feature = _features[keyFeature];
            }
            
            if (feature != nil){
                //add the param
                param = [[W2STSDKParam alloc] init:key feature:feature node:self];
                [_params setObject:param forKey:key];
                [feature.params addObject:param]; //link the param in the feature
            }
        }
    //}
    
    return ret;
}

- (BOOL)_connect:(BOOL)conn{
    if (_local) {
        _connectionStatus = conn ? W2STSDKNodeConnectionStatusConnected : W2STSDKNodeConnectionStatusDisconnected;
        [_delegate node:self connectionDidChange:_connectionStatus];
        return YES;
    }
    
    BOOL ret = NO;
	/*if (_manager != nil && _manager.central != nil && _manager.central.centralManager != nil && _peripheral != nil) {
        
        if ((conn && _peripheral.state == CBPeripheralStateDisconnected && _isConnectable)
            ||
            (!conn && _peripheral.state != CBPeripheralStateDisconnected))
        {
            assert (_notifiedCharacteristics != nil);
            [_notifiedCharacteristics removeAllObjects];
            _configCharacteristic = nil;
            
            //performing a ...
            if (conn) {
                //connect
                _peripheral.delegate = self;
                _connectionStatus = W2STSDKNodeConnectionStatusConnecting;
                [_delegate node:self connectionDidChange:_connectionStatus];
                [_manager.central.centralManager connectPeripheral:_peripheral options:nil];
            }
            else {
                //disconnect
                _peripheral.delegate = nil;
                _connectionStatus = W2STSDKNodeConnectionStatusDisconnecting;
                [_delegate node:self connectionDidChange:_connectionStatus];
                [_manager.central.centralManager cancelPeripheralConnection:_peripheral];
            }
            ret = YES;
        }
	}
     */

    return ret;
}
/*
- (BOOL)connectAndReading {
    _connectAndReading = YES;
    return [self _connect:YES];
 
}

- (BOOL)connect {
    return [self _connect:YES];
}
- (BOOL)disconnect {
    return [self _connect:NO];
}
 
- (BOOL)toggleConnect {
    return [self _connect:!self.isConnected];
}
- (BOOL)isConnected {
    //[self updateConnectionStatus];
    return _connectionStatus == W2STSDKNodeConnectionStatusConnected ? YES : NO;
}
 */

/*
 * Called when a connect/disconnect event occurs in a peripheral
 */
-(BOOL)updateConnectionStatus {
    if (_local) {
        [_delegate node:self connectionDidChange:_connectionStatus];
        return YES;
    }

    //we're introduced 2 new states connecting and disconnecting, so the changed if always true ...
    //BOOL changed = NO;
    //W2STSDKNodeConnectionStatus previous = _connectionStatus;
    
    //if in disconnecting stop the reading
    /*
    if (_connectionStatus == W2STSDKNodeConnectionStatusDisconnecting) {
        [self reading:NO];
    }
     */
    
    if (mPeripheral != nil) {
        _connectionStatus = mPeripheral.state == CBPeripheralStateConnected ? W2STSDKNodeConnectionStatusConnected : W2STSDKNodeConnectionStatusDisconnected;
    }
    else {
        _connectionStatus = W2STSDKNodeConnectionStatusUnknown;
    }
    
    //[self populateParams]; //if not connected remove all objects
    [_delegate node:self connectionDidChange:_connectionStatus];
    
    //performe discovery of the services
    if (_connectionStatus == W2STSDKNodeConnectionStatusConnected) {
        //start a services discovery
        _leaveTime = nil;
        NSArray *serviceUUIDs = nil; //@[[CBUUID UUIDWithString:W2STSDKMotionServiceUUIDString]]; //select all services and search the known characteristics
        [mPeripheral discoverServices:serviceUUIDs];
        
//        if (_connectAndReading) {
//            [self reading:YES];
//            _connectAndReading = NO;
//        }
    }
    
    if (_connectionStatus == W2STSDKNodeConnectionStatusDisconnected) {
        [self updateLiveTime];
    }
    return YES;
}


/**** Reading data ****/
-(BOOL) isReading
{
    return _notifiedReading;
}
-(void) reading:(BOOL)enable {
    if (_local) {
        static NSTimer *timerReadingLocal = nil;
        _notifiedReading = enable;
        //enable a timer to read data from sensors available inside the device
        [timerReadingLocal invalidate];
        timerReadingLocal = nil;
        if (enable) {
            timerReadingLocal = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(readingLocal:) userInfo:nil repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:timerReadingLocal forMode:NSDefaultRunLoopMode];
        }
    }
    else {
        if (_notifiedCharacteristics != nil && _notifiedCharacteristics.count > 0) {
            _notifiedReading = enable;
            [self readingSync];
            [_delegate node:self readingDidChange:_notifiedReading];
        }
    }
}

short v_count = 0;
typedef struct {
    short time;
    short acce_x;
    short acce_y;
    short acce_z;
    short gyro_x;
    short gyro_y;
    short gyro_z;
    short magn_x;
    short magn_y;
    short magn_z;
} frameMotion_t;
typedef struct {
    short time;
    int pressure;
    short temperature;
    short humidity;
} frameEnvironment_t;
typedef struct {
    short time;
    float qx;
    float qy;
    float qz;
    float qw;
} frameAHRS_t;

frameMotion_t frameMotion;
frameEnvironment_t frameEnvironment;
frameAHRS_t frameAHRS;

int my_irand(int min, int max) {
    return (int)my_drand((double)min, (double)max);
}
float my_frand(float min, float max) {
    return (float)my_drand((double)min, (double)max);
}
double my_drand(double min, double max) {
    int n = rand();
    double r = (((double)n/(double)RAND_MAX) * (double)(max - min)) + (double)min;
    return r;
}
-(void)readingLocal:(NSTimer *)timer {
    assert(_local);
    int k = v_count >= 9 ? 9 : v_count;
    //update randomly the vars
    if (v_count == 0) {
        memset((void *)&frameMotion, 0, sizeof(frameMotion_t));
        memset((void *)&frameEnvironment, 0, sizeof(frameEnvironment_t));
        memset((void *)&frameAHRS, 0, sizeof(frameAHRS_t));
    }
    
    frameMotion.time = v_count;
    frameMotion.acce_x = (frameMotion.acce_x * k + my_irand(-2000, 2000)) / (k + 1);
    frameMotion.acce_y = (frameMotion.acce_y * k + my_irand(-2000, 2000)) / (k + 1);
    frameMotion.acce_z = (frameMotion.acce_z * k + my_irand(-2000, 2000)) / (k + 1);
    
    frameMotion.gyro_x = (frameMotion.gyro_x * k + my_irand(-200, 200)) / (k + 1);
    frameMotion.gyro_y = (frameMotion.gyro_y * k + my_irand(-200, 200)) / (k + 1);
    frameMotion.gyro_z = (frameMotion.gyro_z * k + my_irand(-200, 200)) / (k + 1);

    frameMotion.magn_x = (frameMotion.magn_x * k + my_irand(-800, 800)) / (k + 1);
    frameMotion.magn_y = (frameMotion.magn_y * k + my_irand(-800, 800)) / (k + 1);
    frameMotion.magn_z = (frameMotion.magn_z * k + my_irand(-800, 800)) / (k + 1);

    frameEnvironment.time = v_count;
    frameEnvironment.pressure = (frameEnvironment.pressure * k + my_irand(980, 1080)) / (k + 1);
    frameEnvironment.temperature = (frameEnvironment.temperature * k + my_irand(0, 100)) / (k + 1);
    
    frameAHRS.time = v_count;
//    float qx = frameAHRS.qx;
//    float qy = frameAHRS.qy;
//    float qz = frameAHRS.qz;
//    float qw = frameAHRS.qw;
//
//    
//    qx = 0.707; //(qx * k + (my_frand(0.0f, 1.0f))) / (k + 1);
//    qy = 0.707; //(qy * k + (my_frand(0.0f, 1.0f))) / (k + 1);
//    qz = 0; //(qz * k + (my_frand(0.0f, 1.0f))) / (k + 1);
//    qw = 0; //(qw * k + (my_frand(0.0f, 1.0f))) / (k + 1);
    
    frameAHRS.qx = (frameAHRS.qx * k + (my_frand(0.0f, 1.0f))) / (k + 1);
    frameAHRS.qy = (frameAHRS.qy * k + (my_frand(0.0f, 1.0f))) / (k + 1);
    frameAHRS.qz = (frameAHRS.qz * k + (my_frand(0.0f, 1.0f))) / (k + 1);
    //frameAHRS.qw = (frameAHRS.qw * k + (my_frand(0.0f, 1.0f))) / (k + 1);
    frameAHRS.qw = sqrtf(1 - (powf(frameAHRS.qx, 2) + powf(frameAHRS.qy, 2) + powf(frameAHRS.qz, 2)));
    
    /**** motion ****/
    
    //add time
    NSData *data;
    uint8_t pos = 0, l=0;
    unsigned char buffer[0x20];

    pos=0;
    memset(buffer, 0x00, 0x20);
    memcpy(&buffer[pos], &frameMotion.time, l=2); pos+=l;
    memcpy(&buffer[pos], &frameMotion.acce_x, l=2); pos+=l;
    memcpy(&buffer[pos], &frameMotion.acce_y, l=2); pos+=l;
    memcpy(&buffer[pos], &frameMotion.acce_z, l=2); pos+=l;
    memcpy(&buffer[pos], &frameMotion.gyro_x, l=2); pos+=l;
    memcpy(&buffer[pos], &frameMotion.gyro_y, l=2); pos+=l;
    memcpy(&buffer[pos], &frameMotion.gyro_z, l=2); pos+=l;
    memcpy(&buffer[pos], &frameMotion.magn_x, l=2); pos+=l;
    memcpy(&buffer[pos], &frameMotion.magn_y, l=2); pos+=l;
    memcpy(&buffer[pos], &frameMotion.magn_z, l=2); pos+=l;

    data = [[NSData alloc] initWithBytes:(void *)buffer length:sizeof(frameMotion)];
    [self updateValueWithData:data group:W2STSDKMotionGroup];
    
    /*
    [self.features[W2STSDKNodeFeatureHWAccelerometerKey] updateData:data position:2 time:frameMotion.time];
    [self.features[W2STSDKNodeFeatureHWGyroscopeKey] updateData:data position:8 time:frameMotion.time];
    [self.features[W2STSDKNodeFeatureHWMagnetometerKey] updateData:data position:14 time:0];
     */
    
    pos=0;
    memset(buffer, 0x00, 0x20);
    memcpy(&buffer[pos], &frameEnvironment.time, l=2); pos+=l;
    memcpy(&buffer[pos], &frameEnvironment.pressure, l=4); pos+=l;
    memcpy(&buffer[pos], &frameEnvironment.temperature, l=2); pos+=l;
    memcpy(&buffer[pos], &frameEnvironment.humidity, l=2); pos+=l;
    data = [[NSData alloc] initWithBytes:(void *)buffer length:sizeof(frameEnvironment)];
    [self updateValueWithData:data group:W2STSDKEnvGroup];
    
    /*
    [self.features[W2STSDKNodeFeatureHWPressureKey] updateData:data position:2 time:0];
    [self.features[W2STSDKNodeFeatureHWTemperatureKey] updateData:data position:6 time:0];
    //[self.features[W2STSDKNodeFeatureHWHumidityKey] updateData:data position:8 time:0];
     */

    pos=0;
    
    memset(buffer, 0x00, 0x20);
    memcpy(&buffer[pos], &frameAHRS.time, l=2); pos+=l;
    memcpy(&buffer[pos], &frameAHRS.qx, l=4); pos+=l;
    memcpy(&buffer[pos], &frameAHRS.qy, l=4); pos+=l;
    memcpy(&buffer[pos], &frameAHRS.qz, l=4); pos+=l;
    memcpy(&buffer[pos], &frameAHRS.qw, l=4); pos+=l;
    data = [[NSData alloc] initWithBytes:(void *)buffer length:sizeof(frameAHRS)];
    [self updateValueWithData:data group:W2STSDKAHRSGroup];
    //[self.features[W2STSDKNodeFeatureSWAHRSKey] updateData:data position:2 time:0];

    //assert(_manager.dataLog);
    /*
    if (_manager && _manager.dataLog && _manager.dataLog.enable) {
        [_manager.dataLog addSampleWithGroup:W2STSDKNodeFrameGroupMotion node:self time:v_count save:NO];
        [_manager.dataLog addSampleWithGroup:W2STSDKNodeFrameGroupEnvironment node:self time:v_count save:NO];
        [_manager.dataLog addSampleWithGroup:W2STSDKNodeFrameGroupAHRS node:self time:v_count save:NO];
    }
     */
    v_count++;

    [_delegate node:self dataDidUpdate:W2STSDKNodeChangeDataVal param:W2STSDKAllGroup];
}
-(void) readingSync {
    if (_local) {
        return;
    }
    for (CBCharacteristic *c in _notifiedCharacteristics)
    {
        [mPeripheral setNotifyValue:_notifiedReading forCharacteristic:c];
    }
}
-(void) startReading
{
    [self reading:YES];
}

-(void) stopReading
{
    [self reading:NO];
}

-(void) toggleReading
{
    [self reading:[self isReading] ? NO : YES];
}

/* Peripheral Delegate Protocol */

//Retrive services and select the Motion service
NSArray *charDataUUIDs = nil;
NSArray *charServUUIDs = nil;
NSArray *charUUIDs = nil;
/*
-  (void)peripheral:(CBPeripheral *)peripheral
didDiscoverServices:(NSError *)error {
    if (!charDataUUIDs) {
        charDataUUIDs = @[
                          [CBUUID UUIDWithString:W2STSDKMotionCharacteristicUUIDString],
                          [CBUUID UUIDWithString:W2STSDKEnvCharacteristicUUIDString],
                          [CBUUID UUIDWithString:W2STSDKAHRSCharacteristicUUIDString],
                          ];
    }
    if (!charServUUIDs) {
        charServUUIDs = @[
                          [CBUUID UUIDWithString:W2STSDKConfCharacteristicUUIDString],
                          [CBUUID UUIDWithString:W2STSDKBatteryCharacteristicUUIDString],
                          ];
    }
    if (!charUUIDs) {
        NSMutableArray *chars = [[NSMutableArray alloc] initWithArray:charDataUUIDs];
        charUUIDs = [chars arrayByAddingObjectsFromArray:charServUUIDs];
    }
    
    for (CBService *service in peripheral.services) {
        //if ([[service UUID] isEqual:[CBUUID UUIDWithString:W2STSDKMotionServiceUUIDString]]) {
            [peripheral discoverCharacteristics:charUUIDs forService:service];
        //}
    }
}
*/

//for each services find the known characteristics
/*- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverCharacteristicsForService:(CBService *)service
             error:(NSError *)error {
    
    if (error && [error code] != 0) {
        NSLog(@"Error %@\n", error);
        return ;
    }
    
    
   // NSLog(@"- %@", service);
    for (CBCharacteristic *c in service.characteristics) {
        if ([charDataUUIDs containsObject:[c UUID]]) {
            [_notifiedCharacteristics addObject:c];
            //[_peripheral setNotifyValue:YES forCharacteristic:c]; //unselect to auto start reading
            //NSLog(@"Discovered characteristic %@", c);
        }
        else if ([[c UUID] isEqual:[CBUUID UUIDWithString:W2STSDKConfCharacteristicUUIDString]]) {
            _configCharacteristic = c;
        }
        else if ([[c UUID] isEqual:[CBUUID UUIDWithString:W2STSDKBatteryCharacteristicUUIDString]]) {
            _batteryCharacteristic = c;
        }
        else {
            //unknown char
            NSLog(@"Unknown char:%@", [c UUID]);
        }
    }
    
    if (_connectAndReading) {
        [self reading:YES];
        _connectAndReading = NO;
    }
    
    //if reading try to start the reading for new characteristics
    if (_notifiedReading) {
        [self readingSync];
    }
    
}
*/
#pragma mark - String Conversion
- (NSString *)hexadecimalString:(NSData *)data {
    /* Returns hexadecimal string of NSData. Empty string if data is empty.   */
    if (data == nil || [data length] == 0)
    {
        return @"(empty)";
    }
    const unsigned char *dataBuffer = (const unsigned char *)[data bytes];
    
    if (!dataBuffer)
        return [NSString string];
    
    NSUInteger          dataLength  = [data length];
    NSMutableString     *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
    
    for (int i = 0; i < dataLength; ++i)
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    
    return [NSString stringWithFormat:@"0x%@", hexString];
}

//internally function
unsigned int convertData(const void * buffer, const int bufferSize, int * ppos, const size_t dataSize) {
    if (buffer == NULL || ppos == NULL) {
        //generate an error
        return 0;
    }

    if (dataSize > 4 || dataSize == 0) {
        //generate an error
        return 0;
    }

    if (*ppos + dataSize > bufferSize)
    {
        //generate an exception
        return 0;
    }
    unsigned int data  = 0;

    //int is 4 bytes
    memcpy(&data, &buffer[*ppos], dataSize);
    *ppos += dataSize;
    
    return data;
}

//get the features from the group (ordered)
+(NSArray *)getFeaturesFromGroup:(NSString *)group {
    NSArray *array = nil;
    
    if ([group isEqualToString:W2STSDKMotionGroup]) {
        array = @[
                  W2STSDKNodeFeatureHWAccelerometerKey,
                  W2STSDKNodeFeatureHWGyroscopeKey,
                  W2STSDKNodeFeatureHWMagnetometerKey,
                  ];
        
    }
    else if ([group isEqualToString:W2STSDKAHRSGroup]) {
        array = @[
                  W2STSDKNodeFeatureSWAHRSKey,
                  ];
        
    }
    else if ([group isEqualToString:W2STSDKEnvGroup]) {
        array = @[
                  W2STSDKNodeFeatureHWPressureKey,
                  W2STSDKNodeFeatureHWTemperatureKey,
                  W2STSDKNodeFeatureHWHumidityKey,
                  ];
        
    }
    
    return array;
}

//get the params from the group (ordered)
+(NSArray *)getParamsFromGroup:(NSString *)group {
    NSArray *array = nil;
    
    if ([group isEqualToString:W2STSDKMotionGroup]) {
        array = @[
                  W2STSDKNodeParamHWAccelerometerXKey,
                  W2STSDKNodeParamHWAccelerometerYKey,
                  W2STSDKNodeParamHWAccelerometerZKey,
                  W2STSDKNodeParamHWGyroscopeXKey,
                  W2STSDKNodeParamHWGyroscopeYKey,
                  W2STSDKNodeParamHWGyroscopeZKey,
                  W2STSDKNodeParamHWMagnetometerXKey,
                  W2STSDKNodeParamHWMagnetometerYKey,
                  W2STSDKNodeParamHWMagnetometerZKey,
                  ];
        
    }
    else if ([group isEqualToString:W2STSDKAHRSGroup]) {
        array = @[
                  W2STSDKNodeParamSWAHRSXKey,
                  W2STSDKNodeParamSWAHRSYKey,
                  W2STSDKNodeParamSWAHRSZKey,
                  W2STSDKNodeParamSWAHRSWKey,
                  ];
        
    }
    else if ([group isEqualToString:W2STSDKEnvGroup]) {
        array = @[
                  W2STSDKNodeParamHWPressureKey,
                  W2STSDKNodeParamHWTemperatureKey,
                  W2STSDKNodeParamHWHumidityKey,
                  ];
        
    }
    
    return array;
}

- (void)peripheral:(CBPeripheral *)peripheral
didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error {
    NSString *group = @""; //key of the group received

    //check if the peripheral is correct
    if (peripheral != mPeripheral) {
        NSLog(@"Wrong peripheral\n");
        return ;
    }
    
    //get the received uuid characteristic
    NSString * uuid = [[[NSUUID alloc] initWithUUIDBytes:[characteristic.UUID.data bytes]] UUIDString];

    //check if an error is notified
    if (error != nil && [error code] != 0) {
        NSLog(@"UUID: %@ Error: %@\n", uuid, error);
        return ;
    }
    
    //get data from characteristic
    NSData *data = characteristic.value;
#if 0
    //Show received frame
    NSString *hexAllString = [self hexadecimalString:characteristic.value];
    NSLog(@"UUID: %@ Data: %@", uuid, hexAllString);
#endif
    /*
     frame structures
     raw env  [ timestamp (2 bytes) | pressure  (4 bytes) | temperature (2 bytes) | humidity   (2 bytes) ] // max 10 bytes
     raw mems [ timestamp (2 bytes) | acc x,y,z (6 bytes) | gyro x,y,z  (6 bytes) | magn x,y,z (6 bytes) ] // max 20 bytes
     ahrs     [ timestamp (2 bytes) | q0        (4 bytes) | q1          (4 bytes) | q2         (4 bytes) | q3         (4 bytes) ] // max 18 bytes
     ctrl     [ ctrl      (1 byte ) | addr      (1 byte ) | err         (1 byte ) | len        (1 byte ) | payload    (N bytes) ] // framelen = 4 + N, N = len * 2
    */
    
    uint16_t time = 0;
    [data getBytes:&time length:2];
    
    CBUUID *cbuuid = [characteristic UUID];
    if ([charDataUUIDs containsObject:cbuuid]) {
        //data
        group = [W2STSDKNode uuid2groupSafe:uuid];
        if(![group isEqualToString:@""] ) {
            [self updateValueWithData:data group:group];
            W2STSDKNodeFrameGroup framegroup = [W2STSDKNode group2mapSafe:group];
            //[_manager.dataLog addSampleWithGroup:framegroup data:data node:self save:NO];
            
            //[_manager.dataLog addSampleWithGroup:framegroup node:self time:time save:NO];
            if (framegroup == W2STSDKNodeFrameGroupEnvironment && _readingBatteryRequired && _batteryCharacteristic && mPeripheral && self.isConnected) {
                NSLog(@"Reading Battery Timer node (%d) %@", nodeCount, self.name);
                [mPeripheral readValueForCharacteristic:_batteryCharacteristic];
                _readingBatteryRequired = NO;
            }
        }
    }
    else if ([cbuuid isEqual:[CBUUID UUIDWithString:W2STSDKConfCharacteristicUUIDString]]) {
        [self updateConfigWithData:data];
    }
    else if ([cbuuid isEqual:[CBUUID UUIDWithString:W2STSDKBatteryCharacteristicUUIDString]]) {
        [self updateBatteryWithData:data];
    }
    else {
        //unknown char
        NSLog(@"Unknown char on reading:%@", cbuuid);
    }

}

- (void)updateBatteryWithData:(NSData *)data {
    const unsigned char *dataBuffer = (const unsigned char *)[data bytes];
    if (dataBuffer) {
        NSInteger batteryPrevious = self.battery;
        NSInteger rechargeStatusPrevious = self.rechargeStatus;
        self.battery = *((int16_t *)dataBuffer);
        self.rechargeStatus = *((int16_t *)(dataBuffer+2));
        if (self.battery == 0x0 && self.rechargeStatus == 0x00) {
            self.battery = -1; //I suppose the battery information is not available
        }
        //if (abs(batteryPrevious - self.battery) > 0.5) {
        if (batteryPrevious != self.battery || rechargeStatusPrevious != self.rechargeStatus) {
            NSLog(@"Battery data: B:%dm%% S:%dmA %@", (int16_t)self.battery, (int16_t)self.rechargeStatus, [data description]);
            [_delegate node:self dataDidUpdate:W2STSDKNodeChangeBatteryVal param:@""];
        }
    }
}
- (void)updateConfigWithData:(NSData *)data {
    W2STSDKCommand *cmd = [W2STSDKCommand createWithData:data];

#if WORKAROUND_READLENGTHFIELD
    //cmd.ctrlFrame.len /= 2;
#endif
    
    NSLog(@"%@", [cmd description]);
    W2STSDKCommandRegister_t ctrl_reg = [cmd getReg];
    int len_register_bytes = ctrl_reg.len * 2; //bytes
    int len_frame_hd_bytes = cmd.ctrlFrame.len; //*2 bytes
    int len_received_bytes = (int)[data length] - W2STSDK_CTRL_FRAME_HEADER_SIZE; //bytes

    BOOL check1 = cmd.ctrlFrame.ctrl.value == (ctrl_reg.mem == W2STSDK_CTRL_MEM_EEPROM ? 0x48 : 0x08); //eeprom+ack or ram+ack1
    BOOL check2 = len_received_bytes == len_frame_hd_bytes; //received a correct payload size (as header declared)
    BOOL check3 = len_register_bytes == len_frame_hd_bytes; //frame size and register size are corrects
    BOOL check4 = ctrl_reg.addr_start == cmd.ctrlFrame.addr; //check if the received address is the start register address
    if ( check1 && check2 && check3 && check4 ) {
        switch(ctrl_reg.reg) {
            case W2STSDK_CTRL_REG_EEPROM_BLE_LOC_NAME:
                {
                    //strip the \t from start
                    NSString * val = [[NSString alloc] initWithBytes:cmd.ctrlFrame.payload+1 length:len_received_bytes-1 encoding:NSASCIIStringEncoding];
                    _name = [[NSString alloc] initWithFormat:@"%@!", val];
                    NSLog(@"Name is '%@'", _name);
                }
                //
                break;
            case W2STSDK_CTRL_REG_EEPROM_BLE_PUB_ADDR:
                //get pubblic ble address
                _addressBLE = [[NSData alloc] initWithBytes:cmd.ctrlFrame.payload length:len_received_bytes];
                NSLog(@"AddressBLE is '%@'", [_addressBLE description]);
                break;
            case W2STSDK_CTRL_REG_EEPROM_LED_CTRL:
                self.led = *(short *)cmd.ctrlFrame.payload;
                NSLog(@"Led is '0x%0.4X'", (int)self.led);
                break;
            case W2STSDK_CTRL_REG_RAM_BATT_VOLT:
                //self.battery = *(short *)cmd.ctrlFrame.payload;
                //NSLog(@"Batt is '0x%0.4X'", (int)self.battery);
                break;
            default:
                break;
        }
        
        [_delegate node:self dataDidUpdate:W2STSDKNodeChangeConfigVal param:@""];
    }
}
long frame_node_count = 0;
- (void)updateValueWithData:(NSData *)data group:(NSString *)group {
    unsigned short timele = 0; //2 bytes for timestamp
    int pos = 0;

    const unsigned char *dataBuffer = (const unsigned char *)[data bytes];

    //internal frame data counting
    frame_node_count++;
    
    //get  timestamp information
    memcpy(&timele, &dataBuffer[0], 2);
    pos += 2;
    
    //get the group of the characteristic received
    
    NSArray *keys;
    keys = [W2STSDKNode getFeaturesFromGroup:group];
    for(NSString *key in keys) {
        if ([self featureAvailable:key]) {
            pos += [_features[key] updateData:data position:pos time:timele];
        }
    }
    
    [_delegate node:self dataDidUpdate:W2STSDKNodeChangeDataVal param:group];
}

/* deprecated delegate */
/*
- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"RSSI:%@db", peripheral.RSSI);
    if (error == nil && peripheral == self.peripheral) {
        [self updateRSSI:peripheral.RSSI enableDelegate:YES];
    }
}
*/
- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
    NSLog(@"RSSI:%@db", RSSI);
    if (error == nil && peripheral == mPeripheral) {
        [self updateRSSI:RSSI enableDelegate:YES];
    }
}


/**** Config ****/
-(NSString *)config:(NSString *)what {
    W2STSDKNodeConfigCode code = [W2STSDKNode configCodeFromKey:what];
    NSString *ret = @"";
    switch(code) {
        case W2STSDKNodeConfigParamNameCode:
            ret = [[NSString alloc] initWithFormat:@"%@", self.name];
            break;
        case W2STSDKNodeConfigParamAddrBLECode:
        {
            //const unsigned char * buffer = (const unsigned char *)[self.addressBLE bytes];
            //ret = [[NSString alloc] initWithFormat:@"%0.2X:%0.2X:%0.2X:%0.2X:%0.2X:%0.2X", buffer[0], buffer[1], buffer[2], buffer[3], buffer[4], buffer[5]];
            ret = @"nd"; //[[NSString alloc] initWithFormat:@"%0.2X", buffer[0]];
        }
            break;
        case W2STSDKNodeConfigParamINEMOCode:
            //ret = [[NSString alloc] initWithFormat:@"%lu", (unsigned long)self.battery];
            break;
        case W2STSDKNodeConfigParamModeCode:
            ret = [[NSString alloc] initWithFormat:@"%lu", (unsigned long)self.led];
            break;
        default:
            //nothing
            ret = @"na";
            break;
    }
    return ret;
}
-(void)forceReadingConfig {
    [mPeripheral readValueForCharacteristic:_configCharacteristic];
}
//return the controlService sent
-(W2STSDKCommand *)sendConfig:(W2STSDKCommand *)command {
    if (_configCharacteristic) {
        assert(command);
        NSData *dataToSend = command.data;
        assert(dataToSend && dataToSend.length > 0);
        
#if WORKAROUND_READLENGTHFIELD
        //workaround: only to read data, the length field is bytes (default: num register)
        if (command.ctrlFrame.ctrl.map.operation == 0) {
            unsigned char *dataBuffer = (unsigned char *)[dataToSend bytes];
            int len = (int)dataToSend.length;
            dataBuffer[3] *= 2;
            dataToSend = [[NSData alloc] initWithBytes:dataBuffer length:len];
        }
#endif
        
        NSLog(@"sendControl [%@]", [dataToSend description]);
        NSLog(@"Writing value for characteristic %@", _configCharacteristic);
        [mPeripheral writeValue:dataToSend forCharacteristic:_configCharacteristic type:CBCharacteristicWriteWithResponse];
        
        if (command.ctrlFrame.ctrl.map.operation == 0) {
            //this is a get command
            [mPeripheral readValueForCharacteristic:_configCharacteristic];
        }
    }
    return command;
}

-(NSString *)writeConfig:(NSString *)what param:(NSString *)param{
    NSLog(@"writeConfig  suspended!!!!!");
    return param;
    NSLog(@"writeConfig: %@", what);
    NSString *prm = param;
    W2STSDKCommand *cmd = nil;
    if ([what isEqual:W2STSDKNodeConfigParamName]) {
        W2STSDKCommandRegister_t reg = [W2STSDKCommand registerAtIndex:W2STSDK_CTRL_OPT_WRITE];
        int max = (reg.len<<2)-1;
        if (prm.length > max) {
         prm = [prm substringToIndex:max]; //the first must be a tab
        }
    }
    else if ([what isEqual:W2STSDKNodeConfigParamAddrBLE]) {
        
    }
    else if ([what isEqual:W2STSDKNodeConfigParamINEMO]) {
        
    }
    else if ([what isEqual:W2STSDKNodeConfigParamMode]) {
        
    }
    
    if (cmd) {
        [self sendConfig:cmd];
    }
        
    return prm;
}

-(void)getAllConfig {
    [self getConfigWithReg:W2STSDK_CTRL_REG_EEPROM_BLE_LOC_NAME];
    [self getConfigWithReg:W2STSDK_CTRL_REG_EEPROM_BLE_PUB_ADDR];
    [self getConfigWithReg:W2STSDK_CTRL_REG_RAM_BATT_VOLT];
    [self getConfigWithReg:W2STSDK_CTRL_REG_EEPROM_LED_CTRL];
}
-(void)getConfig:(NSString *)what {
    W2STSDKNodeConfigCode code = [W2STSDKNode configCodeFromKey:what];
    W2STSDKCommandRegister_e regEnum = W2STSDK_CTRL_REG_FAKE;
    switch(code) {
        case W2STSDKNodeConfigParamNameCode:
            regEnum = W2STSDK_CTRL_REG_EEPROM_BLE_LOC_NAME;
            break;
        case W2STSDKNodeConfigParamAddrBLECode:
            regEnum = W2STSDK_CTRL_REG_EEPROM_BLE_PUB_ADDR;
            break;
        case W2STSDKNodeConfigParamINEMOCode:
            regEnum = W2STSDK_CTRL_REG_RAM_BATT_VOLT;
            break;
        case W2STSDKNodeConfigParamModeCode:
            regEnum = W2STSDK_CTRL_REG_EEPROM_LED_CTRL;
            break;
        default:
            //nothing
            break;
    }
    [self getConfigWithReg:regEnum];
}
-(void)getConfigWithReg:(unsigned char)regEnum {
    if (regEnum != W2STSDK_CTRL_REG_FAKE) {
        W2STSDKCommand *cmd = nil;
        cmd = [W2STSDKCommand createWithReg:(W2STSDKCommandRegister_e)regEnum operation:W2STSDK_CTRL_OPT_READ payload:nil];
        [self sendConfig:cmd];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral
didWriteValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error {
    
    if (error) {
        NSLog(@"Error writing characteristic value: %@",
              [error localizedDescription]);
    }
    else {
        NSLog(@"Ok writing characteristic");
    }
}
-(W2STSDKCommand *)bleGetFirmwareVersion {
    //W2STSDKCommand * cs = [self sendControl: [W2STSDKCommand create:YES firmware:NO]];
    
    return nil;
}
-(W2STSDKCommand *)bleSetLed:(BOOL)state {
    return nil; //[self sendControl:[W2STSDKCommand create:NO led:state]];
}
-(W2STSDKCommand *)bleGetLed {
    //[self sendControl:[W2STSDKCommandServices create:(BOOL) firmware:<#(BOOL)#>]];
    return nil;
}
////////////////// NEW SDK ///////////

-(W2STSDKFeature*) buildFeatureFromClass:(Class)featureClass{
    return [((W2STSDKFeature*)[featureClass alloc]) initWhitNode:self];

}

-(void)buildAvailableFeatures:(featureMask_t)mask maskFeatureMap:(NSDictionary*)maskFeatureMap{
    uint32_t nBit = 8*sizeof(featureMask_t);
    mAvailableFeature = [[NSMutableArray alloc] initWithCapacity:nBit];
    mMaskToFeature = [[NSMutableDictionary alloc] initWithCapacity:nBit];
    if(maskFeatureMap==nil)
        return;
    for (uint32_t i=0; i<nBit; i++) {
        featureMask_t test = 1<<i;
        if((mask & test)!=0){
            NSNumber *temp =[NSNumber numberWithUnsignedInt:test];
            Class featureClass = [maskFeatureMap objectForKey: temp];
            if(featureClass!=nil){
                W2STSDKFeature *f = [self buildFeatureFromClass:featureClass];
                if(f!=nil){
                    [mAvailableFeature addObject:f];
                    [mMaskToFeature setObject:f forKey:temp];
                }else{
                    NSLog(@"Impossible build the feature @%",[featureClass description]);
                }//if f
            }// if featureClass
        }//if mask
    }//for
}

-(id)init:(CBPeripheral *)peripheral rssi:(NSNumber*)rssi advertise:(NSDictionary*)advertisementData{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sNotificationQueue = dispatch_queue_create("W2STNode", DISPATCH_QUEUE_CONCURRENT);
    });

    mNodeStatusDelegates = [[NSMutableSet alloc]init];
    mBleConnectionDelegates = [[NSMutableSet alloc]init];
    mCharFeatureMap = CFDictionaryCreateMutable(NULL, 0, 0, 0);
    
    mPeripheral=peripheral;
    mPeripheral.delegate=self;
    _state=W2STSDKNodeStateIdle;
    _name = peripheral.name;
    _tag = peripheral.identifier.UUIDString;
    W2STSDKBleAdvertiseParser *parser = [[W2STSDKBleAdvertiseParser alloc]
                        initWithAdvertise:advertisementData];
    [self buildAvailableFeatures: parser.featureMap maskFeatureMap:parser.featureMaskMap];
    _type = parser.nodeType;
    [self updateRssi:rssi];
    [self updateTxPower: parser.txPower];
    NSLog(@"create Node: name: %@ type: %x feature: %d",_name,_type,parser.featureMap);
    return self;
}

-(void) addBleConnectionParamiterDelegate:(id<W2STSDKNodeBleConnectionParamDelegate>)delegate{
    [mBleConnectionDelegates addObject:delegate];
}
-(void) removeBleConnectionParamiterDelegate:(id<W2STSDKNodeBleConnectionParamDelegate>)delegate{
    [mBleConnectionDelegates addObject:delegate];
}

-(void) addNodeStatusDelegate:(id<W2STSDKNodeStateDelegate>)delegate{
    [mNodeStatusDelegates addObject:delegate];
}
-(void) removeNodeStatusDelegate:(id<W2STSDKNodeStateDelegate>)delegate{
    [mNodeStatusDelegates addObject:delegate];
}

-(void) updateRssi:(NSNumber *)rssi{
    _RSSI=rssi;
    _rssiLastUpdate = [NSDate date];
    for (id<W2STSDKNodeBleConnectionParamDelegate> delegate in mBleConnectionDelegates) {
        dispatch_async(sNotificationQueue,^{
            [delegate node:self didChangeRssi:rssi.integerValue];
        });
    }//for
}

-(void) updateTxPower:(NSNumber *)txPower{
    _txPower=txPower;
    for (id<W2STSDKNodeBleConnectionParamDelegate> delegate in mBleConnectionDelegates) {
        dispatch_async(sNotificationQueue,^{
            [delegate node:self didChangeTxPower:txPower.integerValue];
        });
    }//for
}

- (BOOL) equals:(W2STSDKNode *)node{
    return [_tag isEqualToString:node.tag];
}

-(void)readRssi{
    [mPeripheral readRSSI];
}

-(void) updateNodeStatus:(W2STSDKNodeState)newState{
    W2STSDKNodeState oldState = _state;
    _state = newState;
    for (id<W2STSDKNodeStateDelegate> delegate in mNodeStatusDelegates) {
        dispatch_async(sNotificationQueue,^{
            [delegate node:self didChangeState:newState prevState:oldState];
        });
    }//for
}

-(NSArray*) getFeatures{
    return mAvailableFeature;

}

-(void)connect{
    [self updateNodeStatus:W2STSDKNodeStateConnecting];
    [[W2STSDKManager sharedInstance]connect:mPeripheral];
}

- (BOOL) isConnected{
    return self.state==W2STSDKNodeStateConnected;
}

-(void) disconnect{
    [self updateNodeStatus:W2STSDKNodeStateDisconnecting];
    [[W2STSDKManager sharedInstance]disconnect:mPeripheral];
    [self updateNodeStatus:W2STSDKNodeStateIdle];
}

-(void)completeConnection{
    if(mPeripheral.state !=	CBPeripheralStateConnected){
        [self updateNodeStatus:W2STSDKNodeStateUnreachable];
        return;
    }
    //else
    [mPeripheral discoverServices:nil];
}

-(void)connectionError:(NSError*)error{
    NSLog(@"Error Node:%@ %@ (%d)",self.name,error.description,error.code);
   [self updateNodeStatus:W2STSDKNodeStateDead];
}


// CBPeriperalDelegate
- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral
                          error:(NSError *)error{
    if(error!=nil){
        [self updateRssi:peripheral.RSSI];
    }else
        //TODO CHANGE THE NODE STATUS?
        NSLog(@"Error Updating Rssi: %@ (%d)",error.description,error.code);
}

- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverServices:(NSError *)error{
    for (CBService *service in peripheral.services) {
        NSLog(@"Discover sService: %@",service.UUID.UUIDString);
        [peripheral discoverCharacteristics:nil forService:service];
    }
}


//for each services find the known characteristics
- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverCharacteristicsForService:(CBService *)service
             error:(NSError *)error {
    
    if (error && [error code] != 0) {
        NSLog(@"Error %@\n", error);
        return ;
    }
    
    if( [[service UUID] isEqual:[W2STSDKServiceDebug serviceUuid]]  ){
        //build the debug service
        NSLog(@"Debug Service Discoverd");
    }else if( [[service UUID] isEqual:[W2STSDKServiceConfig serviceUuid]]  ){
        NSLog(@"Debug Config Discoverd");
    }else{
        for (CBCharacteristic *c in service.characteristics) {
            if ([W2STSDKFeatureCharacteristics isFeatureCharacteristics: c.UUID]){
                featureMask_t featureMask = [W2STSDKFeatureCharacteristics extractFeatureMask:c.UUID];
                NSMutableArray *charFeature = [[NSMutableArray alloc] initWithCapacity:1];
                for(NSNumber *mask in mMaskToFeature.allKeys ){
                    featureMask_t temp = mask.unsignedIntegerValue;
                    if((temp & featureMask)!=0){
                        W2STSDKFeature *f = [mMaskToFeature objectForKey:mask];
                        [f setEnabled:true];
                        [charFeature addObject:f];
                    }//if
                }//for
                if(charFeature.count != 0){
                    //TODO create an object for merge the characteristics and the feature?
                    CFDictionaryAddValue(mCharFeatureMap,(__bridge const void*) c ,
                                         (__bridge const void*)charFeature);
                }//if
            }//if featureChar
        }//for char
    }//if else
    [self updateNodeStatus:W2STSDKNodeStateConnected];
    
    //debug
    NSLog(@"Know Char:");
    for (CBCharacteristic *temp in [(__bridge NSDictionary*)mCharFeatureMap allKeys]) {
        NSLog(@"Add Char %@",temp.UUID.UUIDString);
    }
    /*
    // NSLog(@"- %@", service);
    for (CBCharacteristic *c in service.characteristics) {
        if ([charDataUUIDs containsObject:[c UUID]]) {
            [_notifiedCharacteristics addObject:c];
            //[_peripheral setNotifyValue:YES forCharacteristic:c]; //unselect to auto start reading
            //NSLog(@"Discovered characteristic %@", c);
        }
        else if ([[c UUID] isEqual:[CBUUID UUIDWithString:W2STSDKConfCharacteristicUUIDString]]) {
            _configCharacteristic = c;
        }
        else if ([[c UUID] isEqual:[CBUUID UUIDWithString:W2STSDKBatteryCharacteristicUUIDString]]) {
            _batteryCharacteristic = c;
        }
        else {
            //unknown char
            NSLog(@"Unknown char:%@", [c UUID]);
        }
    }
    
    if (_connectAndReading) {
        [self reading:YES];
        _connectAndReading = NO;
    }

    //if reading try to start the reading for new characteristics
    if (_notifiedReading) {
        [self readingSync];
    }
*/
}


@end
