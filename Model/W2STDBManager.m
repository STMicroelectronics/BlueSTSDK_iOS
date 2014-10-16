///
/// DataManager.m
/// Tappestry
///
/// Copyright 2012 Float Mobile Learning. All Rights Reserved.
///

#import "W2STDBManager.h"
NSString * const DataManagerDidSaveNoChangeNotification = @"DataManagerDidSaveNoChangeNotification";
NSString * const DataManagerDidSaveNotification = @"DataManagerDidSaveNotification";
NSString * const DataManagerDidSaveFailedNotification = @"DataManagerDidSaveFailedNotification";

@interface W2STDBManager ()

- (NSString*)sharedDocumentsPath;

@end

@implementation W2STDBManager

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize mainObjectContext = _mainObjectContext;
@synthesize objectModel = _objectModel;

NSString * const kDataManagerBundleName = @"w2stdb";
NSString * const kDataManagerModelName = @"w2stdb";
NSString * const kDataManagerSQLiteName = @"w2stdb.sqlite";

+ (W2STDBManager*)sharedInstance {
    static dispatch_once_t pred;
    static W2STDBManager *sharedInstance = nil;
    
    dispatch_once(&pred, ^{ sharedInstance = [[self alloc] init]; });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    
    return self;
}

- (void)dealloc {
    [self save];
}

- (NSManagedObjectModel*)objectModel {
    if (_objectModel)
        return _objectModel;
    
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"W2STDBModel" withExtension:@"momd"];
    _objectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _objectModel;
}



- (NSPersistentStoreCoordinator*)persistentStoreCoordinator {
    
    if (_persistentStoreCoordinator)
        return _persistentStoreCoordinator;
    
    // Get the paths to the SQLite file
    NSString *storePath = [[self sharedDocumentsPath] stringByAppendingPathComponent:kDataManagerSQLiteName];
    NSURL *storeURL = [NSURL fileURLWithPath:storePath];
    
    // Define the Core Data version migration options
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                             nil];
    
    // Attempt to load the persistent store
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.objectModel];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:storeURL
                                                         options:options
                                                           error:&error]) {
        NSLog(@"Fatal error while creating persistent store: %@", error);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext*)mainObjectContext {
    if (_mainObjectContext)
        return _mainObjectContext;

    // Create the main context only on the main thread
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(mainObjectContext)
                               withObject:nil
                            waitUntilDone:YES];
        return _mainObjectContext;
    }
    
    _mainObjectContext = [[NSManagedObjectContext alloc] init];
    [_mainObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    
    return _mainObjectContext;
}

- (BOOL)save {
    BOOL ret  = YES;
    NSError *error = nil;
    NSString *postnotname = DataManagerDidSaveNoChangeNotification;
    
    if ([self.mainObjectContext hasChanges]) {
        if (![self.mainObjectContext save:&error]) {
            NSLog(@"Error while saving: %@\n%@", [error localizedDescription], [error userInfo]);
            ret = NO;
            postnotname = DataManagerDidSaveFailedNotification;
        }
        else {
            error = nil;
            postnotname = DataManagerDidSaveNotification;
        }
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:postnotname object:error];

    return ret;
}

- (NSString*)sharedDocumentsPath {
    static NSString *SharedDocumentsPath = nil;
    if (SharedDocumentsPath)
        return SharedDocumentsPath;
    
    // Compose a path to the <Library>/Database directory
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    SharedDocumentsPath = [libraryPath stringByAppendingPathComponent:@"Database"];
    
    // Ensure the database directory exists
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL isDirectory;
    if (![manager fileExistsAtPath:SharedDocumentsPath isDirectory:&isDirectory] || !isDirectory) {
        NSError *error = nil;
        NSDictionary *attr = [NSDictionary dictionaryWithObject:NSFileProtectionComplete
                                                         forKey:NSFileProtectionKey];
        [manager createDirectoryAtPath:SharedDocumentsPath
           withIntermediateDirectories:YES
                            attributes:attr
                                 error:&error];
        if (error)
            NSLog(@"Error creating directory path: %@", [error localizedDescription]);
    }
    
    return SharedDocumentsPath;
}

- (NSManagedObjectContext*)managedObjectContext {
    NSManagedObjectContext *ctx = [[NSManagedObjectContext alloc] init] ;
    [ctx setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    
    return ctx;
}

@end
