//
//  W2STSDKNode.m
//  W2STSDK-CB
//
//  Created by Antonino Raucea on 18/03/14.
//  Copyright (c) 2014 STMicroelectronics. All rights reserved.
//

#import "W2STSDKNode.h"

@interface W2STSDKNode()


@end

@implementation W2STSDKNode {
    //NSMutableArray *_notifiedCharacteristics;
    //CBCharacteristic *_controlCharacteristic;
    BOOL _notifiedReading;
    BOOL _connectAndReading;
}
#define WORKAROUND_READLENGTHFIELD 1

NSString *W2STSDKMotionServiceUUIDString         = @"02366E80-CF3A-11E1-9AB4-0002A5D5C51B"; //Motion service
NSString *W2STSDKEnvironmentalServiceUUIDString  = @"42821A40-E477-11E2-82D0-0002A5D5C51B"; //Environment service
NSString *W2STSDKCommandServiceUUIDString        = @"03366E80-CF3A-11E1-9AB4-0002A5D5C51B"; //Config service

NSString *W2STSDKRawCharacteristicUUIDString  = @"230A1B80-CF4B-11E1-AC36-0002A5D5C51B"; //Raw motion char
NSString *W2STSDKAHRSCharacteristicUUIDString = @"240A1B80-CF4B-11E1-AC36-0002A5D5C51B"; //AHRS char
NSString *W2STSDKEnvCharacteristicUUIDString  = @"250A1B80-CF4B-11E1-AC36-0002A5D5C51B"; //Environment char

NSString *W2STSDKConfCharacteristicUUIDString  = @"360A1B80-CF4B-11E1-AC36-0002A5D5C51B"; //Config char

NSString *W2STSDKAllGroup  = @"AllData";
NSString *W2STSDKRawGroup  = @"RawData";
NSString *W2STSDKAHRSGroup = @"AHRSData";
NSString *W2STSDKEnvGroup  = @"EnvData";

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

NSTimer *bleDataTimer = nil;

-(void)startBleDataTimining {
    if (bleDataTimer != nil && [bleDataTimer isValid]) {
        [bleDataTimer invalidate];
        bleDataTimer = nil;
    }
    bleDataTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(bleDataUpdate) userInfo:nil repeats:YES];
}

-(void)stopBleDataTimining {
    if (bleDataTimer != nil && [bleDataTimer isValid]) {
        [bleDataTimer invalidate];
    }
    bleDataTimer = nil;
}

-(void)bleDataUpdate {
    //NSLog(@"Update BLE data node %@", self.name);
    if (self.isConnected) {
        [self.peripheral readRSSI];
    }
}

-(id) initStatus:(W2STSDKNodeStatus)status cstatus:(W2STSDKNodeConnectionStatus)cstatus {
    //self = [self init:nil manager:nil local:YES];
    self = [super init];
    self.status = status;
    self.connectionStatus = cstatus;
    return self;
}

-(id) init:(CBPeripheral *)peripheral manager:(W2STSDKManager *)manager local:(BOOL)local {
    static dispatch_once_t onceToken;
    
    _notifiedReading = NO;
    _connectAndReading = NO;
    
    self = [super init];
    
    dispatch_once(&onceToken, ^{
        boardNames = @{ [[NSNumber alloc] initWithInt:W2STSDKNodeBoardNameCodeUnknown    ] : @"Unknown",
                        [[NSNumber alloc] initWithInt:W2STSDKNodeBoardNameCodeNone       ] : @"None",
                        [[NSNumber alloc] initWithInt:W2STSDKNodeBoardNameCodeGeneric    ] : @"Generic",
                        [[NSNumber alloc] initWithInt:W2STSDKNodeBoardNameCodeWeSU       ] : @"WeSU",
                        [[NSNumber alloc] initWithInt:W2STSDKNodeBoardNameCodeL1Disco    ] : @"L1-discovery",
                        [[NSNumber alloc] initWithInt:W2STSDKNodeBoardNameCodeWeSU2      ] : @"WeSU2",
                        [[NSNumber alloc] initWithInt:W2STSDKNodeBoardNameCodeLocal      ] : @"Local",
                        };
        
        uuid2group = @{W2STSDKRawCharacteristicUUIDString  : W2STSDKRawGroup,
                       W2STSDKAHRSCharacteristicUUIDString : W2STSDKAHRSGroup,
                       W2STSDKEnvCharacteristicUUIDString  : W2STSDKEnvGroup,
                       };
        group2map = @{W2STSDKRawGroup : [NSNumber numberWithInt:W2STSDKNodeFrameGroupRaw],
                      W2STSDKAHRSGroup : [NSNumber numberWithInt:W2STSDKNodeFrameGroupAHRS],
                      W2STSDKEnvGroup : [NSNumber numberWithInt:W2STSDKNodeFrameGroupEnvironment],
                      };
    });
    
    if (manager == nil)
    {
        @throw [NSException
                exceptionWithName:@"InvalidArgumentException"
                reason:@"Manager can't be null"
                userInfo:nil];
    }
    
    _notifiedCharacteristics = [[NSMutableArray alloc] init];
    _configCharacteristic = nil;
    
    //data initialization
    _features = [[NSMutableDictionary alloc] init];
    _valueFeatures = [[NSMutableArray alloc] init];
    _params = [[NSMutableDictionary alloc] init];
    
    //node initialization
    _status = W2STSDKNodeStatusInit;
    _connectionStatus = W2STSDKNodeConnectionStatusUnknown;
    _local = local;

    _manager = manager;
    _peripheral = nil;
    
    //ble properties
    _name = @"noname";
    _peripheralName = @"na pname";
    _localName = @"na lname";
    
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

    if (_local == NO)
    {
        
        if (peripheral == nil)
        {
            @throw [NSException
                    exceptionWithName:@"InvalidArgumentException"
                    reason:@"Peripheral can't be null"
                    userInfo:nil];
        }

        _peripheral = peripheral;
        _peripheralName = _peripheral.name;
        _name = _peripheralName;
        _identifier = _peripheral.identifier;
        _boardNameCode = W2STSDKNodeBoardNameCodeNone;
        _info = @"";
        [self startBleDataTimining];
        
    }
    else {
        [self configureAsLocal];
    }

    return self;
}
-(id) init {
    return [self init:nil manager:nil local:YES];
}
-(id) initAsVirtual:(W2STSDKManager *)manager {
    return [self init:nil manager:manager local:YES];
}
- (int16_t)featureByte {
    return ((_hwFeatureByte<<8) | _swFeatureByte);
}
-(void)configureAsLocal {
    //bmesh initialitation
    //_hwFeatureByte = (int)W2STSDKNodeFeatureHWAcce | (int)W2STSDKNodeFeatureHWGyro | (int)W2STSDKNodeFeatureHWMagn | (int)W2STSDKNodeFeatureHWTemp;
    //_swFeatureByte = (int)W2STSDKNodeFeatureSWAHRS;
    _hwFeatureByte = 0xC0; //0xFF;
    _swFeatureByte = 0x80; //0xFF;
    
    _name = @"your device"; //get the name of device
    _localName = @"lname"; //get the name of device
    _peripheralName = @"pname"; //get the name of device
    _identifier = nil;
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
-(NSString *)UUIDGetString {
    
    return _identifier == nil ? @"00000000-0000-0000-0000-000000000000" : [_identifier UUIDString];
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
        
        if ([[advertisementData allKeys] containsObject:CBAdvertisementDataLocalNameKey])
        {
            _localName = advertisementData[CBAdvertisementDataLocalNameKey];
            _name = _localName;
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
    W2STSDKNodeStatus nextStatus = _status;
    if (_status != W2STSDKNodeStatusDead) {
        //if no check
        nextStatus = W2STSDKNodeStatusNormalNoCheck;
        if (_leaveTime != nil) {
            //check enable
            //if connect then the node is always in normal state
            //else check if in dead state
            nextStatus = W2STSDKNodeStatusNormal;
            if (_status == W2STSDKNodeStatusNormal) {
                if (![self isConnected]) {
                    NSDate *now = [NSDate date];
                    NSDate *lst = _leaveTime;
                    NSTimeInterval t_sec = [now timeIntervalSinceDate:lst];
                    if (t_sec > DEAD_TIME) {
                        NSLog(@"Dead node: %@ %0.2f %@", _name, t_sec, lst);
                        nextStatus = W2STSDKNodeStatusDead;
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
            nextStatus = W2STSDKNodeStatusResumed;
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
        _connectionStatus = W2STSDKNodeConnectionStatusConnected;
        [_delegate node:self connectionDidChange:_connectionStatus];
        return YES;
    }
    
    BOOL ret = NO;
	if (_manager != nil && _manager.central != nil && _manager.central.centralManager != nil && _peripheral != nil) {
        
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

    return ret;
}
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
    if (_connectionStatus == W2STSDKNodeConnectionStatusDisconnecting) {
        [self reading:NO];
    }
    
    if (_peripheral != nil) {
        _connectionStatus = _peripheral.state == CBPeripheralStateConnected ? W2STSDKNodeConnectionStatusConnected : W2STSDKNodeConnectionStatusDisconnected;
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
        [_peripheral discoverServices:serviceUUIDs];
        
        if (_connectAndReading) {
            [self reading:YES];
            _connectAndReading = NO;
        }
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
NSTimer *timerLocalReading = nil;
-(void) reading:(BOOL)enable {
    if (_local) {
        _notifiedReading = enable;
        //enable a timer to read data from sensors available inside the device
        if (timerLocalReading != nil) {
            [timerLocalReading invalidate];
        }
        if (enable) {
            if (timerLocalReading != nil) {
                [timerLocalReading invalidate];
            }
            timerLocalReading = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(readingLocal) userInfo:nil repeats:YES];
        }
        return;
    }
    if (_notifiedCharacteristics != nil && _notifiedCharacteristics.count > 0) {
        _notifiedReading = enable;
        [self readingSync];
        [_delegate node:self readingDidChange:_notifiedReading];
    }
}

int v_count = 0;
typedef struct {
    short v_acce_val[3];
    short v_gyro_val[3];
    short v_magn_val[3];
    int v_pres_val;
    short v_temp_val;
    float v_ahrs_val[4];
} frame_t;
frame_t frame;

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
-(void)readingLocal {
    assert(_local);
    int k = v_count >= 9 ? 9 : v_count;
//    size_t size = sizeof(val);
    //memcpy(buffer, val, size);
    
    //update randomly the vars
    if (v_count == 0) {
        memset((void *)&frame, 0, sizeof(frame_t));
    }
    
    frame.v_acce_val[0] = (frame.v_acce_val[0] * k + my_irand(-2000, 2000)) / (k + 1);
    frame.v_acce_val[1] = (frame.v_acce_val[1] * k + my_irand(-2000, 2000)) / (k + 1);
    frame.v_acce_val[2] = (frame.v_acce_val[2] * k + my_irand(-2000, 2000)) / (k + 1);
    
    frame.v_gyro_val[0] = (frame.v_acce_val[0] * k + my_irand(-800, 800)) / (k + 1);
    frame.v_gyro_val[1] = (frame.v_acce_val[1] * k + my_irand(-800, 800)) / (k + 1);
    frame.v_gyro_val[2] = (frame.v_acce_val[2] * k + my_irand(-800, 800)) / (k + 1);
    
    frame.v_magn_val[0] = (frame.v_acce_val[0] * k + my_irand(-800, 800)) / (k + 1);
    frame.v_magn_val[1] = (frame.v_acce_val[1] * k + my_irand(-800, 800)) / (k + 1);
    frame.v_magn_val[2] = (frame.v_acce_val[2] * k + my_irand(-800, 800)) / (k + 1);
    
    frame.v_pres_val = (frame.v_pres_val * k + my_irand(980, 1080)) / (k + 1);
    frame.v_temp_val = (frame.v_temp_val * k + my_irand(0, 100)) / (k + 1);
    
    frame.v_ahrs_val[0] = (frame.v_ahrs_val[0] * k + (my_frand(0.0f, 1.0f))) / (k + 1);
    frame.v_ahrs_val[1] = (frame.v_ahrs_val[1] * k + (my_frand(0.0f, 1.0f))) / (k + 1);
    frame.v_ahrs_val[2] = (frame.v_ahrs_val[2] * k + (my_frand(0.0f, 1.0f))) / (k + 1);
    frame.v_ahrs_val[3] = (frame.v_ahrs_val[3] * k + (my_frand(0.0f, 1.0f))) / (k + 1);
    
    NSData *data;
    data = [[NSData alloc] initWithBytes:(void *)&frame.v_acce_val length:sizeof(frame.v_acce_val)];
    [self.features[W2STSDKNodeFeatureHWAccelerometerKey] updateData:data position:0 time:0];
 
    data = [[NSData alloc] initWithBytes:(void *)&frame.v_gyro_val length:sizeof(frame.v_gyro_val)];
    [self.features[W2STSDKNodeFeatureHWGyroscopeKey] updateData:data position:0 time:0];
    
    data = [[NSData alloc] initWithBytes:(void *)&frame.v_magn_val length:sizeof(frame.v_magn_val)];
    [self.features[W2STSDKNodeFeatureHWMagnetometerKey] updateData:data position:0 time:0];
    
    data = [[NSData alloc] initWithBytes:(void *)&frame.v_pres_val length:sizeof(frame.v_pres_val)];
    [self.features[W2STSDKNodeFeatureHWPressureKey] updateData:data position:0 time:0];

    data = [[NSData alloc] initWithBytes:(void *)&frame.v_temp_val length:sizeof(frame.v_temp_val)];
    [self.features[W2STSDKNodeFeatureHWTemperatureKey] updateData:data position:0 time:0];

    data = [[NSData alloc] initWithBytes:(void *)&frame.v_ahrs_val length:sizeof(frame.v_ahrs_val)];
    [self.features[W2STSDKNodeFeatureSWAHRSKey] updateData:data position:0 time:0];

    v_count++;

    [_delegate node:self dataDidUpdate:W2STSDKNodeChangeDataVal param:W2STSDKAllGroup];
}
-(void) readingSync {
    if (_local) {
        return;
    }
    for (CBCharacteristic *c in _notifiedCharacteristics)
    {
        [_peripheral setNotifyValue:_notifiedReading forCharacteristic:c];
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
-  (void)peripheral:(CBPeripheral *)peripheral
didDiscoverServices:(NSError *)error {
    NSArray *charUUIDs = @[[CBUUID UUIDWithString:W2STSDKEnvCharacteristicUUIDString],
                           [CBUUID UUIDWithString:W2STSDKAHRSCharacteristicUUIDString],
                           [CBUUID UUIDWithString:W2STSDKRawCharacteristicUUIDString],
                           [CBUUID UUIDWithString:W2STSDKConfCharacteristicUUIDString],
                           ];
    
    for (CBService *service in peripheral.services) {
        //if ([[service UUID] isEqual:[CBUUID UUIDWithString:W2STSDKMotionServiceUUIDString]]) {
            [peripheral discoverCharacteristics:charUUIDs forService:service];
        //}
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
    
    
   // NSLog(@"- %@", service);
    for (CBCharacteristic *c in service.characteristics) {
        if ([[c UUID] isEqual:[CBUUID UUIDWithString:W2STSDKEnvCharacteristicUUIDString]] ||
            [[c UUID] isEqual:[CBUUID UUIDWithString:W2STSDKAHRSCharacteristicUUIDString]] ||
            [[c UUID] isEqual:[CBUUID UUIDWithString:W2STSDKRawCharacteristicUUIDString]]) {
            [_notifiedCharacteristics addObject:c];
            //[_peripheral setNotifyValue:YES forCharacteristic:c]; //unselect to auto start reading
            //NSLog(@"Discovered characteristic %@", c);
        }
        
        if ([[c UUID] isEqual:[CBUUID UUIDWithString:W2STSDKConfCharacteristicUUIDString]]) {
            _configCharacteristic = c;
        }
    }
    
    //if reading try to start the reading for new characteristics
    if (_notifiedReading) {
        [self readingSync];
    }
    
}

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
    
    if ([group isEqualToString:W2STSDKRawGroup]) {
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
    
    if ([group isEqualToString:W2STSDKRawGroup]) {
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
    if (peripheral != _peripheral) {
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
    
    if ([uuid isEqualToString:W2STSDKConfCharacteristicUUIDString]) {
        [self updateConfigForData:data];
    }
    else {
        group = [W2STSDKNode uuid2groupSafe:uuid];
        if(![group isEqualToString:@""] ) {
            [self updateValueForData:data group:group];
            W2STSDKNodeFrameGroup framegroup = [W2STSDKNode group2mapSafe:group];
            [_manager.dataLog addRawDataWithGroup:framegroup data:data node:self save:NO];
        }
        
    }
}
- (void)updateConfigForData:(NSData *)data {
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
                self.battery = *(short *)cmd.ctrlFrame.payload;
                NSLog(@"Batt is '0x%0.4X'", (int)self.battery);
                break;
            default:
                break;
        }
        
        [_delegate node:self dataDidUpdate:W2STSDKNodeChangeConfigVal param:@""];
    }
}
long frame_node_count = 0;
- (void)updateValueForData:(NSData *)data group:(NSString *)group {
    unsigned short timele = 0; //2 bytes for timestamp
    int pos = 0;

    const unsigned char *dataBuffer = (const unsigned char *)[data bytes];

    //internal frame data counting
    frame_node_count++;
    
    //get  timestamp information
    memcpy(&timele, &dataBuffer[0], 2);
    pos += 2;
    
    //get the group of the characteristic received
    
    
    //decode the environment frame
    
    NSArray *keys;
    keys = [W2STSDKNode getFeaturesFromGroup:group];
    for(NSString *key in keys) {
        if ([self featureAvailable:key]) {
            pos += [_features[key] updateData:data position:pos time:timele];
        }
    }
    
    [_delegate node:self dataDidUpdate:W2STSDKNodeChangeDataVal param:group];
}
- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral
                          error:(NSError *)error {
    if (error == nil) {
        [self updateRSSI:peripheral.RSSI enableDelegate:YES];
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
            ret = [[NSString alloc] initWithFormat:@"%lu", (unsigned long)self.battery];
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
    [self.peripheral readValueForCharacteristic:_configCharacteristic];
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
        [self.peripheral writeValue:dataToSend forCharacteristic:_configCharacteristic type:CBCharacteristicWriteWithResponse];
        
        if (command.ctrlFrame.ctrl.map.operation == 0) {
            //this is a get command
            [self.peripheral readValueForCharacteristic:_configCharacteristic];
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
@end
