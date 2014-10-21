//
//  W2STSDKManager.h
//  W2STSDK-CB
//
//  Created by Antonino Raucea on 02/04/14.
//  Copyright (c) 2014 STMicroelectronics. All rights reserved.
//

#import "W2STSDKDefine.h"


@class W2STSDKCentral;
@class W2STSDKDataLog;

typedef NS_ENUM(NSInteger, W2STSDKManagerFilter) {
    W2STSDKManagerFilterAllNodes         = 0,
    W2STSDKManagerFilterConnectedOnly    = 1,
    W2STSDKManagerFilterConnectedNo      = 2,
    W2STSDKManagerFilterDeadOnly         = 3,
    W2STSDKManagerFilterDeadNo           = 4,
};



@protocol W2STSDKManagerDelegate;

@interface W2STSDKManager : NSObject

@property (retain, nonatomic) W2STSDKDataLog * dataLog;
@property (retain, nonatomic) NSMutableArray * nodes;
@property (retain, nonatomic) W2STSDKNode * localNode;
@property (retain, nonatomic) W2STSDKCentral * central; //private
@property (assign, nonatomic, readonly) BOOL knownNodesOnly;

@property (retain, nonatomic) id<W2STSDKManagerDelegate> delegate;

-(void)clear;
-(void)knownNodesOnlySet:(BOOL)value;
-(void)knownNodesOnlyToggle;

-(BOOL)discoveryActive;
-(void)discovery:(BOOL)enable;
-(void)discoveryStart;
-(void)discoveryStop;
-(void)discoveryToggle;

-(void)toggleLocalNode;
-(void)actionLocalNode:(BOOL)add;
-(void)addLocalNode;
-(void)delLocalNode;

-(NSArray *)filteredNodes:(W2STSDKManagerFilter)filter;
-(W2STSDKNode *)nodeWithName:(NSString *)name;

//to avoid misconfiguration we prefere to export a method to filter the nodes
//and static methods to manage them
//-(NSUInteger)nodesCountWithFilter:(W2STSDKManagerFilter)filterCondition;
//-(NSInteger)findIndexByPeripheral:(CBPeripheral *)peripheral filter:(W2STSDKManagerFilter)filterCondition;
//-(W2STSDKNode *)findNodeByPeripheral:(CBPeripheral *)peripheral filter:(W2STSDKManagerFilter)filterCondition;

+(NSArray *)filteredNodesIn:(NSArray *)nodes filter:(W2STSDKManagerFilter)filter;
+(NSInteger)indexNodeIn:(NSArray *)nodes peripheral:(CBPeripheral *)peripheral;
+(W2STSDKNode *)nodeIn:(NSArray *)nodes index:(NSUInteger)index;
+(W2STSDKNode *)nodeIn:(NSArray *)nodes peripheral:(CBPeripheral *)peripheral;
+(W2STSDKNode *)nodeIn:(NSArray *)nodes name:(NSString *)name;

+ (W2STSDKManager *)sharedInstance;
@end

//protocol
@protocol W2STSDKManagerDelegate <NSObject>
@required
- (void)manager:(W2STSDKManager *)manager nodesDidChange:(W2STSDKNode *)node what:(NSString *)what; //W2STSDKManagerNodeChange...
- (void)manager:(W2STSDKManager *)manager discoveryDidChange:(BOOL)discovery;


@end