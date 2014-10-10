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
#define W2STSDK_SAVE_AUTO_TIME 2.5f //sec, double
//#define W2STSDK_DATALOG_AUTO

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
- (void)saveDB;
- (void)closeCurrentSession;
- (BOOL)addNode:(W2STSDKNode *)node save:(BOOL)save;
- (BOOL)addSampleWithGroup:(NSInteger)group node:(W2STSDKNode *)node time:(NSInteger)time save:(BOOL)save;

- (void)updateCountSamplesForNode:(W2STDBNode *)dbNode group:(NSInteger)group;
- (void)updateCountSamplesForSession:(W2STDBSession *)dbSession group:(NSInteger)group;
- (NSInteger)countSamplesForNode:(W2STDBNode *)dbNode group:(NSInteger)group force:(BOOL)force;
- (NSInteger)countSamplesForSession:(W2STDBSession *)dbSession group:(NSInteger)group force:(BOOL)force;
- (NSArray *)samplesForNode:(W2STDBNode *)node group:(NSInteger)group;
- (NSArray *)samplesForSession:(W2STDBSession *)dbSession group:(NSInteger)group;

- (NSArray *)sessionsWithDate:(NSDate *)date;

- (NSString *)createLogFileWithNode:(W2STDBNode*)node session:(W2STDBSession *)dbSession sampleType:(NSString *)sampleType countSample:(NSInteger)countSample;
- (NSArray *)createLogWithNode:(W2STDBNode *)node session:(W2STDBSession *)dbSession;
- (NSArray *)createLogWithSession:(W2STDBSession *)dbSession;

@end
