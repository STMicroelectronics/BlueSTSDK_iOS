//
//  W2STSDKCentral.h
//  W2STSDK-CB
//
//  Created by Antonino Raucea on 18/03/14.
//  Copyright (c) 2014 STMicroelectronics. All rights reserved.
//

#import "W2STSDKDefine.h"

@protocol W2STSDKCentralDelegate;
@class W2STSDKManager;

@interface W2STSDKCentral : NSObject <CBCentralManagerDelegate>

/*!
 *  @property delegate
 *
 *  @discussion The delegate object that will receive central events.
 *
 */
//@property (retain, nonatomic) id<W2STSDKCentralDelegate> delegate;

@property (retain, nonatomic) CBCentralManager * centralManager;
@property (readonly) BOOL scanActive;

-(id) init:(W2STSDKManager *)manager;
-(void) scan:(BOOL)enable;
-(void)toggleScan;
-(void)startScan;
-(void)stopScan;

@end

//protocol
/*
@protocol W2STSDKCentralDelegate <NSObject>
@required
- (void) central:(W2STSDKCentral *)central nodeDidDiscover:(BOOL)discovery;
@end
*/