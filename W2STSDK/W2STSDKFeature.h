//
//  W2STSDKFeature.h
//  W2STSDK-CB
//
//  Created by Antonino Raucea on 30/04/14.
//  Copyright (c) 2014 STMicroelectronics. All rights reserved.
//
#ifndef W2STApp_W2STSDKFeature_h
#define W2STApp_W2STSDKFeature_h

#import <Foundation/Foundation.h>

///////////////////////////////NEW SDK//////////////////////////////////////
@protocol W2STSDKFeatureDelegate;
@protocol W2STSDKFeatureLogDelegate;

@class W2STSDKNode;

@interface W2STSDKFeature : NSObject

@property(readonly) bool enabled;
@property (readonly,retain, nonatomic) NSString *name;
@property (readonly,retain,nonatomic) W2STSDKNode *parentNode;
@property (readonly) NSDate* lastUpdate;

-(NSString*) description;
-(void) addFeatureDelegate:(id<W2STSDKFeatureDelegate>)delegate;
-(void) removeFeatureDelegate:(id<W2STSDKFeatureDelegate>)delegate;
-(void) addFeatureLoggerDelegate:(id<W2STSDKFeatureLogDelegate>)delegate;
-(void) removeFeatureLoggerDelegate:(id<W2STSDKFeatureLogDelegate>)delegate;

//abstact method
-(id) initWhitNode: (W2STSDKNode*)node;
-(NSArray*) getFieldsData;
-(NSArray*) getFieldsDesc;
-(uint32_t) getTimestamp;

/// protected method
-(id) initWhitNode: (W2STSDKNode*)node name:(NSString*)name;
-(void) notifyUpdate;
-(void) logFeatureUpdate:(NSData*)rawData data:(NSArray*)data;
-(BOOL) sendCommand:(uint8_t)commandType data:(NSData*)commandData;
-(void) parseCommandResponseWithTimestamp:(uint32_t)timestamp
                                 commandType:(uint8_t)commandType
                                        data:(NSData*)data;
-(void)writeData:(NSData*)data;

///////package method////////////
-(void) setEnabled:(bool)enabled;
-(uint32_t) update:(uint32_t)timestamp data:(NSData*)data dataOffset:(uint32_t)offset;

@end

//Protocols definition
@protocol W2STSDKFeatureDelegate <NSObject>
@required
- (void)didUpdateFeature:(W2STSDKFeature *)feature;
@end
@protocol W2STSDKFeatureLogDelegate <NSObject>
@required
- (void)feature:(W2STSDKFeature *)feature rawData:(NSData*)raw data:(NSArray*)data;
@end

#endif

