//
//  ConsoleViewController.m
//  W2STSDKSampleApp
//
//  Created by Giovanni Visentini on 03/08/15.
//  Copyright (c) 2015 STCentralLab. All rights reserved.
//

#import "ConsoleViewController.h"


static NSDictionary *errorAttribute;
static NSDictionary *outAttribute;
static NSDictionary *inAttribute;

@interface ConsoleViewController () <W2STSDKDebugOutputDelegate,
    UITextFieldDelegate>
@end

@implementation ConsoleViewController{
    NSMutableAttributedString *mDisplayString;
    NSDateFormatter *mDateFormatter;
}

+(void)initialize{
    if(self == [ConsoleViewController class]){
        errorAttribute = @{
                           NSForegroundColorAttributeName: [UIColor redColor]
                           };
        outAttribute = @{
                         NSForegroundColorAttributeName: [UIColor blueColor]
                         };
        inAttribute = @{
                        NSForegroundColorAttributeName: [UIColor greenColor]
                        };
    }//if
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    mDisplayString = [[NSMutableAttributedString alloc] init];
    
    _userText.delegate=self;
    
    
    mDateFormatter = [[NSDateFormatter alloc] init];
    mDateFormatter.timeStyle = NSDateFormatterMediumStyle;
    mDateFormatter.dateStyle = NSDateFormatterMediumStyle;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    _debugInterface.delegate=self;
    [_userText becomeFirstResponder];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    _debugInterface.delegate=nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [_debugInterface writeMessage: textField.text];
    textField.text=@"";
    return true;
}


-(void) debug:(W2STSDKDebug*)debug didStdOutReceived:(NSString*) msg{
    
    NSString *raw = [NSString stringWithFormat:@"%@ <- %@\n",
                     [mDateFormatter stringFromDate:[NSDate date]],  msg];
    NSAttributedString *temp = [[NSAttributedString alloc] initWithString:raw
                                                               attributes:outAttribute];
    [mDisplayString appendAttributedString:temp];
    dispatch_async(dispatch_get_main_queue(),^{
        _console.attributedText = mDisplayString;
    });
}

-(void) debug:(W2STSDKDebug*)debug didStdErrReceived:(NSString*) msg{
    NSString *raw = [NSString stringWithFormat:@"%@ <- %@\n",
                     [mDateFormatter stringFromDate:[NSDate date]],  msg];
    NSAttributedString *temp = [[NSAttributedString alloc] initWithString:raw
                                                               attributes:errorAttribute];
    [mDisplayString appendAttributedString:temp];
    dispatch_async(dispatch_get_main_queue(),^{
        _console.attributedText = mDisplayString;
    });
}

-(void) debug:(W2STSDKDebug*)debug didStdInSend:(NSString*) msg error:(NSError*)error{
    NSString *raw = [NSString stringWithFormat:@"%@ -> %@\n",
                     [mDateFormatter stringFromDate:[NSDate date]],  msg];
    NSAttributedString *temp = [[NSAttributedString alloc] initWithString:raw
                                                               attributes:inAttribute];
    [mDisplayString appendAttributedString:temp];
    dispatch_async(dispatch_get_main_queue(),^{
        _console.attributedText = mDisplayString;
    });
}

@end

