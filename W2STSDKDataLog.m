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
        [self closeCurrentSession];

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
    _session.dateStart = [NSDate date];
    _session.dateEnd = [NSDate date]; //if the session is open this is a dummy value
    _session.name = [dateFormatterName stringFromDate:_session.dateStart];
    _session.descr = [dateFormatterDescr stringFromDate:_session.dateStart];
    _session.running = [NSNumber numberWithBool:YES];
    
    //add all existings nodes
    NSArray *nodes = [[W2STSDKManager sharedInstance] nodes];
    for(W2STSDKNode * node in nodes) {
        [self addNode:node save:NO];
    }
    
    //save data
    if (save) {
        [_dataManager save];
    }
    
    //enabling logging
    _enable = YES;
    
    return _session;
}

- (void)saveDB {
    assert(_dataManager && _context);
    [_dataManager save];
}

#ifdef W2STSDK_SAVE_AUTO
- (void)autoSaveAction {
    NSTimeInterval diff = 0;
    if (_session) {
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
    else {
        //NSLog(@"Save no session");
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
        _session.dateEnd = [NSDate date];
        [self updateCountSamplesForSession:nil group:W2STSDKNodeFrameGroupAll];
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
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(identifier = %@) && (session = %@)", node.tag, _session]];
    //[fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO]]];
    NSArray *res = [_context executeFetchRequest:fetchRequest error:NULL];
    assert(res.count <= 1);
    if (res.count == 0) {
        db_node = [NSEntityDescription insertNewObjectForEntityForName:@"Node" inManagedObjectContext:_context];
        db_node.identifier = node.tag;
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


- (BOOL)addSampleWithGroup:(NSInteger)group node:(W2STSDKNode *)node time:(NSInteger)time save:(BOOL)save {
    assert(_dataManager && _context);
    if (!_enable || ![self isRunning]) {
        return NO;
    }

    assert(group == W2STSDKNodeFrameGroupMotion || group == W2STSDKNodeFrameGroupEnvironment || group == W2STSDKNodeFrameGroupAHRS);
    
    W2STSDKFeature *feature = nil;
    NSArray *values = nil;
    
    switch((W2STSDKNodeFrameGroup)group) {
        case W2STSDKNodeFrameGroupMotion:
        {
            W2STDBSampleMotion *db_item = [NSEntityDescription insertNewObjectForEntityForName:@"SampleMotion" inManagedObjectContext:_context];
            db_item.session = _session;
            db_item.node = node.dbNode;
            db_item.timeStamp = [NSDate date];
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
            
            node.dbNode.countSamplesMotion = @([node.dbNode.countSamplesMotion intValue] + 1);
        }
            break;
        case W2STSDKNodeFrameGroupEnvironment:
        {
            W2STDBSampleEnvironment *db_item = [NSEntityDescription insertNewObjectForEntityForName:@"SampleEnvironment" inManagedObjectContext:_context];
            db_item.session = _session;
            db_item.node = node.dbNode;
            db_item.timeStamp = [NSDate date];
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
            
            node.dbNode.countSamplesEnvironment = @([node.dbNode.countSamplesEnvironment intValue] + 1);
        }
            break;
        case W2STSDKNodeFrameGroupAHRS:
        {
            W2STDBSampleAHRS *db_item = [NSEntityDescription insertNewObjectForEntityForName:@"SampleAHRS" inManagedObjectContext:_context];
            db_item.session = _session;
            db_item.node = node.dbNode;
            db_item.timeStamp = [NSDate date];
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
            
            node.dbNode.countSamplesAHRS = @([node.dbNode.countSamplesAHRS intValue] + 1);
        }
            break;
        default:
            //nothing
            break;
    }
    
    return YES;
}

/*
- (BOOL)addSampleWithGroup:(NSInteger)group data:(NSData *)data node:(W2STSDKNode *)node save:(BOOL)save {
    assert(_dataManager && _context && data);
    if (!_enable || ![self isRunning]) {
        return NO;
    }
    
    const unsigned char *buffer = (const unsigned char *)[data bytes];
    //int8_t size = (int8_t)data.length;
    uint16_t time = (uint16_t)(*((uint16_t *)buffer));
    uint16_t pos = 0;
    uint32_t val = 0;
    
    uint8_t hw_map = node.hwFeatureByte;
    uint8_t sw_map = node.swFeatureByte;

     switch((W2STSDKNodeFrameGroup)group) {
        case W2STSDKNodeFrameGroupRaw:
        {
            W2STDBSampleMotion *db_item = [NSEntityDescription insertNewObjectForEntityForName:@"SampleMotion" inManagedObjectContext:_context];
            
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
            [node.dbNode addSampleMotionsObject:db_item];
            
        }
            break;
        case W2STSDKNodeFrameGroupEnvironment:
        {
            W2STDBSampleEnvironment *db_item = [NSEntityDescription insertNewObjectForEntityForName:@"SampleEnvironment" inManagedObjectContext:_context];
            
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
            [node.dbNode addSampleEnvironmentsObject:db_item];
        }
            break;
        case W2STSDKNodeFrameGroupAHRS:
        {
            W2STDBSampleAHRS *db_item = [NSEntityDescription insertNewObjectForEntityForName:@"SampleAHRS" inManagedObjectContext:_context];
            
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
            [node.dbNode addSampleAHRSsObject:db_item];
       }
            break;
        default:
            break;
    }
    //save data
    if (save) {
        [_dataManager save];
    }

    return YES;
}
 */

/**************** DB data retrieve ****************/
- (void)updateCountSamplesForNode:(W2STDBNode *)dbNode group:(NSInteger)group {
    /*
     * No using the getSamples to future optimization
     * using (if possible) a count in the query
     */
    NSArray *samples = nil;
    if ((group & W2STSDKNodeFrameGroupMotion) == W2STSDKNodeFrameGroupMotion) {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"SampleMotion"];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"node == %@", dbNode]];
        samples = [_context executeFetchRequest:fetchRequest error:NULL];
        dbNode.countSamplesMotion = [NSNumber numberWithInteger:samples.count];
        
    }
    if ((group & W2STSDKNodeFrameGroupEnvironment) == W2STSDKNodeFrameGroupEnvironment) {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"SampleEnvironment"];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"node == %@", dbNode]];
        samples = [_context executeFetchRequest:fetchRequest error:NULL];
        dbNode.countSamplesEnvironment = [NSNumber numberWithInteger:samples.count];
    }
    if ((group & W2STSDKNodeFrameGroupAHRS) == W2STSDKNodeFrameGroupAHRS) {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"SampleAHRS"];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"node == %@", dbNode]];
        samples = [_context executeFetchRequest:fetchRequest error:NULL];
        dbNode.countSamplesAHRS = [NSNumber numberWithInteger:samples.count];
    }
}
- (void)updateCountSamplesForSession:(W2STDBSession *)dbSession group:(NSInteger)group {
    W2STDBSession *s = dbSession ? dbSession : _session;
    
    if (s) {
        for(W2STDBNode * dbNode in s.nodes) {
            [self updateCountSamplesForNode:dbNode group:group];
        }
    }
    
}
- (NSInteger)countSamplesForNode:(W2STDBNode *)dbNode group:(NSInteger)group force:(BOOL)force {
    if (force) {
        [self updateCountSamplesForNode:dbNode group:group];
    }
    
    NSInteger count = 0;
    if ((group & W2STSDKNodeFrameGroupMotion) == W2STSDKNodeFrameGroupMotion) {
        count += [dbNode.countSamplesMotion integerValue];
    }
    if ((group & W2STSDKNodeFrameGroupEnvironment) == W2STSDKNodeFrameGroupEnvironment) {
        count += [dbNode.countSamplesMotion integerValue];
    }
    if ((group & W2STSDKNodeFrameGroupAHRS) == W2STSDKNodeFrameGroupAHRS) {
        count += [dbNode.countSamplesMotion integerValue];
    }
    return count;
}

- (NSInteger)countSamplesForSession:(W2STDBSession *)dbSession group:(NSInteger)group force:(BOOL)force {
    W2STDBSession *s = dbSession ? dbSession : _session;
    NSInteger count = 0;
    
    if (s) {
        for(W2STDBNode * dbNode in s.nodes) {
            count += [self countSamplesForNode:dbNode group:group force:force];
        }
    }
    
    return count;
}
- (NSArray *)samplesForNode:(W2STDBNode *)node group:(NSInteger)group {
    NSMutableArray *samples = [[NSMutableArray alloc] init];
    if ((group & W2STSDKNodeFrameGroupMotion) == W2STSDKNodeFrameGroupMotion) {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"SampleMotion"];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"node == %@", node]];
        [samples addObjectsFromArray:[_context executeFetchRequest:fetchRequest error:NULL]];
    }
    if ((group & W2STSDKNodeFrameGroupEnvironment) == W2STSDKNodeFrameGroupEnvironment) {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"SampleEnvironment"];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"node == %@", node]];
        [samples addObjectsFromArray:[_context executeFetchRequest:fetchRequest error:NULL]];
    }
    if ((group & W2STSDKNodeFrameGroupAHRS) == W2STSDKNodeFrameGroupAHRS) {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"SampleAHRS"];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"node == %@", node]];
        [samples addObjectsFromArray:[_context executeFetchRequest:fetchRequest error:NULL]];
    }
    
    return samples;
}
- (NSArray *)samplesForSession:(W2STDBSession *)dbSession group:(NSInteger)group {
    W2STDBSession *s = dbSession ? dbSession : _session;
    NSMutableArray *samples = [[NSMutableArray alloc] init];
    
    if (s) {
        for(W2STDBNode * node in s.nodes) {
            [samples addObjectsFromArray:[self samplesForNode:node group:group]];
        }
    }
    
    return samples;
}

- (NSArray *)sessionsWithDate:(NSDate *)date {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Session"];
    if (date) {
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"date == %@", date]]; //in case to filter by date
    }
    [fetchRequest setPredicate:[NSPredicate predicateWithValue:YES]];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"dateStart" ascending:NO]]];
    NSError *err;
    NSArray *ret = [_context executeFetchRequest:fetchRequest error:&err];
    return ret;
}
/**************** /////////// ****************/

/* Log */
- (NSString *) createLogFileWithNode:(W2STDBNode *)node session:(W2STDBSession *)dbSession sampleType:(NSString *)sampleType countSample:(NSInteger)countSample {
    W2STDBSession * s = dbSession ? dbSession : _session;
    assert(s);

    NSDateFormatter *df_file = [[NSDateFormatter alloc] init];
    [df_file setDateFormat:@"YYYYMMdd_HHmmss"];
    NSDateFormatter *df_header = [[NSDateFormatter alloc] init];
    [df_header setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filename = [[NSString stringWithFormat:@"%@_%@_%@", [df_file stringFromDate:s.dateStart], node.name, sampleType] stringByAppendingPathExtension:@"txt"];
    NSString *filepath = [documentsDirectory stringByAppendingPathComponent:filename ];

    if ([manager fileExistsAtPath:filepath])
        [manager removeItemAtPath:filepath error:nil];
    
    NSString *headerLog = [NSString stringWithFormat:@"Node name:%@ identifier:%@ date:%@ type:%@ samples:%ld \n",
                           node.name,
                           node.identifier,
                           [df_header stringFromDate:s.dateStart],
                           sampleType, (long)countSample];

    [headerLog  writeToFile:filepath
                 atomically:YES
                   encoding:NSUTF8StringEncoding
                      error:nil];
    
    return filepath;
}

//return an array of files with data
- (NSArray *)createLogWithNode:(W2STDBNode *)node session:(W2STDBSession *)dbSession {
    W2STDBSession * s = dbSession ? dbSession : _session;
    assert(s);
    
    NSString *filepath = @"";
    NSFileHandle * fileHandler = nil;
    NSArray *sortedSamples = nil;
    NSMutableArray *logFiles = [[NSMutableArray alloc] init];
    NSString *text = @"";
    NSSet *samples = nil;
    NSTimeInterval t=0;
    NSInteger perc = 0, perc_prev = 0;
    NSInteger count = 0;
    NSString *sampleType = @"";
    
    //NSDateFormatter *dateFormatterName = [[NSDateFormatter alloc] init];
    //[dateFormatterName setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    /**** motions ****/
    sampleType = @"motion";
    count = 0;
    perc = 0;
    perc_prev = 0;
    filepath = [self createLogFileWithNode:node session:s sampleType:sampleType countSample:[node.countSamplesMotion integerValue]];
    fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:filepath];
    [fileHandler seekToEndOfFile];
    assert(fileHandler);
    samples = [[NSSet alloc] initWithArray:[self samplesForNode:node group:W2STSDKNodeFrameGroupMotion]];
    sortedSamples = [samples sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:YES ]]];
    
    text = @"time (s), count, acc (mg), gyro (dps), magn (mGa)\n\n";
    [fileHandler writeData:[text dataUsingEncoding:NSUTF8StringEncoding]];
    text = @"time          count    ax    ay    az     gx    gy    gz     mx    my    mz\n";
    [fileHandler writeData:[text dataUsingEncoding:NSUTF8StringEncoding]];
    [self.delegate dbNode:node session:s sampleType:sampleType perc:@(perc)];

    if (![self.delegate abortingRequired]) {
        for (W2STDBSampleMotion *sample in sortedSamples) {
            t = [sample.timeStamp timeIntervalSinceDate:s.dateStart];
            text = [NSString stringWithFormat:@"%0.6f %10d %5d %5d %5d  %5d %5d %5d  %5d %5d %5d\n"
                    , t
                    , [sample.time intValue]
                    , [sample.acc_x intValue], [sample.acc_y intValue], [sample.acc_z intValue]
                    , [sample.gyr_x intValue], [sample.gyr_y intValue], [sample.gyr_z intValue]
                    , [sample.mag_x intValue], [sample.mag_y intValue], [sample.mag_z intValue]
                    ];
            [fileHandler writeData:[text dataUsingEncoding:NSUTF8StringEncoding]];
            perc_prev = perc;
            perc = (100 * count) / sortedSamples.count;
            count++;
            if ([self.delegate abortingRequired]) {
                break;
            }
            if (perc != perc_prev) {
                [self.delegate dbNode:node session:s sampleType:sampleType perc:@(perc)];
            }
        }
    }
    [fileHandler closeFile];

    if ([self.delegate abortingRequired]) {
        return nil;
    }
    
    [logFiles addObject:filepath];

    /**** environment ****/
    sampleType = @"environment";
    count = 0;
    perc = 0;
    perc_prev = 0;
    filepath = [self createLogFileWithNode:node session:s sampleType:sampleType countSample:[node.countSamplesEnvironment integerValue]];
    fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:filepath];
    [fileHandler seekToEndOfFile];
    assert(fileHandler);
    samples = [[NSSet alloc] initWithArray:[self samplesForNode:node group:W2STSDKNodeFrameGroupEnvironment]];
    sortedSamples = [samples sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:YES ]]];
    
    text = @"time (s), count, pressure (mbar), temperature (°C)\n\n";
    [fileHandler writeData:[text dataUsingEncoding:NSUTF8StringEncoding]];
    text = @"time          count  press  temp\n";
    [fileHandler writeData:[text dataUsingEncoding:NSUTF8StringEncoding]];
    [self.delegate dbNode:node session:s sampleType:sampleType perc:@(perc)];

    if (![self.delegate abortingRequired]) {
        for (W2STDBSampleEnvironment *sample in sortedSamples) {
            t = [sample.timeStamp timeIntervalSinceDate:s.dateStart];
            text = [NSString stringWithFormat:@"%0.6f %10d  %0.2f  %0.2f\n"
                    , t
                    , [sample.time intValue]
                    , [sample.pressure floatValue]
                    , [sample.temperature floatValue]
                    //, [sample.humidity floatValue]
                    ];
            [fileHandler writeData:[text dataUsingEncoding:NSUTF8StringEncoding]];
            perc_prev = perc;
            perc = (100 * count) / sortedSamples.count;
            count++;
            if ([self.delegate abortingRequired]) {
                break;
            }
            if (perc != perc_prev) {
                [self.delegate dbNode:node session:s sampleType:sampleType perc:@(perc)];
            }
        }
    }
    [fileHandler closeFile];
    
    if ([self.delegate abortingRequired]) {
        return nil;
    }
    [logFiles addObject:filepath];
    
    /**** ahrs ****/
    sampleType = @"ahrs";
    count = 0;
    perc = 0;
    perc_prev = 0;
    filepath = [self createLogFileWithNode:node session:s sampleType:sampleType countSample:[node.countSamplesAHRS integerValue]];
    fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:filepath];
    [fileHandler seekToEndOfFile];
    assert(fileHandler);
    samples = [[NSSet alloc] initWithArray:[self samplesForNode:node group:W2STSDKNodeFrameGroupAHRS]];
    sortedSamples = [samples sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:YES ]]];
    
    text = @"time (s), count, quaternions\n\n";
    [fileHandler writeData:[text dataUsingEncoding:NSUTF8StringEncoding]];
    text = @"time          count  qx      qy      qz      qw\n";
    [fileHandler writeData:[text dataUsingEncoding:NSUTF8StringEncoding]];
    [self.delegate dbNode:node session:s sampleType:sampleType perc:@(perc)];
    
    if (![self.delegate abortingRequired]) {
        for (W2STDBSampleAHRS *sample in sortedSamples) {
            t = [sample.timeStamp timeIntervalSinceDate:s.dateStart];
            text = [NSString stringWithFormat:@"%0.6f %10d  %0.5f  %0.5f  %0.5f  %0.5f\n"
                    , t
                    , [sample.time intValue]
                    , [sample.qx doubleValue]
                    , [sample.qy doubleValue]
                    , [sample.qz doubleValue]
                    , [sample.qw doubleValue]];
            [fileHandler writeData:[text dataUsingEncoding:NSUTF8StringEncoding]];
            perc_prev = perc;
            perc = (100 * count) / sortedSamples.count;
            count++;
            if ([self.delegate abortingRequired]) {
                break;
            }
            if (perc != perc_prev) {
                [self.delegate dbNode:node session:s sampleType:sampleType perc:@(perc)];
            }
        }
    }
    [fileHandler closeFile];
    
    if ([self.delegate abortingRequired]) {
        return nil;
    }
    [logFiles addObject:filepath];
    
    return logFiles;
}

- (NSArray *)createLogWithSession:(W2STDBSession *)dbSession {
    W2STDBSession * s = dbSession ? dbSession : _session;
    assert(s);
    
    NSMutableArray *logFiles = [[NSMutableArray alloc] init];
    
    NSSet *nodes = s.nodes;
    
    for (W2STDBNode *node in nodes) {
        [logFiles addObjectsFromArray:[self createLogWithNode:node session:s]];
    }

    return logFiles;
    
}

@end
