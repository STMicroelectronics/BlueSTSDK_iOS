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


@interface ConsoleViewController () <BlueSTSDKDebugOutputDelegate,
    UITextFieldDelegate>
@end

@implementation ConsoleViewController{
    
    /**
     *  displayed string with all the message send/received to/from the board
     */
    NSMutableAttributedString *mDisplayString;
    /** message that we have to send */
    NSString *mMessageToSend;
    /** number of byte that we have sent */
    NSUInteger mLastByteSend;
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
    [self.debugInterface addDebugOutputDelegate:self];
    [self.userText becomeFirstResponder];
}//viewDidAppear

/**
 * when the view disappear remove the debug listener
 *
 *  @param animated <#animated description#>
 */
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.debugInterface removeDebugOutputDelegate:self];
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
    [self setMessageToSend:textField.text];
    [self sendMessage];
    textField.text=@"";
    [self.view endEditing:YES];
    return true;
}//textFieldShouldReturn

/** the message 
 * @param msg message that we have to send
 */
-(void)setMessageToSend:(NSString *)msg{
    mMessageToSend=msg;
    mLastByteSend=0;
}

/**
 * send a a message, or part of it
 */
-(void)sendMessage{
    
    if(mLastByteSend >= mMessageToSend.length)
        return;
    
    mLastByteSend += [_debugInterface writeMessage:
                      [mMessageToSend substringFromIndex:mLastByteSend]];
    
}


/**
 *  display a message received from the device
 *
 *  @param debug object that send the message
 *  @param msg   message received from the board
 */
-(void) debug:(BlueSTSDKDebug*)debug didStdOutReceived:(NSString*) msg{
    
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
-(void) debug:(BlueSTSDKDebug*)debug didStdErrReceived:(NSString*) msg{
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
-(void) debug:(BlueSTSDKDebug*)debug didStdInSend:(NSString*) msg error:(NSError*)error{
    NSString *raw = [NSString stringWithFormat:@"%@ -> %@\n",
                     [sDateFormatter stringFromDate:[NSDate date]],  msg];
    NSAttributedString *temp = [[NSAttributedString alloc] initWithString:raw
                                                               attributes:sInAttribute];
    [mDisplayString appendAttributedString:temp];
    dispatch_async(dispatch_get_main_queue(),^{
        _console.attributedText = mDisplayString;
        //after update the gui we can send a new message
        [self sendMessage];
    });
}//didStdInSend

@end

