///
/// DataManager.h
/// Tappestry
///
/// Copyright 2012 Float Mobile Learning. All Rights Reserved.
///

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "W2STDBNode.h"
#import "W2STDBSession.h"
#import "W2STDBSampleMotion.h"
#import "W2STDBSampleEnvironment.h"
#import "W2STDBSampleAHRS.h"

extern NSString * const DataManagerDidSaveNoChangeNotification;
extern NSString * const DataManagerDidSaveNotification;
extern NSString * const DataManagerDidSaveFailedNotification;


@interface W2STDBManager : NSObject {
}

@property (nonatomic, readonly, retain) NSManagedObjectModel *objectModel;
@property (nonatomic, readonly, retain) NSManagedObjectContext *mainObjectContext;
@property (nonatomic, readonly, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (W2STDBManager*)sharedInstance;
- (BOOL)save;
- (NSManagedObjectContext*)managedObjectContext;

@end
