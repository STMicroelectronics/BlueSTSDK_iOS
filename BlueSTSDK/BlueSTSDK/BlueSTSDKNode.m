/*******************************************************************************
 * COPYRIGHT(c) 2015 STMicroelectronics
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *   1. Redistributions of source code must retain the above copyright notice,
 *      this list of conditions and the following disclaimer.
 *   2. Redistributions in binary form must reproduce the above copyright notice,
 *      this list of conditions and the following disclaimer in the documentation
 *      and/or other materials provided with the distribution.
 *   3. Neither the name of STMicroelectronics nor the names of its contributors
 *      may be used to endorse or promote products derived from this software
 *      without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 ******************************************************************************/

#import "BlueSTSDK/BlueSTSDK-Swift.h"

#import "BlueSTSDKNode_prv.h"
#import "BlueSTSDKFeature_prv.h"
#import "BlueSTSDKFeatureGenPurpose.h"
#import "BlueSTSDKDebug_prv.h"
#import "BlueSTSDKConfigControl_prv.h"
#import "BlueSTSDK_LocalizeUtil.h"

#import "Util/BlueSTSDKCharacteristic.h"
#import "Util/NSData+NumberConversion.h"
#import "Util/UnwrapTimeStamp.h"

#define RETRAY_ENABLE_NOTIFICATION_DELAY 1.0f
#define TAG_NAME_CHAR_NUM 6

@interface BlueSTSDKNode() <CBPeripheralDelegate>
@end

/**
 * concurrent queue used for notify the node update in different thread
 */
static dispatch_queue_t sNotificationQueue;

@implementation BlueSTSDKNode {

    /**
     *  characteristics where write the command for the feature, null if the 
     * functionality is not present
     */
    CBCharacteristic *mFeatureCommand;
    BOOL mFeatureCommandNotifyEnable;
    NSMutableArray <NSData*>* mCommandQueue;
    
    /**
     *  remote ble peripheral
     */
    CBPeripheral *mPeripheral;
    
    /**
     *  set of delegate where notify changes in the ble connection parameters
     */
    NSMutableSet *mBleConnectionDelegates;
    
    /**
     *  set of delegate where notify changes in node status
     */
    NSMutableSet *mNodeStatusDelegates;
    
    /**
     *  map the feature  bitmask with the build feature
     */
    NSMutableDictionary<NSNumber*, BlueSTSDKFeature* > *mMaskToFeature;
    
    /**
     *  array of BlueSTSDKCharacteristics it contains the mapping between
     * CBCharacteristics and {@link BlueSTSDKFeature}
     */
    NSMutableArray<BlueSTSDKCharacteristic* > *mCharFeatureMap;
    
    /**
     *  array of {@link BlueSTSDKFeature} that the node export
     */
    NSMutableArray< BlueSTSDKFeature*> *mAvailableFeature;
    
    /**
     *  set of {@link BlueSTSDKFeature} that are currently in notify mode
     */
    NSMutableSet< BlueSTSDKFeature*> *mNotifyFeature;

    NSMutableDictionary<CBUUID*,NSArray<Class>* >* mExternalCharFeature;

    /**
     *  true if the user ask to disconnect, it is used for understand if we lost
     * the connection with the node
     */
    BOOL mUserAskDisconnect;
    
    // array that will contain the service for that we request the characteristics,
    //when this array becomes empty the node is connected
    NSMutableArray *mCharDiscoverServiceReq;
    
    UnwrapTimeStamp *mUnwrapUtil;
    
    /**
     * we can send a request for notification before the connection is completed
     * (es. we wait that the user insert a pin) -> we use this set for keep the
     * notification request and we remote it when we receive some data, otherwise we
     * re ask for enable the notification.
     * you have to synchronize the access of this structure
     */
    NSMutableSet *mAskForNotification;
    
    /**
     *caching the friendly name to avoid several calculation
     */
    NSString *mFriendlyNameCache;
}

/**
 *  instanziate a feature from a class type
 *
 *  @param featureClass class to instanziate, it must be a class that extend the 
 *  BlueSTSDKFeature
 *
 *  @return object of type "featureClass"
 */
-(BlueSTSDKFeature*) buildFeatureFromClass:(Class)featureClass{
    return [((BlueSTSDKFeature*)[featureClass alloc]) initWhitNode:self];

}

-(instancetype)init{
    self = [super init];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sNotificationQueue = dispatch_queue_create("BlueSTNode", DISPATCH_QUEUE_CONCURRENT);
    });

    mNodeStatusDelegates = [NSMutableSet set];
    mBleConnectionDelegates = [NSMutableSet set];
    mCharFeatureMap = [NSMutableArray array];
    mNotifyFeature = [NSMutableSet set];
    mAskForNotification = [NSMutableSet set];
    mExternalCharFeature = [NSMutableDictionary dictionary];
    mAvailableFeature = [NSMutableArray array];
    mMaskToFeature = [NSMutableDictionary dictionary];
    mFeatureCommand=nil;
    mFeatureCommandNotifyEnable=false;
    _debugConsole=nil;
    _configControl=nil;
    _state=BlueSTSDKNodeStateIdle;
    return self;
}

-(void)updateAdvertiseInfo:(id<BleAdvertiseInfo> _Nonnull)newInfo{
    _advertiseInfo = newInfo;
    _type = _advertiseInfo.boardType;
    _typeId = _advertiseInfo.deviceId;
    _name = _advertiseInfo.name;
    _address = _advertiseInfo.address;
    _protocolVersion = _advertiseInfo.protocolVersion;
    _hasExtension = _advertiseInfo.hasGeneralPurpose;
    _isSleeping = _advertiseInfo.isSleeping;
    _advertiseBitMask = _advertiseInfo.featureMap;
}

-(instancetype)init:(CBPeripheral *)peripheral rssi:(NSNumber*)rssi advertiseInfo:(id<BleAdvertiseInfo> _Nonnull)advertiseInfo{
    self = [self init];
    mPeripheral=peripheral;
    mPeripheral.delegate=self;

    _tag = peripheral.identifier.UUIDString;
    [self updateAdvertiseInfo:advertiseInfo];
    
    [self updateTxPower: [NSNumber numberWithUnsignedChar:_advertiseInfo.txPower]];
    
    [self updateRssi:rssi];
    //NSLog(@"create Node: name: %@ type: %x feature: %d",_name,_type,parser.featureMap);
    return self;
}

-(NSString *) friendlyName {
    return [self friendlyName:NO];
}


/**
 * get the tag or the address and strip ':' or '-'
 * after compound it with the name of the node
 */
-(NSString *) friendlyName:(BOOL)forceUpdate {
    if (!mFriendlyNameCache || forceUpdate) {
        //if address removing the :
        NSString *tag = self.addressEx;
        NSString *name = self.name;
        NSString *tail = @"";
        
        tag = [tag stringByReplacingOccurrencesOfString:@":" withString:@""];
        tag = [tag stringByReplacingOccurrencesOfString:@"-" withString:@""];
        
        NSInteger len = [tag length];
        
        tail = len <= TAG_NAME_CHAR_NUM ? tag : [tag substringFromIndex:len - TAG_NAME_CHAR_NUM];
        mFriendlyNameCache = [NSString stringWithFormat:@"%@ @%@", name, tail];
    }
    assert(mFriendlyNameCache);
    return mFriendlyNameCache;
}

/**
 * if the address (BLE) is valid (provided by board on the discovery time)
 * return it otherwise use the as tag the identify provided by iOS
 */
-(NSString *)addressEx {
    return self.address && ![self.address isEqualToString:@""] ? self.address : self.tag;
}
-(void) addBleConnectionParamiterDelegate:(id<BlueSTSDKNodeBleConnectionParamDelegate>)delegate{
    [mBleConnectionDelegates addObject:delegate];
}//addBleConnectionParamiterDelegate

-(void) removeBleConnectionParamiterDelegate:(id<BlueSTSDKNodeBleConnectionParamDelegate>)delegate{
    [mBleConnectionDelegates removeObject:delegate];
}//removeBleConnectionParamiterDelegate

-(void) addNodeStatusDelegate:(id<BlueSTSDKNodeStateDelegate>)delegate{
    [mNodeStatusDelegates addObject:delegate];
}//addNodeStatusDelegate

-(void) removeNodeStatusDelegate:(id<BlueSTSDKNodeStateDelegate>)delegate{
    [mNodeStatusDelegates removeObject:delegate];
}//removeNodeStatusDelegate

-(void) updateRssi:(NSNumber *)rssi{
    _RSSI=rssi;
    _rssiLastUpdate = [NSDate date];
    for (id<BlueSTSDKNodeBleConnectionParamDelegate> delegate in mBleConnectionDelegates) {
        dispatch_async(sNotificationQueue,^{
            [delegate node:self didChangeRssi:rssi.integerValue];
        });
    }//for
}//updateRssi

-(void) updateTxPower:(NSNumber *)txPower{
    _txPower=txPower;
    for (id<BlueSTSDKNodeBleConnectionParamDelegate> delegate in mBleConnectionDelegates) {
        dispatch_async(sNotificationQueue,^{
            [delegate node:self didChangeTxPower:txPower.integerValue];
        });
    }//for
}//updateTxPower

- (BOOL) equals:(BlueSTSDKNode *)node{
    return [_tag isEqualToString:node.tag];
}//equals

-(void)readRssi{
    [mPeripheral readRSSI];
}//readRssi

-(void) updateNodeStatus:(BlueSTSDKNodeState)newState{
    BlueSTSDKNodeState oldState = _state;
    _state = newState;
    for (id<BlueSTSDKNodeStateDelegate> delegate in mNodeStatusDelegates) {
        dispatch_async(sNotificationQueue,^{
            [delegate node:self didChangeState:newState prevState:oldState];
        });
    }//for
}//updateNodeStatus

-(NSArray*) getFeatures{
    return mAvailableFeature;
}//getFeatures

-(NSArray*) getFeaturesOfType:(Class)type{
    NSMutableArray *foundFeature = [NSMutableArray array];
    
    for(BlueSTSDKFeature *f in mAvailableFeature){
        if([f isKindOfClass:type]){
            [foundFeature addObject:f];
        }//if
    }//for
    
    return foundFeature;
}//getFeaturesOfType

-(BlueSTSDKFeature*) getFeatureOfType:(Class)type{

    NSArray *features = [self getFeaturesOfType:type];
    if(features.count == 0)
        return nil;
    //else
    return features[0];
}

-(void)connect{
    mUserAskDisconnect=false;
    //reset the unwrap object
    mUnwrapUtil = [[UnwrapTimeStamp alloc]init];
    [self updateNodeStatus:BlueSTSDKNodeStateConnecting];
    
    [[BlueSTSDKManager sharedInstance]connect:mPeripheral];
}//connect

-(void)completeConnection{
    if(mPeripheral.state !=	CBPeripheralStateConnected){
        [self updateNodeStatus:BlueSTSDKNodeStateUnreachable];
        return;
    }//if
    //else
    [mPeripheral discoverServices:nil];
}//completeConnection


- (BOOL) isConnected{
    return self.state==BlueSTSDKNodeStateConnected;
}//isConnected


-(void)completeDisconnection:(NSError*)error{
    if(mUserAskDisconnect){
        if(error==nil){
            //all ok
            [self updateNodeStatus:BlueSTSDKNodeStateIdle];
        }else{
            NSLog(@"Disconnect: Node: %@ Error: %@ (%d)",_name,
                  [error localizedDescription],(int)error.code);
            [self updateNodeStatus:BlueSTSDKNodeStateDead];
        }//if else error==nil
    }else{
        NSLog(@"Disconnect Node: %@ Error: %@ (%d)",_name,
              [error localizedDescription],(int)error.code);
        [self updateNodeStatus:BlueSTSDKNodeStateUnreachable];
    }//if else
}//completeDisconnection

-(void) disconnect{
    [self updateNodeStatus:BlueSTSDKNodeStateDisconnecting];
    mUserAskDisconnect=true;
    
    if(mFeatureCommand!=nil)
        [mPeripheral setNotifyValue:NO forCharacteristic:mFeatureCommand];
    
    //we remove the feature/char map since it must be rebuild every time we connect
    [mCharFeatureMap removeAllObjects];
    
    //we close the connection so we remove all the notify characteristics
    [mNotifyFeature removeAllObjects];
    
    [mAvailableFeature removeAllObjects];
    
    [[BlueSTSDKManager sharedInstance]disconnect:mPeripheral];
}//disconnect

- (void)addExternalCharacteristics:(NSDictionary<CBUUID *, NSArray<Class>* > *)userDefinedFeature {
    if(userDefinedFeature==nil)
        return;

    [mExternalCharFeature addEntriesFromDictionary:userDefinedFeature];
}


-(void)connectionError:(NSError*)error{
    NSLog(@"Connection Node:%@ Error:%@ (%d)",_name,
          error.localizedDescription,(int)error.code);
   [self updateNodeStatus:BlueSTSDKNodeStateDead];
}//connectionError

/**
 *  find the CBCharacteristics that we can use for read/write a feature
 *
 *  @param feature feature that we want read/write
 *
 *  @return CBCharacteristics equivalent to the feature in the node
 */
-(CBCharacteristic*) extractCharacteristicsFromFeature:(BlueSTSDKFeature*)feature{
    //if is a generic feature we use the characteristics inside the class
    if([feature isKindOfClass:BlueSTSDKFeatureGenPurpose.class])
        return ((BlueSTSDKFeatureGenPurpose*)feature).characteristics;
    else //otherwise we extract it from the map since a feature can be inside more than one CBCharacteristics
        return [BlueSTSDKCharacteristic getCharFromFeature:feature in:mCharFeatureMap];
}


/**
 * tell if you can read a characteristic
 * @param c characteristic to read
 * @return true if it can be read
 */
+(BOOL) charCanBeRead:(CBCharacteristic *)c{
    return (c.properties & CBCharacteristicPropertyRead)!=0;
}

/**
 * tell if you can enable the notification for a characteristic
 * @param c characteristic to test
 * @return true if it can be notify
 */
+(BOOL) charCanBeNotify:(CBCharacteristic *)c{
    return (c.properties & (CBCharacteristicPropertyNotify |
                            CBCharacteristicPropertyNotifyEncryptionRequired |
                            CBCharacteristicPropertyIndicate))!=0;
}

/**
 * tell if you can write a characteristic
 * @param c characteristic to test
 * @return true if it can be write
 */
+(BOOL) charCanBeWrite:(CBCharacteristic *)c{
    return (c.properties & (CBCharacteristicPropertyWrite |
                            CBCharacteristicPropertyWriteWithoutResponse))!=0;
}



-(BOOL)readFeature:(BlueSTSDKFeature *)feature{
    CBCharacteristic *c =[self extractCharacteristicsFromFeature: feature];
    if(c==nil)
        return false;
    if(![BlueSTSDKNode charCanBeRead:c])
        return false;
    [mPeripheral readValueForCharacteristic:c];
    return true;
}//readFeature


-(BOOL) isEnableNotification:(BlueSTSDKFeature*)feature{
    return [mNotifyFeature containsObject:feature];
}//isEnableNotification

-(BOOL) enableNotification:(BlueSTSDKFeature*)feature{
   // NSLog(@"Enable: %@",feature.name);
    if(![feature enabled])
        return false;
    
    if(![self isConnected])
        return false;
    
    if([self isEnableNotification:feature])
        return true;
    
    CBCharacteristic *c= [self extractCharacteristicsFromFeature:feature];
    
    if(c==nil)
        return false;
    if(![BlueSTSDKNode charCanBeNotify:c])
        return false;
    
    @synchronized(mAskForNotification){
         [mAskForNotification addObject:c.UUID];
    }//synchronized
    
    [mPeripheral setNotifyValue:YES forCharacteristic:c];
    
    [mNotifyFeature addObject:feature];
    return true;
}//enableNotification

-(BOOL) disableNotification:(BlueSTSDKFeature*)feature{
   // NSLog(@"Disable: %@",feature.name);
    if(![feature enabled])
        return false;
    
    if(![self isEnableNotification:feature])
        return true;
    
    CBCharacteristic *c=[self extractCharacteristicsFromFeature:feature];
    if(c==nil)
        return false;

    //we remove anyway the uuid, in case we disable the notification before
    //before receive some data
    //we do it before set it to no, for avoid that the callback see the object
    //still inside the set
    @synchronized(mAskForNotification){
        [mAskForNotification removeObject:c.UUID];
    }//synchronized
    
    [mPeripheral setNotifyValue:NO forCharacteristic:c];
    [mNotifyFeature removeObject:feature];

    return true;
}//disableNotification

/**
 *  pack the data for be send to as command to a feature
 *
 *  @param mask feature mask corresponding to the feature that will receive the command
 *  @param type command type
 *  @param data other data for the command
 *
 *  @return array of byte to send as command
 */
+(NSData*)prepareMessageWithMask:(featureMask_t)mask type:(uint8_t)type data:(NSData*)data{
    NSMutableData *msg = [NSMutableData dataWithCapacity:(sizeof(featureMask_t)+1+data.length)];

    //store the feature mask as big endian
    uint8_t *maskByte = (uint8_t*)&mask;
    [msg appendBytes:maskByte+3 length:1];
    [msg appendBytes:maskByte+2 length:1];
    [msg appendBytes:maskByte+1 length:1];
    [msg appendBytes:maskByte+0 length:1];

    [msg appendBytes:&type length:1];
    [msg appendData:data];
    return msg;
}//prepareMessageWithMask

/**
 * get the available write type for the characteristics, if both are present the default one is withoutResponse
 */
+(CBCharacteristicWriteType) getWriteTypeForChar:(CBCharacteristic*)characteristic{
    bool hasWrithoutResponse = (characteristic.properties & CBCharacteristicPropertyWriteWithoutResponse) == CBCharacteristicPropertyWriteWithoutResponse;
    if(hasWrithoutResponse)
        return CBCharacteristicWriteWithoutResponse;
    else
        return CBCharacteristicWriteWithResponse;
    
}

-(BOOL)sendCommandMessageToFeature:(BlueSTSDKFeature*)feature type:(uint8_t)commandType
                     data:(NSData*) commandData{
   
    //the general purpose feature can not receive command
    if([feature isKindOfClass:BlueSTSDKFeatureGenPurpose.class]){
        return false;
    }//if
    
    //find the characteristic link with the feature
    CBCharacteristic *featureChar = [BlueSTSDKCharacteristic
                                     getCharFromFeature:feature in:mCharFeatureMap];
    if(featureChar==nil)
        return false;

    CBCharacteristic *writeTo = mFeatureCommand == nil ? featureChar : mFeatureCommand;
    if(writeTo==nil || ![BlueSTSDKNode charCanBeWrite:writeTo]){
        return false;
    }//if
    
    if(writeTo==mFeatureCommand && mFeatureCommandNotifyEnable==false){
        [mPeripheral setNotifyValue:YES forCharacteristic:mFeatureCommand];
    }
    
    CBCharacteristicWriteType writeType = [BlueSTSDKNode getWriteTypeForChar:writeTo];
    //extract the feature bit mask
    featureMask_t featureMask = featureChar.UUID.featureMask;
    
    //compose the message
    NSData *msg = [BlueSTSDKNode prepareMessageWithMask:featureMask type:commandType data:commandData];
    if(writeTo==mFeatureCommand)
        [mPeripheral writeValue:msg forCharacteristic:writeTo type:writeType];
    else{ //write directly on the feature, we don't send the feature mask
        [mPeripheral writeValue:[msg subdataWithRange:NSMakeRange(sizeof(featureMask_t),
                                                                  msg.length-sizeof(featureMask_t))]
              forCharacteristic:writeTo
                           type:writeType];
    }
    return true;
}//sendCommandMessageToFeature

-(BOOL)writeDataToFeature:(BlueSTSDKFeature *)feature data:(NSData *)data{
    CBCharacteristic *featureChar=[self extractCharacteristicsFromFeature:feature];

    if(featureChar==nil)
        return false;
    if(![BlueSTSDKNode charCanBeWrite:featureChar]){
        return false;
    }
    
    CBCharacteristicWriteType writeType = [BlueSTSDKNode getWriteTypeForChar:featureChar];
    //CBCharacteristicWriteType writeType = CBCharacteristicWriteWithoutResponse;
    [mPeripheral writeValue:data forCharacteristic:featureChar type:writeType];
    return true;
}//writeDataToFeature

#pragma mark - CBPeripheralDelegate
/**
 * if we receive an rssi update, we notify it to the delegate
 */
- (void)peripheral:(CBPeripheral *)peripheral
                  didReadRSSI:(nonnull NSNumber *)RSSI
             error:(nullable NSError *)error{
    if(error==nil){
        [self updateRssi:RSSI];
    }else
        NSLog(@"Error Updating Rssi: %@ (%ld)",error.description,(long)error.code);
}//peripheralDidUpdateRSSI

/**
 * we discover the services during the first connection, for each service we
 * request also to discover the characteristics
 */
- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverServices:(NSError *)error{
    //[NSThread sleepForTimeInterval:1];
    if([self isConnected]) //we already run this method one time
        return;
    
    if(error!=nil)
       [self updateNodeStatus:BlueSTSDKNodeStateUnreachable];
    /*
    we store all the service in an array, when we receive the characteristics
    of a service we remove the service from the array in a way to avoid to scan 
     multiple time the same service */
    mCharDiscoverServiceReq = [NSMutableArray arrayWithArray: peripheral.services];
    for (CBService *service in peripheral.services) {
        NSLog(@"Discovered Service: %@",service.UUID.UUIDString);
        [peripheral discoverCharacteristics:nil forService:service];
    }//for
}//didDiscoverServices

/**
 *  create a debug object
 *
 *  @param service ble service that contains the ble characteristics for the debug
 *
 *  @return object to use for access to the stderr/out/in stream
 */
-(BlueSTSDKDebug*) buildDebugService:(CBService*)service{
    
    CBCharacteristic *term=nil,*err=nil;
    for(CBCharacteristic *c in service.characteristics){
        if(c.isDebugTermCharacteristic){
            term = c;
        }else if(c.isDebugErrorCharacteristic){
            err = c;
        }//if-else-if
    }//for
    //if both the characteristics are present build the debug object
    if(term == nil || err == nil)
        return nil;
    else
        return [[BlueSTSDKDebug alloc] initWithNode:self periph:mPeripheral
                                        termChart:term errChart:err];
}//buildDebugService

/**
 *  create a debug object
 *
 *  @param service ble service that contains the ble characteristics for the debug
 *
 *  @return object to use for access to the stderr/out/in stream
 */
-(BlueSTSDKConfigControl *) buildConfigService:(CBService*)service {
    
    CBCharacteristic *configcontrolchar=nil;
    for(CBCharacteristic *c in service.characteristics) {
        if(c.isConfigControlCharacteristic){
            configcontrolchar = c;
        } else if (c.isConfigFeatureCommandCharacteristic) {
            mFeatureCommand = c; //to compatibility with previous code
        }
    }//for
    if(configcontrolchar!=nil){
      return [BlueSTSDKConfigControl configControlWithNode:self periph:mPeripheral
                                      configControlChart:configcontrolchar];
    }else
        return nil;
}//buildConfigService

/**
 *  From a characteristic extract the exported features. That feature will be enabled
 *
 *  @param c characteristic that will export one or more features
 */
-(void)buildKnowFeatureFromChar:(CBCharacteristic*)c{
    NSDictionary<NSNumber*,Class> *maskFeatureMap = [[BlueSTSDKManager sharedInstance] getFeaturesForNode: self.typeId];
    featureMask_t featureMask = c.UUID.featureMask;
    NSMutableArray *charFeature = [[NSMutableArray alloc] initWithCapacity:1];
    
    uint32_t mask = 1<<31;
    for(uint32_t i=0; i<32; i++){
        if((featureMask & mask)!=0){
            NSNumber *key = @(mask);
            Class featureClass = maskFeatureMap[key];
            if(featureClass!=nil && [self isExportingFeature:featureClass]){
                BlueSTSDKFeature *f = [self buildFeatureFromClass:featureClass];
                if(f!=nil){

                    [charFeature addObject:f];
                    mMaskToFeature[key] = f;
                    if([self isExportingFeature:featureClass]){
                        [mAvailableFeature addObject:f];
                        [f setEnabled:true];
                    }
                }//if
            }//if feature class
        }//if
        mask = mask >>1;
    }//for
    
    if(charFeature.count != 0){ //if we found some feature save it
        BlueSTSDKCharacteristic* temp = [[BlueSTSDKCharacteristic alloc]
                                       initWithChar:c features:charFeature];
        [mCharFeatureMap addObject: temp];
    }//if
}//buildKnowFeatureFromChar

/**
 *  build a general purpose feature from a valid characteristics
 *
 *  @param c characteristic with an uuid compatible as a general purpose feature
 */
-(void) buildGeneraPurposeFeatureFromChar:(CBCharacteristic*)c{
    BlueSTSDKFeature *f = [[BlueSTSDKFeatureGenPurpose alloc]initWhitNode:self characteristics:c];
    [f setEnabled:true];
    [mAvailableFeature addObject:f];
    BlueSTSDKCharacteristic* temp = [[BlueSTSDKCharacteristic alloc]
            initWithChar:c features:@[f]];
    [mCharFeatureMap addObject: temp];
}//buildGeneraPurposeFeatureFromChar

- (void)buildKnowUUID:(CBCharacteristic *)characteristic
             features:(NSArray<Class> *)features{
    NSMutableArray *charFeature = [[NSMutableArray alloc] initWithCapacity:features.count];

    for (Class c in features){
        BlueSTSDKFeature *f = [self buildFeatureFromClass:c];
        if(f!=nil){
            [f setEnabled:true];
            [charFeature addObject:f];
            [mAvailableFeature addObject:f];
        }//if
    }

    if(charFeature.count != 0){ //if we found some feature save it
        BlueSTSDKCharacteristic* temp = [[BlueSTSDKCharacteristic alloc]
                initWithChar:characteristic features:charFeature];
        [mCharFeatureMap addObject: temp];
    }//if
}

/**
 * if the service is know we build the link object, otherwise we scan
 * the characteristics searching an uuid compatible with the sdk
 */
- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverCharacteristicsForService:(CBService *)service
             error:(NSError *)error {

    if(error){
        NSLog(@"Error discovering the service: %@ Error: %@",
              service.UUID.UUIDString,error.localizedDescription);
        [self updateNodeStatus:BlueSTSDKNodeStateUnreachable];
        return;
    }
    
    //we already see this service -> return
    if(![mCharDiscoverServiceReq containsObject:service])
        return;
    
    //NSLog(@"Service: %@", service.UUID.UUIDString);
    //for (CBCharacteristic *c in service.characteristics) {
    //    NSLog(@" - Char: %@", c.UUID.UUIDString);
    //}
    
    if( service.isDebugService  ){
        _debugConsole = [self buildDebugService:service];
    }else if( service.isConfigService){
        _configControl = [self buildConfigService:service];
    }else{
        for (CBCharacteristic *c in service.characteristics) {            
            if (c.isFeatureCaracteristics){
                [self buildKnowFeatureFromChar:c];
            }else if (c.extendedFeature!=nil){
                [self buildKnowUUID:c features:c.extendedFeature];
            }else if (c.isFeatureGeneralPurposeCharacteristics){
                [self buildGeneraPurposeFeatureFromChar:c];
            }else if (mExternalCharFeature!=nil && mExternalCharFeature[c.UUID]!=nil)
                [self buildKnowUUID:c features:mExternalCharFeature[c.UUID]];

        }//for char
    }//if else
    
    [mCharDiscoverServiceReq removeObject:service];
    if(mCharDiscoverServiceReq.count == 0){
        // before fire the connected state, wait a second if a didModifyServices callback arrive and rebuild all the
        // feature/characteristics mapping
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(NSEC_PER_SEC)), sNotificationQueue, ^{
            if(![self isConnected]){
                if(self->mFeatureCommand!=nil){
                    self->mFeatureCommandNotifyEnable=false;
                    [self->mPeripheral setNotifyValue:YES forCharacteristic:self->mFeatureCommand];
                }
                [self updateNodeStatus:BlueSTSDKNodeStateConnected];
            }//if
        });
    }

    //debug
    /*NSLog(@"Know Char:");
    for (BlueSTSDKCharacteristic *temp in mCharFeatureMap) {
        NSLog(@"Add Char %@",temp.characteristic.UUID.UUIDString);
    }*/
    
}

/**
 * call when we receive a message in the config characteristics, this method will
 * parse the response byte stream and notify it on the correct feature
 *
 *  @param data response data from the node
 */
-(void)notifyCommandResponse:(NSData*)data{

    if(data.length<7)
        return;
    
    uint32_t timestamp =[data extractLeUInt16FromOffset: 0];
    uint32_t featureMask = [data extractBeUInt32FromOffset:2];
    uint8_t commandType = [data extractUInt8FromOffset:6];
    
    NSData *resp = [data subdataWithRange:NSMakeRange(7, data.length-7)];
    
    BlueSTSDKFeature *f = mMaskToFeature[@(featureMask)];
    if(f!=nil)
        [f parseCommandResponseWithTimestamp:timestamp commandType:commandType
                                       data: resp];
    else
        NSLog(@"Receive a response for the feature %X that is not handle by this node",featureMask);
}

/**
 *  dispatch the update to the feature or the object that will parse the data
 *
 *  @param characteristics node characteristics that send a notify/read message
 */
-(void)characteristicUpdate:(CBCharacteristic*)characteristics{
    
    if([characteristics isEqual: mFeatureCommand]){
        [self notifyCommandResponse: characteristics.value];
        return;
    } else if(_debugConsole!=nil && characteristics.isDebugCharacteristic){
        [_debugConsole receiveCharacteristicsUpdate:characteristics];
        return;
    } else if(_configControl!=nil &&
             characteristics.isConfigCharacteristics){
        [_configControl characteristicsUpdate:characteristics];
        return;
    }//else
    
    NSData *newData = characteristics.value;
    NSArray *features = [BlueSTSDKCharacteristic getFeaturesFromChar:characteristics
                                                                in:mCharFeatureMap];

    if(features==nil){
        NSLog(@"Receive a notification for a characteristics that isn't handle by the sdk");
        return;
    }//if

    uint64_t timestamp=0;
    if([newData length]>=2){
        //extract the timestamp and add the offset for extend the ts from 16bit to 32
        uint16_t timeStamp16 = [newData extractLeUInt16FromOffset: 0];
        timestamp = [mUnwrapUtil unwrap:timeStamp16];
    }else{
        timestamp =[mUnwrapUtil getNext];
    }
    
    uint32_t offset=2; // =2 since we already read 2 byte for the timestamp
    for(BlueSTSDKFeature *f in features){
        offset += [f update:timestamp data:newData dataOffset:offset];
    }//for
    
}//characteristicUpdate

/**
 *  Call when a characteristic is read or notify
 */
- (void)peripheral:(CBPeripheral *)peripheral
didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error {
    if(error){
        NSLog(@"Error reading the char: %@ Error: %@",
              characteristic.UUID.UUIDString,error.localizedDescription);
        [self updateNodeStatus:BlueSTSDKNodeStateLost];
        return;
    }//if
    
    //we are reading the data so we correctly enable the notification
    @synchronized(mAskForNotification){
        if( [mAskForNotification containsObject:characteristic.UUID]){
            [mAskForNotification removeObject:characteristic.UUID];
        }//if
    }//synchronized
    
    [self characteristicUpdate:characteristic];
}//didUpdateValueForCharacteristic

/**
 * Call where a message is write to a characteristics, this function will route
 * the notification to the object that request the write
 */
- (void)peripheral:(CBPeripheral *)peripheral
didWriteValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error{
    if(error){
        NSLog(@"Error writing the char: %@ Error: %@",
              characteristic.UUID.UUIDString,error.localizedDescription);
        [self updateNodeStatus:BlueSTSDKNodeStateLost];
    }//if
    
    if (characteristic.isDebugTermCharacteristic &&
        _debugConsole!=nil){
        [_debugConsole receiveCharacteristicsWriteUpdate:characteristic error:error];
    } else if(_configControl!=nil &&
              characteristic.isConfigCharacteristics){
        [_configControl characteristicsWriteUpdate:characteristic success:(error == nil)];
    }//else

}//didWriteValueForCharacteristic

/**
 * call when we change the notification state of a characteristics. 
 * It change the node status if there is some error
 */
- (void)peripheral:(CBPeripheral *)peripheral
didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error{
    
    if(error){
        NSLog(@"Error updating the char: %@ Error: %@",
              characteristic.UUID.UUIDString,error.localizedDescription);
        [self updateNodeStatus:BlueSTSDKNodeStateLost];
    }else{
        if(characteristic==mFeatureCommand){
            mFeatureCommandNotifyEnable=true;
            return;
        }
        dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW,
                (int64_t)(RETRAY_ENABLE_NOTIFICATION_DELAY) * NSEC_PER_SEC);

        if(characteristic.isNotifying){
            //we reuse the queue for the notification
            dispatch_after(when, sNotificationQueue, ^{
                @synchronized(self->mAskForNotification){
                    //if the uuid is still there we didn't receive data ->
                    //subscribe again to the characteristics
                    if([self->mAskForNotification containsObject:characteristic.UUID]){
                        [self->mPeripheral setNotifyValue:YES forCharacteristic:characteristic]; //request again
                    }//if
                }//syncronized
            });
        }
    }//if-else
}//didUpdateNotificationStateForCharacteristic

/** call if the node change its services/characteristics, just re scan the new services */
- (void)peripheral:(CBPeripheral *)peripheral
 didModifyServices:(NSArray<CBService *> *)invalidatedServices{
    //remove all the feature char object since it will be reboud with the new scanning
    [mCharFeatureMap removeAllObjects];
    [mAvailableFeature removeAllObjects];
    [mNotifyFeature removeAllObjects];
    
    [peripheral discoverServices:nil];
}

+(NSString*)nodeTypeToString:(BlueSTSDKNodeType)type{
    
    switch (type) {
        case BlueSTSDKNodeTypeNucleo:
            return @"Nucleo";
        case BlueSTSDKNodeTypeSensor_Tile:
            return @"SensorTile";
        case BlueSTSDKNodeTypeSensor_Tile_Box:
            return @"SensorTile.Box";
        case BlueSTSDKNodeTypeBlue_Coin:
            return @"BlueCoin";
        case BlueSTSDKNodeTypeSTEVAL_WESU1:
            return @"STEVAL_WESU1";
        case BlueSTSDKNodeTypeSTEVAL_IDB008VX:
            return @"STEVAL_IDB008VX";
        case BlueSTSDKNodeTypeSTEVAL_BCN002V1:
            return @"STEVAL_BCN002V1";
        case BlueSTSDKNodeTypeDiscovery_IOT01A:
            return @"DISCOVERY_IOT01A";
        case BlueSTSDKNodeTypeGeneric:
            return @"GENERIC";
    }
    
}


+(NSString*) stateToString:(BlueSTSDKNodeState)state{
    switch (state) {
        case BlueSTSDKNodeStateConnected:
            return BLUESTSDK_LOCALIZE(@"Connected",nil);
        case BlueSTSDKNodeStateConnecting:
            return BLUESTSDK_LOCALIZE(@"Connecting",nil);
        case BlueSTSDKNodeStateDead:
            return BLUESTSDK_LOCALIZE(@"Dead",nil);
        case BlueSTSDKNodeStateDisconnecting:
            return BLUESTSDK_LOCALIZE(@"Disconnecting",nil);
        case BlueSTSDKNodeStateIdle:
            return BLUESTSDK_LOCALIZE(@"Idle",nil);
        case BlueSTSDKNodeStateInit:
            return BLUESTSDK_LOCALIZE(@"Init",nil);
        case BlueSTSDKNodeStateLost:
            return BLUESTSDK_LOCALIZE(@"Lost",nil);
        case BlueSTSDKNodeStateUnreachable:
            return BLUESTSDK_LOCALIZE(@"Unreachable",nil);
        default:
            return BLUESTSDK_LOCALIZE(@"Invalid Enum value",nil);
    }//switch
}//stateToString

-(BOOL) isExportingFeature:(Class)featureClass{
    NSDictionary<NSNumber*,Class> *maskFeatureMap = [[BlueSTSDKManager sharedInstance] getFeaturesForNode: self.typeId];
    NSArray<NSNumber*>* maskArray = [maskFeatureMap allKeysForObject:featureClass];
    for (int i = 0 ; i < maskArray.count ; i++){
        uint32_t mask = (uint32_t) maskArray[i].unsignedIntValue;
        if((self.advertiseBitMask & mask) != 0)
            return true;
    }
    return false;
}

-(NSInteger)maximumWriteValueLength{
    return [mPeripheral maximumWriteValueLengthForType:CBCharacteristicWriteWithoutResponse];
}

@end
