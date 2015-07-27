//
//  W2STSDKNode.m
//  W2STSDK
//
//  Created by Giovanni Visentini on 21/04/15
//  Copyright (c) 2014 STMicroelectronics. All rights reserved.
//

#import "W2STSDKManager_prv.h"
#import "W2STSDKNode_prv.h"
#import "W2STSDKFeature_prv.h"
#import "W2STSDKFeatureGenPurpose.h"
#import "W2STSDKDebug_prv.h"
#import "W2STSDKConfigControl_prv.h"

#import "Util/W2STSDKCharacteristic.h"
#import "Util/W2STSDKBleAdvertiseParser.h"
#import "Util/W2STSDKBleNodeDefines.h"
#import "util/NSData+NumberConversion.h"

@interface W2STSDKNode()<CBPeripheralDelegate>
@end

/**
 * concurrent queue used for notify the node update in different thread
 */
static dispatch_queue_t sNotificationQueue;

@implementation W2STSDKNode {

    /**
     *  characteristics where write the command for the feature, null if the 
     * functionality is not present
     */
    CBCharacteristic *mFeatureCommand;
    
    /**
     *  remote ble device
     */
    CBPeripheral *mPeripheral;
    
    /**
     *  set of delegate where notify changes in the ble connection paramiters
     */
    NSMutableSet *mBleConnectionDelegates;
    
    /**
     *  set of delegate where notify changes in node status
     */
    NSMutableSet *mNodeStatusDelegates;
    
    /**
     *  connect a bitmask with the build feature
     */
    NSMutableDictionary *mMaskToFeature;
    
    /**
     *  array of W2STSDKCharacteristics it contans the mapping between
     * CBCharacteristics and W2STSDKFeatrure
     */
    NSMutableArray *mCharFeatureMap;
    
    /**
     *  array of W2STSDKFeature that the node export
     */
    NSMutableArray *mAvailableFeature;
    
    /**
     *  set of W2STSDKFeature that are currently in notify mode
     */
    NSMutableSet *mNotifyFeature;
    
    /**
     *  true if the user ask to disconnect, it is used for understend if we lost
     * the connection with the node
     */
    BOOL mUserAskDisconnect;
    
    // array that will contain the service for that we request the characteristics,
    //when this array becomes empty the node is connected
    NSMutableArray *mCharDiscoverServiceReq;
    
    /**
     *  number of time tahat the ts has reset, the ts is reseted when we see a ts
     * with a lower value after that the ts reach the valu 2^16-100
     */
    uint32_t mNReset;
    
    /** last raw ts received from the board, it is a numer between 0 and (2^16)-1
     */
    uint16_t mLastTs;
    
}

/**
 *  instanziate a feature from a class type
 *
 *  @param featureClass class to instanziate, it must be a class that extend the 
 *  W2STSDKFeature
 *
 *  @return object of type "featureClass"
 */
-(W2STSDKFeature*) buildFeatureFromClass:(Class)featureClass{
    return [((W2STSDKFeature*)[featureClass alloc]) initWhitNode:self];

}

/**
 * from the bitmask in the advertise message and the dictionary that map a 
 * bitmask to a feature class inizialize the mAvvailableFeature and the
 * mMaskToFeature array
 *
 *  @param mask           bitmask from the advertise, tell us what feature are present in the node
 *  @param maskFeatureMap map that connect a bit position with a feature class, 
 *   if null the method don't do anything
 */
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
                    NSLog(@"Impossible build the feature %@",[featureClass description]);
                }//if f
            }// if featureClass
        }//if mask
    }//for
}

-(id)init{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sNotificationQueue = dispatch_queue_create("W2STNode", DISPATCH_QUEUE_CONCURRENT);
    });
    
    mNodeStatusDelegates = [NSMutableSet set];
    mBleConnectionDelegates = [NSMutableSet set];
    mCharFeatureMap = [NSMutableArray array];
    mNotifyFeature = [NSMutableSet set];
    mFeatureCommand=nil;
    _debugConsole=nil;
    _configControl=nil;
    _state=W2STSDKNodeStateIdle;
    return self;
}

-(id)init:(CBPeripheral *)peripheral rssi:(NSNumber*)rssi advertise:(NSDictionary*)advertisementData{
    self = [self init];
    mPeripheral=peripheral;
    mPeripheral.delegate=self;

    _tag = peripheral.identifier.UUIDString;

    W2STSDKBleAdvertiseParser *parser = [W2STSDKBleAdvertiseParser
                                         advertiseParserWithAdvertise:advertisementData];
    [self buildAvailableFeatures: parser.featureMap maskFeatureMap:parser.featureMaskMap];
    
    _type = parser.nodeType;
    _name = parser.name;
    _address = parser.address;
    _protocolVersion = parser.protocolVersion;
    
    [self updateTxPower: parser.txPower];
    
    [self updateRssi:rssi];
    //NSLog(@"create Node: name: %@ type: %x feature: %d",_name,_type,parser.featureMap);
    return self;
}


-(void) addBleConnectionParamiterDelegate:(id<W2STSDKNodeBleConnectionParamDelegate>)delegate{
    [mBleConnectionDelegates addObject:delegate];
}
-(void) removeBleConnectionParamiterDelegate:(id<W2STSDKNodeBleConnectionParamDelegate>)delegate{
    [mBleConnectionDelegates removeObject:delegate];
}

-(void) addNodeStatusDelegate:(id<W2STSDKNodeStateDelegate>)delegate{
    [mNodeStatusDelegates addObject:delegate];
}
-(void) removeNodeStatusDelegate:(id<W2STSDKNodeStateDelegate>)delegate{
    [mNodeStatusDelegates removeObject:delegate];
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
    mUserAskDisconnect=false;
    [self updateNodeStatus:W2STSDKNodeStateConnecting];
    [[W2STSDKManager sharedInstance]connect:mPeripheral];
}

-(void)completeConnection{
    if(mPeripheral.state !=	CBPeripheralStateConnected){
        [self updateNodeStatus:W2STSDKNodeStateUnreachable];
        return;
    }
    mLastTs=0;
    mNReset=0;
    //else
    [mPeripheral discoverServices:nil];
}


- (BOOL) isConnected{
    return self.state==W2STSDKNodeStateConnected;
}


-(void)completeDisconnection:(NSError*)error{
    if(mUserAskDisconnect){
        if(error==nil){
            //all ok
            [self updateNodeStatus:W2STSDKNodeStateIdle];
        }else{
            NSLog(@"Node: %@ Error: %@",_name,[error debugDescription]);
            [self updateNodeStatus:W2STSDKNodeStateDead];
        }
    }else{
        NSLog(@"Node: %@ Error: %@",_name,[error debugDescription]);
        [self updateNodeStatus:W2STSDKNodeStateUnreachable];
    }
    
}

-(void) disconnect{
    [self updateNodeStatus:W2STSDKNodeStateDisconnecting];
    mUserAskDisconnect=true;
    
    if(mFeatureCommand!=nil)
        [mPeripheral setNotifyValue:NO forCharacteristic:mFeatureCommand];
    
    //we remove the feature/char map since it must be rebuild every time we connect
    [mCharFeatureMap removeAllObjects];
    
    //we close the connection so we remove all the notify characteristics
    [mNotifyFeature removeAllObjects];
    
    [[W2STSDKManager sharedInstance]disconnect:mPeripheral];
}

-(void)connectionError:(NSError*)error{
    NSLog(@"Error Node:%@ %@ (%ld)",self.name,error.description,(long)error.code);
   [self updateNodeStatus:W2STSDKNodeStateDead];
}

/**
 *  find the CBCharacteristics that we can use for read/write a feature
 *
 *  @param feature feature that we want read/write
 *
 *  @return CBCharacteristics equivalent to the feature in the node
 */
-(CBCharacteristic*) extractCharacteristicsFromFeature:(W2STSDKFeature*)feature{
    //if is a generic feature we use the characteristics inside the class
    if([feature isKindOfClass:W2STSDKFeatureGenPurpose.class])
        return ((W2STSDKFeatureGenPurpose*)feature).characteristics;
    else //otherwise we extract it from the map since a feature can be inside more than one CBCharacteristics
        return [W2STSDKCharacteristic getCharFromFeature:feature in:mCharFeatureMap];
}

-(BOOL)readFeature:(W2STSDKFeature *)feature{
    CBCharacteristic *c =[self extractCharacteristicsFromFeature: feature];
    if(c==nil)
        return false;
    [mPeripheral readValueForCharacteristic:c];
    return true;
}


-(BOOL) isEnableNotification:(W2STSDKFeature*)feature{
    return [mNotifyFeature containsObject:feature];
}

-(BOOL) enableNotification:(W2STSDKFeature*)feature{
    if(![feature enabled])
        return false;
    
    CBCharacteristic *c= [self extractCharacteristicsFromFeature:feature];
    if(c==nil)
        return false;
    [mPeripheral setNotifyValue:YES forCharacteristic:c];
    [mNotifyFeature addObject:feature];
    return true;
}

-(BOOL) disableNotification:(W2STSDKFeature*)feature{
    if(![feature enabled])
        return false;
    CBCharacteristic *c=[self extractCharacteristicsFromFeature:feature];
    if(c==nil)
        return false;
    [mPeripheral setNotifyValue:NO forCharacteristic:c];
    [mNotifyFeature removeObject:feature];
    return true;
}

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
    [msg appendBytes:&type length:1];
    [msg appendBytes:&mask length:4];
    [msg appendData:data];
    return msg;
}

-(BOOL)sendCommandMessageToFeature:(W2STSDKFeature*)feature type:(uint8_t)commandType
                     data:(NSData*) commandData{
    if(mFeatureCommand==nil)
        return false;
    if([feature isKindOfClass:W2STSDKFeatureGenPurpose.class])
        return false;
    
    CBCharacteristic *featureChar = [W2STSDKCharacteristic getCharFromFeature:feature in:mCharFeatureMap];
    if(featureChar==nil)
        return false;
    featureMask_t featureMask = [W2STSDKFeatureCharacteristics extractFeatureMask:featureChar.UUID];
    NSData *msg = [W2STSDKNode prepareMessageWithMask:featureMask type:commandType data:commandData];
    [mPeripheral writeValue:msg forCharacteristic:mFeatureCommand type:CBCharacteristicWriteWithoutResponse];
    return true;
}

-(BOOL)writeDataToFeature:(W2STSDKFeature *)feature data:(NSData *)data{
    CBCharacteristic *featureChar=[self extractCharacteristicsFromFeature:feature];

    if(featureChar==nil)
        return false;
    
    [mPeripheral writeValue:data forCharacteristic:featureChar type:CBCharacteristicWriteWithoutResponse];
    return true;
}


#pragma mark - CBPeripheralDelegate
/**
 * if we receive an rssi update, we notify it to the delegate
 */
- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral
                          error:(NSError *)error{
    if(error==nil){
        [self updateRssi:peripheral.RSSI];
    }else
        NSLog(@"Error Updating Rssi: %@ (%ld)",error.description,(long)error.code);
}

/**
 * we discover the serivces during the first connection, for each service we 
 * request also to discover the characteristics
 */
- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverServices:(NSError *)error{
    if([self isConnected]) //we already run this method one time
        return;
    if(error!=nil)
       [self updateNodeStatus:W2STSDKNodeStateUnreachable];
    /*
    we store all the service in an array, when we recevie the characteristics
    of a service we remove from the array in a way to avoid to scan multiple time
    the same service */
    mCharDiscoverServiceReq = [NSMutableArray arrayWithArray: peripheral.services];
    for (CBService *service in peripheral.services) {
        NSLog(@"Discovered Service: %@",service.UUID.UUIDString);
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

/**
 *  create a debug object
 *
 *  @param service ble service that contains the ble characteristics for the debug
 *
 *  @return object to use for access to the stderr/out/in stream
 */
-(W2STSDKDebug*) buildDebugService:(CBService*)service{
    
    CBCharacteristic *term=nil,*err=nil;
    for(CBCharacteristic *c in service.characteristics){
        if([c.UUID isEqual:W2STSDKServiceDebug.termUuid]){
            term = c;
        }else if([c.UUID isEqual:W2STSDKServiceDebug.stdErrUuid]){
            err = c;
        }//if-else-if
    }//for
    return term == nil || err == nil ? nil : [[W2STSDKDebug alloc] initWithNode:self device:mPeripheral termChart:term errChart:err];
}

/**
 *  create a debug object
 *
 *  @param service ble service that contains the ble characteristics for the debug
 *
 *  @return object to use for access to the stderr/out/in stream
 */
-(W2STSDKConfigControl *) buildConfigService:(CBService*)service {
    
    CBCharacteristic *configcontrolchar=nil;
    for(CBCharacteristic *c in service.characteristics) {
        if([c.UUID isEqual:W2STSDKServiceConfig.configControlUuid]){
            configcontrolchar = c;
        } else if ([c.UUID isEqual:W2STSDKServiceConfig.featureCommandUuid]) {
            mFeatureCommand = c; //to compatibility with previous code
        }
    }//for
//    if(configcontrolchar!=nil){
//      return [;
    
    //}
    return configcontrolchar == nil ? nil : [W2STSDKConfigControl configControlWithNode:self device:mPeripheral configControlChart:configcontrolchar];
}

/**
 *  create a feature from a valid characteristics
 *
 *  @param c characteristic that will export one or more features
 */
-(void)buildKnowFeatureFromChar:(CBCharacteristic*)c{
    featureMask_t featureMask = [W2STSDKFeatureCharacteristics extractFeatureMask:c.UUID];
    NSMutableArray *charFeature = [[NSMutableArray alloc] initWithCapacity:1];
    for(NSNumber *mask in mMaskToFeature.allKeys ){
        featureMask_t temp = (featureMask_t) mask.unsignedIntegerValue;
        if((temp & featureMask)!=0){
            W2STSDKFeature *f = [mMaskToFeature objectForKey:mask];
            [f setEnabled:true];
            [charFeature addObject:f];
        }//if
    }//for
    
    if(charFeature.count != 0){
        W2STSDKCharacteristic* temp = [[W2STSDKCharacteristic alloc]
                                       initWithChar:c features:charFeature];
        [mCharFeatureMap addObject: temp];
    }//if
}

/**
 *  build a general purpose feature from a valid characteristics
 *
 *  @param c characteristic with an uuid compatible as a general purpose feature
 */
-(void) buildGeneraPurposeFeatureFromChar:(CBCharacteristic*)c{
    W2STSDKFeature *f = [[W2STSDKFeatureGenPurpose alloc]initWhitNode:self characteristics:c];
    [f setEnabled:true];
    [mAvailableFeature addObject:f];
    W2STSDKCharacteristic* temp = [[W2STSDKCharacteristic alloc]
                                   initWithChar:c features:[NSArray arrayWithObjects:f,nil]];
    [mCharFeatureMap addObject: temp];
}

/**
 * if the service is know we build the corrispective object, otherwise we scan
 * the characteristics searching an uuid compatible with the sdk
 */
- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverCharacteristicsForService:(CBService *)service
             error:(NSError *)error {
    
    //we already see this service -> return
    if(![mCharDiscoverServiceReq containsObject:service])
        return;
    
    if(error){
        NSLog(@"Error discovering the service: %@ Erorr: %@",
              service.UUID.UUIDString,error.localizedDescription);
        [self updateNodeStatus:W2STSDKNodeStateUnreachable];
    }
    
    NSLog(@"Service: %@", service.UUID.UUIDString);
    for (CBCharacteristic *c in service.characteristics) {
        NSLog(@" - Char: %@", c.UUID.UUIDString);
    }
    if( [[service UUID] isEqual:[W2STSDKServiceDebug serviceUuid]]  ){
        _debugConsole = [self buildDebugService:service];
    }else if( [[service UUID] isEqual:[W2STSDKServiceConfig serviceUuid]]  ){
        
        _configControl = [self buildConfigService:service];
        
        //AR the association has been moved in the buildConfigService
//        for (CBCharacteristic *c in service.characteristics) {
//            if ([c.UUID isEqual: [W2STSDKServiceConfig featureCommandUuid]])
//                mFeatureCommand = c;
//        }//for
    }else{
        for (CBCharacteristic *c in service.characteristics) {            
            if ([W2STSDKFeatureCharacteristics isFeatureCharacteristics: c]){
                [self buildKnowFeatureFromChar:c];
            }else if ([W2STSDKFeatureCharacteristics isFeatureGeneralPurposeCharacteristics:c]){
                [self buildGeneraPurposeFeatureFromChar:c];
            }//if-else
        }//for char
    }//if else
    
    [mCharDiscoverServiceReq removeObject:service];
    if(mCharDiscoverServiceReq.count == 0){
        if(mFeatureCommand!=nil)
           [mPeripheral setNotifyValue:YES forCharacteristic:mFeatureCommand];
        [self updateNodeStatus:W2STSDKNodeStateConnected];
    }
    
    /*
    //debug
    NSLog(@"Know Char:");
    for (W2STSDKCharacteristic *temp in mCharFeatureMap) {
        NSLog(@"Add Char %@",temp.characteristic.UUID.UUIDString);
    }
    */
}

/**
 *  parse the response byte stream and pass the data to the feature
 *
 *  @param data response data from the node
 */
-(void)notifyCommandResponse:(NSData*)data{

    uint32_t timestamp =[data extractLeUInt16FromOffset: 0];
    uint32_t featureMask = [data extractBeUInt32FromOffset:2];
    uint8_t commandType = [data extractUInt8FromOffset:6];
    NSData *resp = [data subdataWithRange:NSMakeRange(7, data.length-7)];
    
    W2STSDKFeature *f = [mMaskToFeature objectForKey: [NSNumber numberWithUnsignedInt:featureMask]];
    if(f!=nil)
        [f parseCommandResponseWithTimestamp:timestamp commandType:commandType
                                       data: resp];
    else
        NSLog(@"Receve a response for the feature %X that is not handle by this node",featureMask);
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
    } else if(_debugConsole!=nil &&
             [W2STSDKServiceDebug isDebugCharacteristics:characteristics]){
        [_debugConsole receiveCharacteristicsUpdate:characteristics];
        return;
    } else if(_configControl!=nil &&
             [W2STSDKServiceConfig isConfigControlCharacteristic:characteristics]){
        [_configControl characteristicsUpdate:characteristics];
    }//else
    
    NSData *newData = characteristics.value;
    NSArray *features = [W2STSDKCharacteristic getFeaturesFromChar:characteristics
                                                                in:mCharFeatureMap];

    uint16_t timeStamp16 = [newData extractLeUInt16FromOffset: 0];
    if(mLastTs>((1<<16)-100) && mLastTs > timeStamp16)
        mNReset++;
    uint32_t timestamp = mNReset * (1<<16) + timeStamp16;
    mLastTs=timeStamp16;
    uint32_t offset=2;
    for(W2STSDKFeature *f in features){
        offset += [f update:timestamp data:newData dataOffset:offset];
    }

}

- (void)peripheral:(CBPeripheral *)peripheral
didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error {
    
    if(error){
        NSLog(@"Error updating the char: %@ Erorr: %@",
              characteristic.UUID.UUIDString,error.localizedDescription);
        [self updateNodeStatus:W2STSDKNodeStateLost];
    }
    
    [self characteristicUpdate:characteristic];
}
- (void)peripheral:(CBPeripheral *)peripheral
didWriteValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error{
    if(error){
        NSLog(@"Error writing the char: %@ Erorr: %@",
              characteristic.UUID.UUIDString,error.localizedDescription);
        [self updateNodeStatus:W2STSDKNodeStateLost];
    }
    
    if ([characteristic.UUID isEqual: [W2STSDKServiceDebug termUuid]] &&
        _debugConsole!=nil){
        [_debugConsole receiveCharacteristicsWriteUpdate:characteristic error:error];
    } else if(_configControl!=nil &&
              [W2STSDKServiceConfig isConfigControlCharacteristic:characteristic]){
        [_configControl characteristicsWriteUpdate:characteristic success:(error == nil)];
    }//else

}

- (void)peripheral:(CBPeripheral *)peripheral
didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error{
    if(error){
        NSLog(@"Error updating the char: %@ Erorr: %@",
              characteristic.UUID.UUIDString,error.localizedDescription);
        [self updateNodeStatus:W2STSDKNodeStateLost];
    }
}

+(NSString*) stateToString:(W2STSDKNodeState)state{
    switch (state) {
        case W2STSDKNodeStateConnected:
            return @"Connected";
        case W2STSDKNodeStateConnecting:
            return @"Connecting";
        case W2STSDKNodeStateDead:
            return @"Dead";
        case W2STSDKNodeStateDisconnecting:
            return @"Disconnecting";
        case W2STSDKNodeStateIdle:
            return @"Idle";
        case W2STSDKNodeStateInit:
            return @"Init";
        case W2STSDKNodeStateLost:
            return @"Lost";
        case W2STSDKNodeStateUnreachable:
            return @"Unreachable";
        default:
            return@"Invalid Enum value";
    }
}


@end
