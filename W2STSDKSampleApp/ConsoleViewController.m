//
//  ConsoleViewController.m
//  W2STSDKSampleApp
//
//  Created by Giovanni Visentini on 03/08/15.
//  Copyright (c) 2015 STCentralLab. All rights reserved.
//

#import "ConsoleViewController.h"

/**
 *  style used for the error message
 */
static NSDictionary *sErrorAttribute;

/**
 *  style used for the output message
 */
static NSDictionary *sOutAttribute;

/**
 *  style used for the input message
 */
static NSDictionary *sInAttribute;

/**
 *  object used for print the message date
 */
static NSDateFormatter *sDateFormatter;


@interface ConsoleViewController () <W2STSDKDebugOutputDelegate,
    UITextFieldDelegate>
@end

@implementation ConsoleViewController{
    
    /**
     *  displayed string with all the message send/received to/from the board
     */
    NSMutableAttributedString *mDisplayString;
}

/**
 *  initialize the private static variable
 */
+(void)initialize{
    if(self == [ConsoleViewController class]){
        // error message display with read color
        sErrorAttribute = @{
                            NSForegroundColorAttributeName: [UIColor redColor]
                            };
        // send message display with blue color
        sOutAttribute = @{
                          NSForegroundColorAttributeName: [UIColor blueColor]
                          };
        // received message display with green color
        sInAttribute = @{
                         NSForegroundColorAttributeName: [UIColor greenColor]
                         };
        
        // object that will format the message received time
        sDateFormatter = [[NSDateFormatter alloc] init];
        sDateFormatter.timeStyle = NSDateFormatterMediumStyle;
        sDateFormatter.dateStyle = NSDateFormatterMediumStyle;
    }//if
}//initialize


- (void)viewDidLoad {
    [super viewDidLoad];
    mDisplayString = [[NSMutableAttributedString alloc] init];
    self.userText.delegate=self;
}//viewDidLoad

/**
 *  when the view appear, register this class as debug delegate + display the
 *  text input
 *
 *  @param animated <#animated description#>
 */
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.debugInterface.delegate=self;
    [self.userText becomeFirstResponder];
}//viewDidAppear

/**
 * when the view disappear remove the debug listener
 *
 *  @param animated <#animated description#>
 */
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    self.debugInterface.delegate=nil;
}//viewDidDisappear

/**
 *  when the user press the return button, send the write message and reset the
 *  text field and hide the keyboard
 *
 *  @param textField text field that generate the callback
 *
 *  @return true
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [_debugInterface writeMessage: textField.text];
    textField.text=@"";
    [self.view endEditing:YES];
    return true;
}//textFieldShouldReturn

/**
 *  display a message received from the device
 *
 *  @param debug object that send the message
 *  @param msg   message received from the board
 */
-(void) debug:(W2STSDKDebug*)debug didStdOutReceived:(NSString*) msg{
    
    NSString *raw = [NSString stringWithFormat:@"%@ <- %@\n",
                     [sDateFormatter stringFromDate:[NSDate date]],  msg];
    NSAttributedString *temp = [[NSAttributedString alloc] initWithString:raw
                                                               attributes:sOutAttribute];
    [mDisplayString appendAttributedString:temp];
    dispatch_async(dispatch_get_main_queue(),^{
        _console.attributedText = mDisplayString;
    });
}//didStdOutReceived

/**
 *  display an error message received from the device
 *
 *  @param debug object that send the message
 *  @param msg   error message received from the board
 */
-(void) debug:(W2STSDKDebug*)debug didStdErrReceived:(NSString*) msg{
    NSString *raw = [NSString stringWithFormat:@"%@ <- %@\n",
                     [sDateFormatter stringFromDate:[NSDate date]],  msg];
    NSAttributedString *temp = [[NSAttributedString alloc] initWithString:raw
                                                               attributes:sErrorAttribute];
    [mDisplayString appendAttributedString:temp];
    dispatch_async(dispatch_get_main_queue(),^{
        _console.attributedText = mDisplayString;
    });
}//didStdErrReceived

/**
 *  display a message that is send to the device
 *
 *  @param debug object where we send the message
 *  @param msg   message send
 *  @param error error happen during the sending or nil is the message was correctly send
 */
-(void) debug:(W2STSDKDebug*)debug didStdInSend:(NSString*) msg error:(NSError*)error{
    NSString *raw = [NSString stringWithFormat:@"%@ -> %@\n",
                     [sDateFormatter stringFromDate:[NSDate date]],  msg];
    NSAttributedString *temp = [[NSAttributedString alloc] initWithString:raw
                                                               attributes:sInAttribute];
    [mDisplayString appendAttributedString:temp];
    dispatch_async(dispatch_get_main_queue(),^{
        _console.attributedText = mDisplayString;
    });
}//didStdInSend

@end

