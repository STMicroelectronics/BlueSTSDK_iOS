/*******************************************************************************
 * COPYRIGHT(c) 2015 STMicroelectronics
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *   1. Redistributions of source code must retain the above copyright notice,
 *      this list of conditions and the following disclaimer.
 *   2. Redistributions in binary form must reproduce the above copyright notice,
 *      this list of conditions and the following disclaimer in the documentation
 *      and/or other materials provided with the distribution.
 *   3. Neither the name of STMicroelectronics nor the names of its contributors
 *      may be used to endorse or promote products derived from this software
 *      without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 ******************************************************************************/

#import "BlueSTSDKFeatureLogCSV.h"
#import "BlueSTSDKNode.h"
#import "BlueSTSDK_LocalizeUtil.h"

#import "../Features/BlueSTSDKFeatureField.h"


@implementation BlueSTSDKFeatureLogCSV{
    /**
     *  dictionary where we store the pair BlueSTSDKFeature/NSFileHandle for be able
     * to use the same log with multiple feature
     */
    NSMutableDictionary *mCacheFileHandler;
    NSDateFormatter *mDateFormatter;
    NSArray *mNodes;
}

+(instancetype)loggerWithNodes:(NSArray *)nodes{
    return [[BlueSTSDKFeatureLogCSV alloc] initWithTimestamp:nil nodes:nodes];
}
+(instancetype)loggerWithTimestamp:(NSDate *)timestamp nodes:(NSArray *)nodes{
    return [[BlueSTSDKFeatureLogCSV alloc] initWithTimestamp:timestamp nodes:nodes];
}
+(instancetype)logger {
    return [[BlueSTSDKFeatureLogCSV alloc] init];
}

-(instancetype)initWithTimestamp:(NSDate *)timestamp nodes:(NSArray *)nodes{
    self = [super init];
    mCacheFileHandler = [NSMutableDictionary dictionary];
    _startupTimestamp = timestamp ? timestamp : [NSDate date];
    mDateFormatter = [[NSDateFormatter alloc] init];
    [mDateFormatter setDateFormat:@"yyyyMMdd_HHmmss"];
    mNodes = nodes;
    
    return self;
}

/**
 *  print the csv header: node name + time stamp + raw data + data type 
 * exported by the feature
 *
 *  @param out handle where write the data
 *  @param f   feature that we will log in the file
 */
-(void) printHeader:(NSFileHandle*)out feature:(BlueSTSDKFeature*)f{
    NSArray *fields = [f getFieldsDesc];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
    
    NSMutableString *line = [NSMutableString stringWithString:BLUESTSDK_LOCALIZE(@"Logged started on,",nil)];
    [line appendString:[dateFormatter stringFromDate:self.startupTimestamp]];
    [line appendString:BLUESTSDK_LOCALIZE(@"\nFeature,",nil)];
    [line appendString:f.name];
    [line appendString:BLUESTSDK_LOCALIZE(@"\nNodes",nil)];
    for (BlueSTSDKNode *node in mNodes){
        [line appendString:@","];
        [line appendString:node.friendlyName];
    }
    [line appendString:@"\n\n"];
    
    [line appendString:BLUESTSDK_LOCALIZE(@"Date,HostTimestamp,NodeName,NodeTimestamp,RawData",nil)];
    for (BlueSTSDKFeatureField *field in fields){
        [line appendString:@","];
        if([field hasUnit]) {
            [line appendString: [NSString stringWithFormat:@"%@ (%@)", field.name, field.unit]];
        } else{
            [line appendString:field.name];
        }
    }
    [line appendString:@"\n"];
    
    [out writeData: [line dataUsingEncoding:NSUTF8StringEncoding]];
}//printHeader

NSString *stringBlobData(NSData *data) {
    NSMutableString *temp = [NSMutableString string];
    //for each block in the data append the exadecimal value to the string
    [data enumerateByteRangesUsingBlock:^(const void *bytes,
                                          NSRange byteRange,
                                          BOOL *stop) {
        for (NSUInteger i = 0; i < byteRange.length; ++i) {
            [temp appendFormat:@"%02X", ((uint8_t*)bytes)[i]];
        }//for
    }];
    return temp;
}

/**
 *  print an array of byte in a exadecimal format
 *
 *  @param out  file where write the data
 *  @param data array of byte to write
 */
+(void) storeBlobData:(NSFileHandle*)out data:(NSData*)data{
    NSString *temp = stringBlobData(data);
    [out writeData: [temp dataUsingEncoding:NSUTF8StringEncoding]];
}

+(NSString *)stringFeatureData:(NSArray*)data charSep:(char)charSep {
    NSMutableString *temp = [NSMutableString string];
    for(NSNumber *n in data){
        [temp appendFormat:@"%@%c",n,charSep];
    }//for
    return temp;
}

/**
 *  print the data exported by the feature
 *
 *  @param out  file where write the data
 *  @param data array of NSNumber to print
 */
+(void) storeFeatureData:(NSFileHandle*)out data:(NSArray*)data charSep:(char)charSep{
    NSString *temp = [BlueSTSDKFeatureLogCSV stringFeatureData:data charSep:charSep];
    [out writeData: [temp dataUsingEncoding:NSUTF8StringEncoding]];
}


void appendTo(NSMutableArray<NSString *> *array, NSArray<NSNumber *> *data) {
    for(NSNumber *n in data){
        [array addObject:n.stringValue];
    }//for
}

/**
 *  return the position of the app document directory
 *
 *  @return position of the document directory
 */
+(NSURL*) getDumpFileDirectoryUrl{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

/**
 *  get the tag to identify the logging session, generated from the startup timestamp
 *
 *  @return the tag to identify the logging session
 */
-(NSString *)sessionPrefix {
    return [mDateFormatter stringFromDate:self.startupTimestamp];
}
/**
 *  create/open a new file or retrive the already opened one to be used for log 
 *  the feature data
 *
 *  @param feature feature that we will log in the file
 *
 *  @return file where log the data
 */
-(NSFileHandle*) openDumpFileForFeature:(BlueSTSDKFeature*)feature{
    //syncronize this function for be secure that we enter here one call at time,
    //for avoid ghost update duplicate entry ecc..
    @synchronized(mCacheFileHandler){
        NSFileHandle *temp = [mCacheFileHandler valueForKey:feature.name];
        if(temp!=nil)
            return temp;
        //else
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *documentsDirectory = [BlueSTSDKFeatureLogCSV getDumpFileDirectoryUrl];
//        NSString *fileName = [NSString stringWithFormat:@"%@_%@.csv",feature.parentNode.friendlyNameEasy,feature.name ];

        NSString *fileName = [NSString stringWithFormat:@"%@_%@.csv",[self sessionPrefix],feature.name ];
        fileName = [fileName stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        NSURL *fileUrl = [NSURL URLWithString:fileName relativeToURL:documentsDirectory];
        NSLog(@"LOG\n- Generating filename: [%@]\n- fileUrl: [%@]", fileName, fileUrl);
        
        if(![fileManager fileExistsAtPath:fileUrl.path]){
            [fileManager createFileAtPath:fileUrl.path contents:nil attributes:nil];
        }
        
        NSError *error = nil;
        temp = [NSFileHandle fileHandleForWritingToURL:fileUrl error:&error];
        [self printHeader:temp feature:feature];
        [mCacheFileHandler setValue:temp forKey:feature.name];
        return temp;
    }//syncronized
}

/**
 *  function called by the feature when it has new data, this function will store
 * all the data inside a file in a csv format
 *
 *  @param feature feature that is update
 *  @param raw     raw data unsed for update the feature, they can be nil
 *  @param sample  data extracted by the feature
 */
- (void)feature:(BlueSTSDKFeature *)feature rawData:(NSData*)raw sample:(BlueSTSDKFeatureSample *)sample{
    static const char comma=',';
    NSMutableData *data = [[NSMutableData alloc] init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm:ss.SSS"];
    
    NSFileHandle *file = [self openDumpFileForFeature:feature];

    //prepare fields
    NSDate *notificaitonTime = sample!=nil ? sample.notificaitonTime : [NSDate date];
    uint64_t timestamp = sample != nil ? sample.timestamp : notificaitonTime.timeIntervalSince1970*100;
    NSString *date = [dateFormatter stringFromDate: notificaitonTime];
    
    NSTimeInterval timeInterval = [self.startupTimestamp timeIntervalSinceNow] * -1;
    NSInteger timeIntervalsec = (NSInteger)(timeInterval);
    NSInteger timeIntervalms = (NSInteger)((timeInterval - (NSTimeInterval)timeIntervalsec) * 1000.0);
    NSMutableArray *fields = [@[date,[NSString stringWithFormat:@"%ld%03ld", (long) timeIntervalsec, (long) timeIntervalms],
            feature.parentNode.friendlyName,
            [NSString stringWithFormat:@"%llu", timestamp],
            raw ? stringBlobData(raw) : @""] mutableCopy];
    
    if(sample!=nil)
        appendTo(fields, sample.data);
    
    BOOL first = YES;
    NSData * comaData =[NSData dataWithBytes:&comma length:1];
    for (NSString *field in fields) {
        if (!first) {
            [data appendData:comaData];
        }
        [data appendData:[field dataUsingEncoding:NSUTF8StringEncoding]];
        first = NO;
    }
    [data appendData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
    @synchronized(file){
        [file writeData:data];
    }
}

-(void) closeFiles{
    @synchronized(mCacheFileHandler){
        NSEnumerator *enumerator = [mCacheFileHandler objectEnumerator];
        NSFileHandle *f;
        while ((f = [enumerator nextObject])) {
            [f closeFile];
        }//while
        [mCacheFileHandler removeAllObjects];
    }
}

-(NSArray*) getLogFiles{
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsDirectory = [BlueSTSDKFeatureLogCSV getDumpFileDirectoryUrl];
    //get all the file in the directory
    NSArray *files = [fileManager contentsOfDirectoryAtURL:documentsDirectory
                               includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey]
                                                  options:(NSDirectoryEnumerationSkipsHiddenFiles |
                                                          NSDirectoryEnumerationSkipsSubdirectoryDescendants)
                                                    error:&error];
    //filter the files and keep only the ones with extenstion csv
    NSString *tag = [self sessionPrefix];
    NSInteger ltag = tag.length;
    NSIndexSet *indexes = [files indexesOfObjectsPassingTest:
                           ^BOOL (id obj, NSUInteger i, BOOL *stop) {
                               NSURL *url = (NSURL*)obj;
                               NSString *fileName = url.lastPathComponent;
                               BOOL endWithCSV = [url.pathExtension isEqualToString:@"csv"];
                               BOOL startWithTag = [fileName compare:tag options:NSCaseInsensitiveSearch range:NSMakeRange(0, ltag)] == NSOrderedSame;
                               return startWithTag && endWithCSV;
                           }];
    return [files objectsAtIndexes:indexes];
}

-(void) removeLogFiles{
    NSArray *files = [self getLogFiles];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    for(NSURL *file in files){
        [fileManager removeItemAtURL:file error:&error];
        if(error)
            NSLog(@"Error Removing the file %@ : %@",file.path,error.localizedDescription);
    }//for
    
}
+(BOOL) areThereLogFiles {
    return [[BlueSTSDKFeatureLogCSV getAllLogFiles] count] > 0;
}
+(NSInteger) countAllLogFiles{
    return [[BlueSTSDKFeatureLogCSV getAllLogFiles] count];
}
+(NSArray<NSURL *>*) getAllLogFiles{
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsDirectory = [BlueSTSDKFeatureLogCSV getDumpFileDirectoryUrl];
    //get all the file in the directory
    NSArray<NSURL *> *files = [fileManager contentsOfDirectoryAtURL:documentsDirectory
                                includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey]
                                                   options:(NSDirectoryEnumerationSkipsHiddenFiles |
                                                            NSDirectoryEnumerationSkipsSubdirectoryDescendants)
                                                     error:&error];
    //filter the files and keep only the ones with extenstion csv
    NSIndexSet *indexes = [files indexesOfObjectsPassingTest:
                           ^BOOL (id obj, NSUInteger i, BOOL *stop) {
                               NSURL *url = (NSURL*)obj;
                               return ([url.pathExtension isEqualToString:@"csv"]);
                           }];
    return [files objectsAtIndexes:indexes];
    
}
+(void) clearLogFolder{
    NSArray *files = [BlueSTSDKFeatureLogCSV getAllLogFiles];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    for(NSURL *file in files){
        [fileManager removeItemAtURL:file error:&error];
        if(error)
            NSLog(@"Error Removing the file %@ : %@",file.path,error.localizedDescription);
    }//for
    
}
@end
