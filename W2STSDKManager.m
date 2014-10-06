//
//  W2STSDKManager.m
//  W2STSDK-CB
//
//  Created by Antonino Raucea on 02/04/14.
//  Copyright (c) 2014 STMicroelectronics. All rights reserved.
//

#import "W2STSDKManager.h"

@implementation W2STSDKManager {
}
BOOL lockNodesArrays = NO;

+(W2STSDKManager *)sharedInstance {
    static W2STSDKManager *this = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        this = [[self alloc] init];
    });
    return this;
}

-(id)init {
    self = [super init];
    [W2STSDKParam initStatic];
    [W2STSDKFeature initStatic];
    
    _central = [[W2STSDKCentral alloc] init:self];
    _nodes = [[NSMutableArray alloc] init];
    _localNode = nil;
    _dataLog = nil;
    _dataLog = [[W2STSDKDataLog alloc] init];
    _dataLog.enable = YES;
    [_dataLog createNewSessionRunning:YES save:YES];
    
    _knownNodesOnly = NO;
//    _knownNodesOnly = YES;
    
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(checkDeadNodes) userInfo:nil repeats:YES];
    
    return self;
}

-(void)toggleLocalNode {
    [self actionLocalNode:(_localNode == nil)];
}

-(void)actionLocalNode:(BOOL)add {
    if (!add) {
        if (_localNode != nil) {
            [_nodes removeObject:_localNode];
            _localNode = nil;
        }
    }
    else {
        if (_localNode != nil) {
            [_nodes removeObject:_localNode];
            _localNode = nil;
        }
        _localNode = [[W2STSDKNode alloc] initAsLocal:self];
        _localNode.connectionStatus = W2STSDKNodeConnectionStatusUnknown;
        [_nodes insertObject:_localNode atIndex:0]; //insert on the top of the list
    }
}
-(void)addLocalNode {
    [self actionLocalNode:YES];
}
-(void)delLocalNode {
    [self actionLocalNode:NO];
}
-(void)checkDeadNodes {
    if (![self discoveryActive])
        return;
    
    if (lockNodesArrays) {
        return;
    }
    
    
    lockNodesArrays = YES;
    BOOL changed;
    //NSMutableArray *deadNodes = [[NSMutableArray alloc] init];
    for(W2STSDKNode *node in _nodes) {
        changed = [node checkLiveTime];
        if (changed) {
            //remove node from list
            //[deadNodes addObject:node];
            switch (node.status) {
                case W2STSDKNodeStatusDead:
                    [_delegate manager:self nodesDidChange:node what:W2STSDKNodeChangeDeadKey];
                    break;
                case W2STSDKNodeStatusResumed:
                    [_delegate manager:self nodesDidChange:node what:W2STSDKNodeChangeResumedKey];
                    break;
                case W2STSDKNodeStatusDeleted:
                    [_delegate manager:self nodesDidChange:node what:W2STSDKNodeChangeDeletedKey];
                    break;
                default:
                    //nothing
                    break;
            }
        }
    }

    lockNodesArrays = NO;
}


-(void)clear {
    if (lockNodesArrays)
        return;
    
    lockNodesArrays = YES;
    BOOL scan_condition = [_central scanActive];
    if (scan_condition)
    {
        [_central stopScan];
    }
    if (_nodes != nil) {
        for(W2STSDKNode *n in _nodes) {
            n.status = W2STSDKNodeStatusDead;
            [n reading:NO];
            [n disconnect];
        }
        [_nodes removeAllObjects];
    }
    
    if (scan_condition)
    {
        [_central startScan];
    }
    lockNodesArrays = NO;
}


/* Filter */
-(void)knownNodesOnlySet:(BOOL)value {
    _knownNodesOnly = value;
    if ([_central scanActive])
    {
        //remove all object and start again with the scan
        [self clear];
    }
}
-(void)knownNodesOnlyToggle {
    [self knownNodesOnlySet:!_knownNodesOnly];
}
/* Discovery */
-(BOOL)discoveryActive {
    return _central.scanActive;
}
-(void)discovery:(BOOL)enable {
    [_central scan:enable];
}
-(void)discoveryStart {
    [self discovery:YES];
}
-(void)discoveryStop {
    [self discovery:NO];
}
-(void)discoveryToggle {
    [_central toggleScan];
}
-(NSArray *)filteredNodes:(W2STSDKManagerFilter)filter {
    return [W2STSDKManager filteredNodesIn:_nodes filter:filter];
}
+(NSArray *)filteredNodesIn:(NSArray *)nodes filter:(W2STSDKManagerFilter)filter {
    assert(nodes != nil);
    
    //Note to improve/semplify this method we have to use the predicates
    NSArray *cacheNodes = @[]; //empty array
    BOOL (^pBlock)(id evaluatedObject, NSDictionary *bindings);
    
    if ([nodes count] > 0) {
        switch (filter) {
            case W2STSDKManagerFilterAllNodes:
                pBlock = ^BOOL(W2STSDKNode *node, NSDictionary *bindings) { return YES; };
                break;
            case W2STSDKManagerFilterConnectedOnly:
                pBlock = ^BOOL(W2STSDKNode *node, NSDictionary *bindings) { return node.connectionStatus == W2STSDKNodeConnectionStatusConnected; };
                break;
            case W2STSDKManagerFilterConnectedNo:
                pBlock = ^BOOL(W2STSDKNode *node, NSDictionary *bindings) { return node.connectionStatus != W2STSDKNodeConnectionStatusConnected; };
                break;
            case W2STSDKManagerFilterDeadOnly:
                pBlock = ^BOOL(W2STSDKNode *node, NSDictionary *bindings) { return node.status == W2STSDKNodeStatusDead; };
                break;
            case W2STSDKManagerFilterDeadNo:
                pBlock = ^BOOL(W2STSDKNode *node, NSDictionary *bindings) { return node.status != W2STSDKNodeStatusDead; };
                break;
                
        }
        cacheNodes = [nodes filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:pBlock]];
    }
    return cacheNodes;
}
+(NSInteger)indexNodeIn:(NSArray *)nodes peripheral:(CBPeripheral *)peripheral {
    assert(nodes != nil);
    W2STSDKNode *node = [W2STSDKManager nodeIn:nodes peripheral:peripheral];
    NSInteger ret = node != nil ? -1 : [nodes indexOfObject:node];
    
    return ret;
}
+(W2STSDKNode *)nodeIn:(NSArray *)nodes index:(NSUInteger)index {
    assert(nodes != nil);
    return nodes.count > 0 && index < nodes.count ? nodes[index] : nil;
}
+(W2STSDKNode *)nodeIn:(NSArray *)nodes peripheral:(CBPeripheral *)peripheral {
    assert(nodes != nil);
    
    W2STSDKNode *node_ret = nil;
    
    for(W2STSDKNode *node in nodes)
    {
        if ([node.peripheral.identifier isEqual:peripheral.identifier])
        {
            node_ret = node;
            break;
        }
    }
    return node_ret;
}
+(W2STSDKNode *)nodeIn:(NSArray *)nodes name:(NSString *)name {
    assert(nodes != nil);
    
    W2STSDKNode *node_ret = nil;
    
    for(W2STSDKNode *node in nodes)
    {
        //if ([node.peripheral.name isEqual:name])
        {
            node_ret = node;
            break;
        }
    }
    return node_ret;

}

@end
