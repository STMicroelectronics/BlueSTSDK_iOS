//
//  W2STSDKDataLog.m
//  W2STApp
//
//  Created by Antonino Raucea on 09/09/14.
//  Copyright (c) 2014 STMicroelectronics. All rights reserved.
//

#import "W2STSDKDataLog.h"


@implementation W2STSDKDataLog


- (id)init {
    self = [super init];
    _enable = NO;

    _dataManager = [W2STDBManager sharedInstance];
    _context = [_dataManager mainObjectContext];

    
    _startTest = [NSDate date];

#ifdef W2STSDK_DATALOG_AUTO
    [self createNewSessionWithSave:YES];
#endif

#ifdef W2STSDK_SAVE_AUTO
    //if the autosave is available then it is enable
    self.autoSave = YES;
#else
    self.autoSave = NO;
#endif
    
    assert(_dataManager && _context);
    
    return self;
}

- (BOOL)isRunning {
    return _session && [_session.running boolValue];
}

- (void)setEnable:(BOOL)enable {
    if (_enable != enable) {
        _enable = enable; //apply before to enable the autoSave

#ifdef W2STSDK_SAVE_AUTO
        if (enable) {
            //start timer according to the auto save
            [self setAutoSaveTimerWith:_autoSave];
        }
        else {
            //disabling timer
            [self setAutoSaveTimerWith:NO];
        }
#endif
     }
}

- (BOOL)getAutoSave {
    return _enable ? _autoSave : NO;
}

- (void)setAutoSave:(BOOL)autoSave {
    _autoSave = autoSave;
#ifdef W2STSDK_SAVE_AUTO
    [self setAutoSaveTimerWith:autoSave];
#endif
}

#ifdef W2STSDK_SAVE_AUTO
- (void)setAutoSaveTimerWith:(BOOL)autoSave {
    if (autoSave) {
        if (_timerAutoSave) {
            [_timerAutoSave invalidate];
        }
        _timerAutoSave = [NSTimer scheduledTimerWithTimeInterval:W2STSDK_SAVE_AUTO_TIME target:self selector:@selector(autoSaveAction) userInfo:nil repeats:YES];
    }
    else {
        [_timerAutoSave invalidate];
        _timerAutoSave = nil;
    }
}
#endif


- (W2STDBSession *)createNewSessionWithSave:(BOOL)save {
    assert(_dataManager && _context);
    
    //log: session closing check if a session is available and is not closed, then close it
    [self closeCurrentSession];
    
    //log: session init
    _session = [NSEntityDescription insertNewObjectForEntityForName:@"Session" inManagedObjectContext:_context];
    assert(_session);

    //log: session insert time stamp
    NSDateFormatter *dateFormatterName = [[NSDateFormatter alloc] init];
    [dateFormatterName setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDateFormatter *dateFormatterDescr = [[NSDateFormatter alloc] init];
    [dateFormatterDescr setDateStyle:NSDateFormatterLongStyle];
    [dateFormatterDescr setTimeStyle:NSDateFormatterLongStyle];
    
    //initialize the fields
    _session.date_start = [NSDate date];
    _session.date_end = [NSDate date]; //if the session is open this is a dummy value
    _session.name = [dateFormatterName stringFromDate:_session.date_start];
    _session.descr = [dateFormatterDescr stringFromDate:_session.date_start];
    _session.running = [NSNumber numberWithBool:YES];
    
    //save data
    if (save) {
        [_dataManager save];
    }
    
    //enabling logging
    _enable = YES;
    
    return _session;
}

- (void)saveCurrentSession {
    assert(_dataManager && _context);
    [_dataManager save];
}

#ifdef W2STSDK_SAVE_AUTO
- (void)autoSaveAction {
    NSTimeInterval diff = 0;
    if (_autoSave) {
        BOOL res = [_dataManager save];
        if (res) {
            NSDate *prevSave = self.lastSave;
            self.lastSave = [NSDate date];
            diff = [self.lastSave timeIntervalSinceDate:prevSave];
        }
        self.autoSave = YES; //reset the timer
        NSLog(@"Save result %@ lastSave (%f) %@ ", (res ? @"OK" : @"NO"), diff, [self.lastSave description]);
    }
    else {
        self.autoSave = NO; //invalidate the timer
    }
}
#endif

- (void)closeCurrentSession {
    assert(_dataManager && _context);

    if (!_session) {
        return;
    }

    if ([self isRunning]) {
        _session.running = [NSNumber numberWithBool:NO];
        _session.date_end = [NSDate date];
        
    }

    //save data
    [_dataManager save];
    _session = nil;
    
}

- (bool)delNode:(W2STSDKNode *)node save:(BOOL)save {
    assert(_dataManager && _context && node);
    
    if (!_enable || ![self isRunning] || !node.dbNode) {
        return NO;
    }
    
    BOOL ret = NO;
    W2STDBNode *db_node = node.dbNode;
    
    [_context deleteObject:db_node];
    NSLog(@"Deleted:\n. %@\n.", db_node);
    
    //save data
    if (save) {
        [_dataManager save];
    }
    return ret;
}
- (bool)delAllNodesWithSave:(BOOL)save {
    assert(_dataManager && _context);
    
    if (!_enable || ![self isRunning]) {
        return NO;
    }
    
    BOOL ret = NO;
    [NSEntityDescription  insertNewObjectForEntityForName:@"Node" inManagedObjectContext:_context];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Node"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"session = %@", _session]];
    NSError *error = nil;
    NSArray *entityObjects = [_context executeFetchRequest:fetchRequest error:&error];
    
    NSLog(@"Deleted:");
    for (W2STDBNode *db_node in entityObjects) {
        [_context deleteObject:db_node];
        NSLog(@". %@", db_node);
    }
    NSLog(@".\n");
    
    //save data
    if (save) {
        [_dataManager save];
    }
    return ret;
}

- (BOOL)addNode:(W2STSDKNode *)node save:(BOOL)save {
    assert(_dataManager && _context && node);

    if (!_enable || ![self isRunning]) {
        return NO;
    }

    W2STDBNode *db_node = nil;
    BOOL ret = NO;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Node"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(identifier = %@) && (session = %@)", [node UUIDGetString], _session]];
    //[fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO]]];
    NSArray *res = [_context executeFetchRequest:fetchRequest error:NULL];
    assert(res.count <= 1);
    if (res.count == 0) {
        db_node = [NSEntityDescription insertNewObjectForEntityForName:@"Node" inManagedObjectContext:_context];
        db_node.identifier = [node UUIDGetString];
        ret = YES;    }
    else {
        //update fields
        db_node = res[0];
    }
    db_node.name = node.name;
    db_node.boardName = node.nameBoardGetString;
    db_node.feature = [NSNumber numberWithInt:node.featureByte];
    node.dbNode = db_node; //store db_node inside node item
    
    //log: add node to session
    if (![_session.nodes containsObject:db_node]) {
        [_session addNodesObject:db_node];
    }
    
    //log: add session to node
    db_node.session = _session;
    
    //save data
    if (save) {
        [_dataManager save];
    }
    return ret;
}

- (BOOL)addDataTestSampleWithNode:(W2STSDKNode *)node {
    W2STDBRawDataEnvironment *db_item = [NSEntityDescription insertNewObjectForEntityForName:@"RawDataEnvironment" inManagedObjectContext:_context];
    
    NSInteger time = (NSInteger)([[NSDate date] timeIntervalSinceDate:_startTest] * 1000.0f) % 65536;
    db_item.time = [NSNumber numberWithInteger:time];
    db_item.pressure = [NSNumber numberWithInteger:((time % 100) + 1000)];
    db_item.temperature = [NSNumber numberWithInteger:((time % 100) + 2000)];
    db_item.humidity = [NSNumber numberWithInteger:((time % 100) + 3000)];
    
    //store relationship info
    db_item.node = node.dbNode;
    //[node.dbNode addRawDataEnvironmentsObject:db_item];
    
    return YES;
}

- (BOOL)addDataWithGroup:(NSInteger)group node:(W2STSDKNode *)node time:(NSInteger)time save:(BOOL)save {
    assert(_dataManager && _context);
    if (!_enable || ![self isRunning]) {
        return NO;
    }
    
    W2STSDKFeature *feature = nil;
    W2STSDKParam *param = nil;
    NSArray *values = nil;
    
    switch((W2STSDKNodeFrameGroup)group) {
        case W2STSDKNodeFrameGroupRaw:
        {
            W2STDBRawDataMotion *db_item = [NSEntityDescription insertNewObjectForEntityForName:@"RawDataMotion" inManagedObjectContext:_context];
            db_item.time = [NSNumber numberWithInteger:time];
            
            feature = [node featureWithKey:W2STSDKNodeFeatureHWAccelerometerKey];
            if (feature) {
                values = [feature arrayValues:NO];
                assert(values.count == 3);
                db_item.acc_x = values[0];
                db_item.acc_y = values[1];
                db_item.acc_z = values[2];
            }
            feature = [node featureWithKey:W2STSDKNodeFeatureHWGyroscopeKey];
            if (feature) {
                values = [feature arrayValues:NO];
                assert(values.count == 3);
                db_item.gyr_x = values[0];
                db_item.gyr_y = values[1];
                db_item.gyr_z = values[2];
            }
            feature = [node featureWithKey:W2STSDKNodeFeatureHWMagnetometerKey];
            if (feature) {
                values = [feature arrayValues:NO];
                assert(values.count == 3);
                db_item.mag_x = values[0];
                db_item.mag_y = values[1];
                db_item.mag_z = values[2];
            }
            
            //store relationship info
            db_item.node = node.dbNode;
            //[node.dbNode addRawDataMotionsObject:db_item];
        }
            break;
        case W2STSDKNodeFrameGroupEnvironment:
        {
            W2STDBRawDataEnvironment *db_item = [NSEntityDescription insertNewObjectForEntityForName:@"RawDataEnvironment" inManagedObjectContext:_context];
            db_item.time = [NSNumber numberWithInteger:time];

            feature = [node featureWithKey:W2STSDKNodeFeatureHWPressureKey];
            if (feature) {
                db_item.pressure = [[feature paramAtIndex:0] numberValue:NO];
            }
            feature = [node featureWithKey:W2STSDKNodeFeatureHWTemperatureKey];
            if (feature) {
                db_item.temperature = [[feature paramAtIndex:0] numberValue:NO];
            }
            feature = [node featureWithKey:W2STSDKNodeFeatureHWHumidityKey];
            if (feature) {
                db_item.humidity = [[feature paramAtIndex:0] numberValue:NO];
            }
            
            //store relationship info
            db_item.node = node.dbNode;
            //[node.dbNode addRawDataEnvironmentsObject:db_item];
        }
            break;
        case W2STSDKNodeFrameGroupAHRS:
        {
            W2STDBRawDataAHRS *db_item = [NSEntityDescription insertNewObjectForEntityForName:@"RawDataAHRS" inManagedObjectContext:_context];
            db_item.time = [NSNumber numberWithInteger:time];
            feature = [node featureWithKey:W2STSDKNodeFeatureSWAHRSKey];
            if (feature) {
                values = [feature arrayValues:NO];
                assert(values.count == 4);
                db_item.qx = [[feature paramAtIndex:0] numberValue:NO];
                db_item.qy = [[feature paramAtIndex:1] numberValue:NO];
                db_item.qz = [[feature paramAtIndex:2] numberValue:NO];
                db_item.qw = [[feature paramAtIndex:3] numberValue:NO];
            }
            
            //store relationship info
            db_item.node = node.dbNode;
            //[node.dbNode addRawDataAHRSsObject:db_item];
        }
            break;
        default:
            //nothing
            break;
    }
    
    return YES;
}

- (BOOL)addRawDataWithGroup:(NSInteger)group data:(NSData *)data node:(W2STSDKNode *)node save:(BOOL)save {
    assert(_dataManager && _context && data);
    if (!_enable || ![self isRunning]) {
        return NO;
    }
    
    return YES;
    
    const unsigned char *buffer = (const unsigned char *)[data bytes];
    //int8_t size = (int8_t)data.length;
    uint16_t time = (uint16_t)(*((uint16_t *)buffer));
    uint16_t pos = 0;
    uint32_t val = 0;
    
    uint8_t hw_map = node.hwFeatureByte;
    uint8_t sw_map = node.swFeatureByte;
/*
    switch((W2STSDKNodeFrameGroup)group) {
        case W2STSDKNodeFrameGroupRaw:
        {
            W2STDBRawDataMotion *db_item = [NSEntityDescription insertNewObjectForEntityForName:@"RawDataMotion" inManagedObjectContext:_context];
            
            db_item.time = [NSNumber numberWithUnsignedInt:time]; pos+=2; //save time
            if (hw_map & (W2STSDKNodeFeatureHWAcce & 0xFF)) {
                ;
                db_item.acc_x = [NSNumber numberWithUnsignedInt:(val = buffer[pos+0] + (buffer[pos+1]<<8))];
                db_item.acc_y = [NSNumber numberWithUnsignedInt:(val = buffer[pos+2] + (buffer[pos+3]<<8))];
                db_item.acc_z = [NSNumber numberWithUnsignedInt:(val = buffer[pos+4] + (buffer[pos+5]<<8))];
                pos += 6;
            }
            if (hw_map & (W2STSDKNodeFeatureHWGyro & 0xFF)) {
                db_item.gyr_x = [NSNumber numberWithUnsignedInt:(val = buffer[pos+0] + (buffer[pos+1]<<8))];
                db_item.gyr_y = [NSNumber numberWithUnsignedInt:(val = buffer[pos+2] + (buffer[pos+3]<<8))];
                db_item.gyr_z = [NSNumber numberWithUnsignedInt:(val = buffer[pos+4] + (buffer[pos+5]<<8))];
                pos += 6;
            }
            if (hw_map & (W2STSDKNodeFeatureHWMagn & 0xFF)) {
                db_item.mag_x = [NSNumber numberWithUnsignedInt:(val = buffer[pos+0] + (buffer[pos+1]<<8))];
                db_item.mag_y = [NSNumber numberWithUnsignedInt:(val = buffer[pos+2] + (buffer[pos+3]<<8))];
                db_item.mag_z = [NSNumber numberWithUnsignedInt:(val = buffer[pos+4] + (buffer[pos+5]<<8))];
                pos += 6;
            }
            
            //store relationship info
            db_item.node = node.dbNode;
            [node.dbNode addRawDataMotionsObject:db_item];
            
        }
            break;
        case W2STSDKNodeFrameGroupEnvironment:
        {
            W2STDBRawDataEnvironment *db_item = [NSEntityDescription insertNewObjectForEntityForName:@"RawDataEnvironment" inManagedObjectContext:_context];
            
            db_item.time = time; pos+=2; //save time
            if (hw_map & (W2STSDKNodeFeatureHWPres & 0xFF)) {
                db_item.pressure = (uint32_t)(*((uint32_t *)&buffer[pos])); pos += 4;
            }
            if (hw_map & (W2STSDKNodeFeatureHWTemp & 0xFF)) {
                db_item.temperature = (uint16_t)(*((uint16_t *)&buffer[pos])); pos += 2;
            }
            if (hw_map & (W2STSDKNodeFeatureHWHumd & 0xFF)) {
                db_item.humidity = (uint16_t)(*((uint16_t *)&buffer[pos])); pos += 2;
            }
            
            //store relationship info
            db_item.node = node.dbNode;
            [node.dbNode addRawDataEnvironmentsObject:db_item];
        }
            break;
        case W2STSDKNodeFrameGroupAHRS:
        {
            W2STDBRawDataAHRS *db_item = [NSEntityDescription insertNewObjectForEntityForName:@"RawDataAHRS" inManagedObjectContext:_context];
            
            db_item.time = time; pos+=2; //save time
            if (sw_map & (W2STSDKNodeFeatureSWAHRS & 0xFF)) {
                db_item.qx = (uint32_t)(*((uint32_t *)&buffer[pos])); 
                db_item.qy = (uint32_t)(*((uint32_t *)&buffer[pos])); 
                db_item.qz = (uint32_t)(*((uint32_t *)&buffer[pos])); 
                db_item.qw = (uint32_t)(*((uint32_t *)&buffer[pos]));
                pos += 16;
            }
            
            //store relationship info
            db_item.node = node.dbNode;
            [node.dbNode addRawDataAHRSsObject:db_item];
       }
            break;
        default:
            break;
    }
    */
    //save data
    if (save) {
        [_dataManager save];
    }

    return YES;
}

/* Log */
- (NSString *) createLogFile:(NSString*)identifier session:(W2STDBSession *)session sampleType:(NSString *)sampleType {
    W2STDBSession * s = session ? session : _session;
    assert(s);

    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"YYYYMMDD-HHmmss"];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filename = [[NSString stringWithFormat:@"%@-%@-%@", [df stringFromDate:s.date_start], identifier, sampleType] stringByAppendingPathExtension:@"txt"];
    NSString *filepath = [documentsDirectory stringByAppendingPathComponent:filename ];

    if ([manager fileExistsAtPath:filepath])
        [manager removeItemAtPath:filepath error:nil];
    
    [[NSString stringWithFormat:@"Log file for node %@ date %@ type %@\n\n", identifier, [s.date_start description], sampleType]
                writeToFile:filepath
                 atomically:YES
                   encoding:NSUTF8StringEncoding
                      error:nil];
    
    return filepath;
}

//return an array of files with data
- (NSArray *)createLogWithNode:(W2STDBNode *)node session:(W2STDBSession *)session {
    W2STDBSession * s = session ? session : _session;
    assert(s);
    
    NSString *filepath = @"";
    NSFileHandle * fileHandler = nil;
    NSArray *sortedSamples = nil;
    NSMutableArray *logFiles = [[NSMutableArray alloc] init];
    NSString *text = @"";
    NSSet *samples = nil;
    
    /**** motions ****/
    filepath = [self createLogFile:node.identifier session:s sampleType:@"motion"];
    fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:filepath];
    [fileHandler seekToEndOfFile];
    assert(fileHandler);
    samples = [[NSSet alloc] init];
    //samples = node.rawDataMotions;
    //query missing
    sortedSamples = [samples sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"time" ascending:YES ]]];
    
    for (W2STDBRawDataMotion *sample in sortedSamples) {
        text = [NSString stringWithFormat:@"%7d - %5d %5d %5d  %5d %5d %5d  %5d %5d %5d\n"
                , sample.time
                , sample.acc_x, sample.acc_y, sample.acc_z
                , sample.gyr_x, sample.gyr_y, sample.gyr_z
                , sample.mag_x, sample.mag_y, sample.mag_z
                ];
        [fileHandler writeData:[text dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [fileHandler closeFile];
    [logFiles addObject:filepath];

    /**** environment ****/
    filepath = [self createLogFile:node.identifier session:s sampleType:@"environment"];
    fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:filepath];
    [fileHandler seekToEndOfFile];
    assert(fileHandler);
    //samples = node.rawDataEnvironments;
    //query missing
    sortedSamples = [samples sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"time" ascending:YES ]]];
    
    for (W2STDBRawDataEnvironment *sample in sortedSamples) {
        text = [NSString stringWithFormat:@"%7d - %5d %5d\n", sample.time, sample.pressure, sample.temperature];
        [fileHandler writeData:[text dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [fileHandler closeFile];
    [logFiles addObject:filepath];
    
    /**** ahrs ****/
    filepath = [self createLogFile:node.identifier session:s sampleType:@"ahrs"];
    fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:filepath];
    [fileHandler seekToEndOfFile];
    assert(fileHandler);
    //samples = node.rawDataAHRSs;
    //query missing
    sortedSamples = [samples sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"time" ascending:YES ]]];
    
    for (W2STDBRawDataAHRS *sample in sortedSamples) {
        text = [NSString stringWithFormat:@"%7d - %5d %5d %5d %5d\n", sample.time, sample.qx, sample.qy, sample.qz, sample.qw];
        [fileHandler writeData:[text dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [fileHandler closeFile];
    [logFiles addObject:filepath];
    
    return logFiles;
}

- (NSArray *)createLogWithSession:(W2STDBSession *)session {
    W2STDBSession * s = session ? session : _session;
    assert(s);
    
    NSMutableArray *logFiles = [[NSMutableArray alloc] init];
    
    NSSet *nodes = s.nodes;
    
    for (W2STDBNode *node in nodes) {
        [logFiles addObjectsFromArray:[self createLogWithNode:node session:s]];
    }

    return logFiles;
    
}

@end
