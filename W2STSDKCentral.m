//
//  W2STSDKCentral.m
//  W2STSDK-CB
//
//  Created by Antonino Raucea on 18/03/14.
//  Copyright (c) 2014 STMicroelectronics. All rights reserved.
//

#import "W2STSDKCentral.h"

@interface W2STSDKCentral ()
@end

@implementation W2STSDKCentral {
    W2STSDKManager * _manager;
}

-(id) init:(W2STSDKManager *)manager
{
    _manager = manager;
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    [self stopScan];
    _scanActive = NO;
    return self;
}

-(void) toggleScan
{
    NSLog(@"scanning toggle");
    _scanActive == YES ? [self stopScan] : [self startScan];
        
}
-(void) scan:(BOOL)enable {
    if (enable) {
        [self startScan];
    }
    else {
        [self stopScan];
    }
}
-(void) startScan
{
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], CBCentralManagerScanOptionAllowDuplicatesKey, nil];
    //NSDictionary *options = nil;

    [_centralManager scanForPeripheralsWithServices:nil options:options];
    _scanActive = YES;
    //[_delegate central:self discoveryDidChange:_scanActive];
    [_manager.delegate manager:_manager discoveryDidChange:_scanActive];
}

-(void) stopScan
{
    [_centralManager stopScan];
    _scanActive = NO;
    //[_delegate central:self discoveryDidChange:_scanActive];
    [_manager.delegate manager:_manager discoveryDidChange:_scanActive];
}

/* Monitoring Connections with Peripherals */
//this delegate are used to associate this events to the node
//(externally the node uses a delegate to communicate a change of connection status

-   (void)centralManager:(CBCentralManager *)central
    didConnectPeripheral:(CBPeripheral *)peripheral
{
    //[W2STSDKManager trace:peripheral text:@"didConnectPeripheral"];
    [self connectionDidChange:peripheral error:nil];
}
-   (void)centralManager:(CBCentralManager *)central
 didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    //[W2STSDKManager trace:peripheral text:@"didDisconnectPeripheral"];
    [self connectionDidChange:peripheral error:error];
}
-   (void)centralManager:(CBCentralManager *)central
didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    //[W2STSDKManager trace:peripheral text:@"didFailToConnectPeripheral"];
    [self connectionDidChange:peripheral error:error];
}
-(W2STSDKNode *)connectionDidChange:(CBPeripheral *)peripheral error:(NSError *)error {
    NSArray *nodes = [_manager filteredNodes:W2STSDKManagerFilterAllNodes];
    W2STSDKNode *node = [W2STSDKManager nodeIn:nodes peripheral:peripheral];
    [node updateConnectionStatus];
    return node;
}

/* Discovering and Retrieving Peripherals */
- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI
{
//    if ([advertisementData[CBAdvertisementDataLocalNameKey] isEqualToString:@"estimote"]) {
//        return; //nothing
//    }

    //[W2STSDKManager trace:peripheral text:@"didDiscoverPeripheral"];
    BOOL exist = YES;
//    BOOL supported = YES;
    NSString *what = nil;
    NSArray *nodes = [_manager filteredNodes:W2STSDKManagerFilterAllNodes];
    W2STSDKNode *node = [W2STSDKManager nodeIn:nodes peripheral:peripheral];

    NSNumber * txPower = @1;
    if ([[advertisementData allKeys] containsObject:CBAdvertisementDataTxPowerLevelKey])
    {
        txPower = advertisementData[CBAdvertisementDataTxPowerLevelKey];
    }
    
    
    //if ([txPower  intValue] >= 1) {
        if (node == nil) {
            exist = NO;
            node = [[W2STSDKNode alloc] init:peripheral manager:_manager local:NO];
            [node updateLiveTime];
            [node updateBLEProperties:advertisementData RSSI:RSSI enableDelegate:YES];
            if (node.isSupportedBoard || _manager.knownNodesOnly == NO) {
                [_manager.nodes addObject:node];
                what = W2STSDKNodeChangeAddedKey;
                [_manager.dataLog addNode:node save:YES];
            }
        }
        else {
            [node updateLiveTime];
            [node updateRSSI:RSSI enableDelegate:YES];
            what = [W2STSDKTools nodeChangeMakeStr:W2STSDKNodeChangeUpdatedKey val:W2STSDKNodeChangeRSSIVal];
        }
    //}
    /*
    else {
        node.status = W2STSDKNodeStatusDead;
        //[_manager.nodes removeObject:node];
    }
    */
    //NSLog(@"%@", [advertisementData description]);
    [_manager.delegate manager:_manager nodesDidChange:node what:what];
}

-           (void)centralManager:(CBCentralManager *)central
 didRetrieveConnectedPeripherals:(NSArray *)peripherals
{
    [W2STSDKTools tracePeripherals:peripherals text:@"didRetrieveConnectedPeripherals"];
}
-           (void)centralManager:(CBCentralManager *)central
          didRetrievePeripherals:(NSArray *)peripherals
{
    [W2STSDKTools tracePeripherals:peripherals text:@"didRetrievePeripherals"];
}

/* Monitoring Changes to the Central Manager’s State */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    static CBCentralManagerState previousState = CBCentralManagerStateUnknown;
    
	switch ([central state]) {
		case CBCentralManagerStatePoweredOff:
		{
			break;
		}
            
		case CBCentralManagerStateUnauthorized:
		{
			/* Tell user the app is not allowed. */
			break;
		}
            
		case CBCentralManagerStateUnknown:
		{
			/* Bad news, let's wait for another event. */
			break;
		}
            
		case CBCentralManagerStatePoweredOn:
		{
			break;
		}
            
		case CBCentralManagerStateResetting:
		{
			break;
		}
            
        case CBCentralManagerStateUnsupported:
		{
            /* Bad news, let's wait for another event. */
            break;
        }
	}
    
    previousState = [central state];
}
- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)dict {
    
}

@end
