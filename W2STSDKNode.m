//
//  W2STSDKNode.m
//  W2STSDK-CB
//
//  Created by Antonino Raucea on 18/03/14.
//  Copyright (c) 2014 STMicroelectronics. All rights reserved.
//

/////////////new sdk///////////////////

#import "W2STSDKNode.h"
#import "W2STSDKFeature.h"
#import "W2STSDKDebug.h"
#import "Util/W2STSDKCharacteristic.h"
#import "Util/W2STSDKBleAdvertiseParser.h"
#import "Util/W2STSDKBleNodeDefines.h"
#import "util/NSData+NumberConversion.h"

@interface W2STSDKNode()
-(void)buildAvailableFeatures:(featureMask_t)mask maskFeatureMap:(NSDictionary*)maskFeatureMap;

-(W2STSDKFeature*) buildFeatureFromClass:(Class)featureClass;
@end

//private static variable
static dispatch_queue_t sNotificationQueue;

@implementation W2STSDKNode {
#pragma mark NodePrivateObject
    //NSMutableArray *_notifiedCharacteristics;
    CBCharacteristic *mFeatureCommand;
    CBPeripheral *mPeripheral;
    NSMutableSet *mBleConnectionDelegates;
    NSMutableSet *mNodeStatusDelegates;
    
    NSMutableDictionary *mMaskToFeature;
    NSMutableArray *mCharFeatureMap;
    NSMutableArray *mAvailableFeature;
    NSMutableSet *mNotifyFeature;
    
    BOOL mUserAskDisconnect;
    
    // array that will contain the service for that we request the characteristics,
    //when this array becames empty the node is connected
    NSMutableArray *mCharDiscoverServiceReq;
    
}

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
                    NSLog(@"Impossible build the feature %@",[featureClass description]);
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

    
    mNodeStatusDelegates = [NSMutableSet set];
    mBleConnectionDelegates = [NSMutableSet set];
    mCharFeatureMap = [NSMutableArray array];
    mNotifyFeature = [NSMutableSet set];
    mFeatureCommand=nil;
    _debugConsole=nil;
    mPeripheral=peripheral;
    mPeripheral.delegate=self;
    _state=W2STSDKNodeStateIdle;
    _name = peripheral.name;
    _tag = peripheral.identifier.UUIDString;
    W2STSDKBleAdvertiseParser *parser = [[W2STSDKBleAdvertiseParser alloc]
                        initWithAdvertise:advertisementData];
    [self buildAvailableFeatures: parser.featureMap maskFeatureMap:parser.featureMaskMap];
    _type = parser.nodeType;

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
    
    //we remove the feature/char map since it must be rebuild evry time we connect
    [mCharFeatureMap removeAllObjects];
    
    //we close the connection so we remove all the notify characteristics
    [mNotifyFeature removeAllObjects];
    
    [[W2STSDKManager sharedInstance]disconnect:mPeripheral];
}

-(void)connectionError:(NSError*)error{
    NSLog(@"Error Node:%@ %@ (%d)",self.name,error.description,error.code);
   [self updateNodeStatus:W2STSDKNodeStateDead];
}

-(BOOL)readFeature:(W2STSDKFeature *)feature{
    CBCharacteristic *c = [W2STSDKCharacteristic getCharFromFeature:feature in:mCharFeatureMap];
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
    CBCharacteristic *c = [W2STSDKCharacteristic getCharFromFeature:feature in:mCharFeatureMap];
    if(c==nil)
        return false;
    [mPeripheral setNotifyValue:YES forCharacteristic:c];
    [mNotifyFeature addObject:feature];
    return true;
}

-(BOOL) disableNotification:(W2STSDKFeature*)feature{
    if(![feature enabled])
        return false;
    CBCharacteristic *c = [W2STSDKCharacteristic getCharFromFeature:feature in:mCharFeatureMap];
    if(c==nil)
        return false;
    [mPeripheral setNotifyValue:NO forCharacteristic:c];
    [mNotifyFeature removeObject:feature];
    return true;
}

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
    
    CBCharacteristic *featureChar = [W2STSDKCharacteristic getCharFromFeature:feature in:mCharFeatureMap];
    if(featureChar==nil)
        return false;
    featureMask_t featureMask = [W2STSDKFeatureCharacteristics extractFeatureMask:featureChar.UUID];
    NSData *msg = [W2STSDKNode prepareMessageWithMask:featureMask type:commandType data:commandData];
    [mPeripheral writeValue:msg forCharacteristic:mFeatureCommand type:CBCharacteristicWriteWithoutResponse];
    return true;
}

-(BOOL)writeDataToFeature:(W2STSDKFeature *)f data:(NSData *)data{
    
    CBCharacteristic *featureChar = [W2STSDKCharacteristic getCharFromFeature:f in:mCharFeatureMap];
    if(featureChar==nil)
        return false;
    
    [mPeripheral writeValue:data forCharacteristic:featureChar type:CBCharacteristicWriteWithoutResponse];
    return true;
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
    if([self isConnected]) //we already run this method one time
        return;
    
    mCharDiscoverServiceReq = [NSMutableArray arrayWithArray: peripheral.services];
    for (CBService *service in peripheral.services) {
        NSLog(@"Discover sService: %@",service.UUID.UUIDString);
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

-(W2STSDKDebug*) buildDebugService:(CBService*)service{
    
    CBCharacteristic *term=nil,*err=nil;
    for(CBCharacteristic *c in service.characteristics){
        if([c.UUID isEqual:W2STSDKServiceDebug.termUuid]){
            term = c;
        }else if([c.UUID isEqual:W2STSDKServiceDebug.stdErrUuid]){
            err = c;
        }//if-else-if
    }//for
    if(term!=nil && err!=nil){
        return [[W2STSDKDebug alloc]initWithNode:self device:mPeripheral
                                       termChart:term errChart:err];
    
    }//else
    return nil;
}

//for each services find the known characteristics
- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverCharacteristicsForService:(CBService *)service
             error:(NSError *)error {
    
    //we already see this service -> return
    if(![mCharDiscoverServiceReq containsObject:service])
        return;
    
    if (error && [error code] != 0) {
        NSLog(@"Error %@\n", error);
        return ;
    }
    
    if( [[service UUID] isEqual:[W2STSDKServiceDebug serviceUuid]]  ){
        _debugConsole = [self buildDebugService:service];
    }else if( [[service UUID] isEqual:[W2STSDKServiceConfig serviceUuid]]  ){
        NSLog(@"Config Service Discoverd");
        for (CBCharacteristic *c in service.characteristics) {
            if ([c.UUID isEqual: [W2STSDKServiceConfig featureCommandUuid]])
                mFeatureCommand = c;
        }//for
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
                    W2STSDKCharacteristic* temp = [[W2STSDKCharacteristic alloc]
                                                   initWithChar:c features:charFeature];
                    [mCharFeatureMap addObject: temp];
                }//if
            }//if featureChar
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

-(void)notifyCommandResponse:(NSData*)data{

    uint32_t timestamp =[data extractLeUInt16FromOffset: 0];
    uint32_t featureMask = [data extractBeUInt32FromOffset:2];
    uint8_t commandType = [data extractUInt8FromOffset:6];
    NSData *resp = [data subdataWithRange:NSMakeRange(7, data.length-7)];
    W2STSDKFeature *f = [mMaskToFeature objectForKey: [NSNumber numberWithUnsignedInt:featureMask]];
    [f parseCommandResponseWithTimestamp:timestamp commandType:commandType
                                       data: resp];
}

-(void)characteristicUpdate:(CBCharacteristic*)characteristics{
    
    if([characteristics isEqual: mFeatureCommand]){
        [self notifyCommandResponse: characteristics.value];
        return;
    }else if(_debugConsole!=nil &&
             [W2STSDKServiceDebug isDebugCharacteristics:characteristics]){
        [_debugConsole receiveCharacteristicsUpdate:characteristics];
        return;
    }//else
    
    NSData *newData = characteristics.value;
    NSArray *features = [W2STSDKCharacteristic getFeaturesFromChar:characteristics
                                                                in:mCharFeatureMap];
    uint32_t timestamp = [newData extractLeUInt16FromOffset: 0];
    uint32_t offset=2;
    for(W2STSDKFeature *f in features){
        offset += [f update:timestamp data:newData dataOffset:offset];
    }

}

- (void)peripheral:(CBPeripheral *)peripheral
didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error {
    
    //check if an error is notified
    if (error != nil && [error code] != 0) {
        NSLog(@"UUID: %@ Error: %@\n", characteristic.UUID.UUIDString, error);
        return ;
    }
    
    [self characteristicUpdate:characteristic];
}

- (void)peripheral:(CBPeripheral *)peripheral
didWriteValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error{
    
    if ([characteristic.UUID isEqual: [W2STSDKServiceDebug termUuid]] &&
        _debugConsole!=nil){
        [_debugConsole receiveCharacteristicsWriteUpdate:characteristic error:error];
    }
    
}

- (void)peripheral:(CBPeripheral *)peripheral
didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error{
    if(error)
        NSLog(@"Error updating the char: %@ Erorr: %@",
              characteristic.UUID.UUIDString,error.localizedDescription);
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
