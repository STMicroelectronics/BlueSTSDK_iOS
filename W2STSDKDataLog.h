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

#define W2STSDK_SAVE_AUTO
#define W2STSDK_SAVE_AUTO_TIME 1.0f //sec, double
#define W2STSDK_DATALOG_AUTO

@property (retain, nonatomic) W2STDBManager * dataManager;
@property (retain, nonatomic) NSManagedObjectContext * context;
@property (retain, nonatomic) W2STDBSession * session;
@property (assign, nonatomic) BOOL enable; //act on adding methods
@property (retain, nonatomic) NSDate * startTest;
@property (retain, nonatomic) NSDate * lastSave;

//autosave
@property (assign, nonatomic) BOOL autoSave;
#ifdef W2STSDK_SAVE_AUTO
@property (retain, nonatomic) NSTimer * timerAutoSave;
#endif

- (BOOL)isRunning;
- (W2STDBSession *)createNewSessionWithSave:(BOOL)save;
- (void)saveCurrentSession;
- (void)closeCurrentSession;
- (BOOL)addNode:(W2STSDKNode *)node save:(BOOL)save;
- (BOOL)addDataTestSampleWithNode:(W2STSDKNode *)node;
- (BOOL)addDataWithGroup:(NSInteger)group node:(W2STSDKNode *)node time:(NSInteger)time save:(BOOL)save;

- (BOOL)addRawDataWithGroup:(NSInteger)group data:(NSData *)data node:(W2STSDKNode *)node save:(BOOL)save;

- (NSString *) createLogFile:(NSString*)identifier session:(W2STDBSession *)session sampleType:(NSString *)sampleType;
- (NSArray *)createLogWithNode:(W2STDBNode *)node session:(W2STDBSession *)session;
- (NSArray *)createLogWithSession:(W2STDBSession *)session;

@end
