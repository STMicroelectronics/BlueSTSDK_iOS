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

#ifndef BlueSTSDK_BlueSTSDKFeatureLogCSV_h
#define BlueSTSDK_BlueSTSDKFeatureLogCSV_h

#import <Foundation/Foundation.h>

#import "BlueSTSDKFeature.h"

/**
 * class that implement the {@link BlueSTSDKFeatureLogDelegate} and store the data in a csv
 * file with the same name of the feature.
 * it can be used for logging multiple feature, each feature has its file.The files
 * are keeped open for avoid multiple fopen/fclose.
 * @note Call closeFiles when you stop the logging for avoid to keep open the files
 *
 * a log row has the format:
 *  - NodeName: name of the node that send the data
 *  - RawData: exadecimal version of the raw data used for extract the feature data
 *  - a colum for each feature item
 *
 * @author STMicroelectronics - Central Labs.
 */
@interface BlueSTSDKFeatureLogCSV : NSObject<BlueSTSDKFeatureLogDelegate>

/**
 *  startup timestamp of the logging
 */
@property (readonly,strong) NSDate* startupTimestamp;

/**
 *  create a logger
 *
 *  @return pointer to the logger
 */
+(instancetype)logger;


/**
 *  create a logger
 *
 *  @param timestamp timestamp used in the file name
 *  @param nodes     list of node to log
 *
 *  @return pointer to a logger
 */
+(instancetype)loggerWithTimestamp:(NSDate *)timestamp nodes:(NSArray *)nodes;

/**
 *  create a logger that use the current timestamp inside the file name
 *
 *  @param nodes list of node to log
 *
 *  @return pointer to a logger	
 */
+(instancetype)loggerWithNodes:(NSArray *)nodes;

/**
 *  create a logger
 *
 *  @param timestamp timestamp used in the file name
 *  @param nodes     list of node to log
 *
 *  @return pointer to a logger
 */
-(instancetype)initWithTimestamp:(NSDate *)timestamp nodes:(NSArray *)nodes;

/**
 *  close all the open files
 */
-(void) closeFiles;

/**
 *  get all the csv file of the current session logging in the directory
 *
 *  @return array of NSURL with the created log files
 */
-(NSArray*) getLogFiles;

/**
 *  remove all the file of the current session with estension *.csv in the same folter where we save the log files
 */
-(void) removeLogFiles;

/**
 *  get the tag to identify the logging session, generated from the startup timestamp
 *
 *  @return the tag to identify the logging session
 */
-(NSString *)sessionPrefix;

/**
 *  true if there are log files
 *
 *  @return true if there are log files, false if there are no log files
 */
+(BOOL) areThereLogFiles;

/**
 *  count the log files available in the folder
 *
 *  @return the number of log files
 */
+(NSInteger) countAllLogFiles;

/**
 *  get all log files available in the folder
 *
 *  @return array of log files
 */
+(NSArray<NSURL *>*) getAllLogFiles;
/**
 *  clear log folder from all csv files
 */
+(void) clearLogFolder;

/**
 *  return the position of the app document directory
 *
 *  @return position of the document directory
 */
+(NSURL*) getDumpFileDirectoryUrl;

@end
#endif
