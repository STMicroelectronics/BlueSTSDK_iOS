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

@protocol W2STSDKDataLogDelegate;

@interface W2STSDKDataLog : NSObject

#define W2STSDK_SAVE_AUTO
#define W2STSDK_SAVE_AUTO_TIME 2.5f //sec, double
//#define W2STSDK_DATALOG_AUTO

@property (retain, nonatomic) id<W2STSDKDataLogDelegate> delegate __deprecated;

@property (retain, nonatomic) W2STDBManager * dataManager __deprecated;
@property (retain, nonatomic) NSManagedObjectContext * context __deprecated;
@property (retain, nonatomic) W2STDBSession * session __deprecated;
@property (assign, nonatomic) BOOL enable __deprecated; //act on adding methods
@property (retain, nonatomic) NSDate * startTest __deprecated;
@property (retain, nonatomic) NSDate * lastSave __deprecated;

//autosave
@property (assign, nonatomic) BOOL autoSave __deprecated;
#ifdef W2STSDK_SAVE_AUTO
@property (retain, nonatomic) NSTimer * timerAutoSave __deprecated;
#endif

- (BOOL)isRunning __deprecated;
- (W2STDBSession *)createNewSessionWithSave:(BOOL)save __deprecated;
- (void)saveDB __deprecated;
- (void)closeCurrentSession __deprecated;
- (BOOL)addNode:(W2STSDKNode *)node save:(BOOL)save __deprecated;
- (BOOL)addSampleWithGroup:(NSInteger)group node:(W2STSDKNode *)node time:(NSInteger)time save:(BOOL)save __deprecated;

- (void)updateCountSamplesForNode:(W2STDBNode *)dbNode group:(NSInteger)group __deprecated;
- (void)updateCountSamplesForSession:(W2STDBSession *)dbSession group:(NSInteger)group __deprecated;
- (NSInteger)countSamplesForNode:(W2STDBNode *)dbNode group:(NSInteger)group force:(BOOL)force __deprecated;
- (NSInteger)countSamplesForSession:(W2STDBSession *)dbSession group:(NSInteger)group force:(BOOL)force __deprecated;
- (NSArray *)samplesForNode:(W2STDBNode *)node group:(NSInteger)group __deprecated;
- (NSArray *)samplesForSession:(W2STDBSession *)dbSession group:(NSInteger)group __deprecated;

- (NSArray *)sessionsWithDate:(NSDate *)date __deprecated;

- (NSString *)createLogFileWithNode:(W2STDBNode*)node session:(W2STDBSession *)dbSession sampleType:(NSString *)sampleType countSample:(NSInteger)countSample __deprecated;
- (NSArray *)createLogWithNode:(W2STDBNode *)node session:(W2STDBSession *)dbSession __deprecated;
- (NSArray *)createLogWithSession:(W2STDBSession *)dbSession __deprecated;

@end

@protocol W2STSDKDataLogDelegate <NSObject>
@required
- (void)dbNode:(W2STDBNode *)dbNode session:(W2STDBSession *)dbSession sampleType:(NSString *)sampleType perc:(NSNumber *)perc;
- (BOOL)abortingRequired;
@end
