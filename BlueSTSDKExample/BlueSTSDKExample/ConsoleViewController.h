//
//  ConsoleViewController.h
//  BlueSTSDKExample
//
//  Created by Giovanni Visentini on 03/08/15.
//  Copyright (c) 2015 STCentralLab. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <BlueSTSDK/BlueSTSDKDebug.h>

/**
 *  show the device console, where the user can send coomand to the device serial port
 */
@interface ConsoleViewController : UIViewController

/**
 *  service that permit to send/receive commands
 */
@property (retain) BlueSTSDKDebug *debugInterface;

/**
 *  text field where the user can write the command
 */
@property (weak, nonatomic) IBOutlet UITextField *userText;

/**
 * text view where we show the device response
 */
@property (weak, nonatomic) IBOutlet UITextView *console;

/**
 *  method used for initialize the private and static object of this class
 */
+(void)initialize;

@end
