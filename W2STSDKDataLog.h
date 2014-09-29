//
//  W2STSDKDataLog.h
//  W2STApp
//
//  Created by Antonino Raucea on 09/09/14.
//  Copyright (c) 2014 STMicroelectronics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "W2STDBManager.h"
#import "W2STSDK.h"

@interface W2STSDKDataLog : NSObject

@property (retain, nonatomic) W2STDBManager * dataManager;
@property (retain, nonatomic) NSManagedObjectContext * context;
@property (retain, nonatomic) W2STDBSession * session;

- (BOOL)isRunning;
- (W2STDBSession *)createNewSessionRunning:(BOOL)running save:(BOOL)save;
- (void)closeCurrentSessionSave:(BOOL)save;
- (bool)addNode:(W2STSDKNode *)node save:(BOOL)save;
- (bool)addRawDataWithGroup:(NSInteger)group data:(NSData *)data node:(W2STSDKNode *)node save:(BOOL)save;

@end
