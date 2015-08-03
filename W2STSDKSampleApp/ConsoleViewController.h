//
//  ConsoleViewController.h
//  W2STSDKSampleApp
//
//  Created by Giovanni Visentini on 03/08/15.
//  Copyright (c) 2015 STCentralLab. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <W2STSDK/W2STSDKDebug.h>

@interface ConsoleViewController : UIViewController


@property (retain) W2STSDKDebug *debugInterface;
@property (weak, nonatomic) IBOutlet UITextField *userText;
@property (weak, nonatomic) IBOutlet UITextView *console;

+(void)initialize;

@end
