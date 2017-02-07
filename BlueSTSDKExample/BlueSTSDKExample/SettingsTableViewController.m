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

#import "SettingsTableViewController.h"

#import <BlueSTSDK/BlueSTSDKWeSURegisterDefines.h>

@interface SettingsTableViewController ()<BlueSTSDKConfigControlDelegate>

@end

@implementation SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    if (_configControl != nil) {
        [_configControl addConfigDelegate:self];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"No config control."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    // Initialize the refresh control.
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor whiteColor];
    self.refreshControl.tintColor = [UIColor blueColor];
    [self.refreshControl addTarget:self
                            action:@selector(refreshAction)
                  forControlEvents:UIControlEventValueChanged];
    
    /*
     // This line makes the spinner start spinning
     [self.refreshControl beginRefreshing];
     // This line makes the spinner visible by pushing the table view/collection view down
     [self.tableView setContentOffset:CGPointMake(0, -1.0f * self.refreshControl.frame.size.height) animated:YES];
     // This line is what actually triggers the refresh action/selector
     [self.refreshControl sendActionsForControlEvents:UIControlEventValueChanged];
     */
    [self performSelector:@selector(refreshAction) withObject:nil afterDelay:0.1];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [_configControl removeConfigDelegate:self];
}


#pragma mark - Table view data source

-(void)asyncReadWithRegisterName:(BlueSTSDKWeSURegisterName_e)name target:(BlueSTSDKRegisterTarget_e)target {
    if (self.configControl != nil && name != BlueSTSDK_REGISTER_NAME_NONE && target != BlueSTSDK_REGISTER_TARGET_BOTH) {
        BlueSTSDKRegister *reg = [BlueSTSDKWeSURegisterDefines lookUpWithRegisterName:name];
        BlueSTSDKCommand *cmd = [BlueSTSDKCommand commandWithRegister:reg target:target];
        
        [self.configControl read:cmd];
    }
}

- (void)refreshAction {
    
    @try {
        [self asyncReadWithRegisterName:BlueSTSDK_REGISTER_NAME_BLE_LOC_NAME target:BlueSTSDK_REGISTER_TARGET_PERSISTENT];
        [self asyncReadWithRegisterName:BlueSTSDK_REGISTER_NAME_BLE_PUB_ADDR target:BlueSTSDK_REGISTER_TARGET_PERSISTENT];
        [self asyncReadWithRegisterName:BlueSTSDK_REGISTER_NAME_FW_VER target:BlueSTSDK_REGISTER_TARGET_PERSISTENT];
        
        [self asyncReadWithRegisterName:BlueSTSDK_REGISTER_NAME_LED_CONFIG target:BlueSTSDK_REGISTER_TARGET_PERSISTENT];
        [self asyncReadWithRegisterName:BlueSTSDK_REGISTER_NAME_PWR_MODE_CONFIG target:BlueSTSDK_REGISTER_TARGET_PERSISTENT];
    }
    @catch (NSException *exception) {
    }
    @finally {
        [self performSelector:@selector(refreshEndAction) withObject:nil afterDelay:1];
    }
}

- (void)refreshEndAction {
    [self.refreshControl endRefreshing];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSInteger nrow = 0;
    switch (section) {
        case 1:
        case 0:
            nrow = 3;
            break;
            
        default:
            break;
    }
    return nrow;
}


-(void) alertNewLocalName:(NSString*)currentName{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Settings"
                                  message:@""
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    [alert setMessage:@"Specify the local name"];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Local name";
        textField.text = currentName;
    }];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
                                                   //Do Some action here
                                                   //perform a write
                                                   [self writeLocalName:((UITextField*)alert.textFields[0]).text];
                                               }];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * action) {
                                                       //nothing
                                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                                   }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];

}//alertNewLocalName

-(void)alertNewAddres:(NSString*)currentAdr{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Settings"
                                  message:@""
                                  preferredStyle:UIAlertControllerStyleAlert];
    [alert setMessage:@"Specify the pubblic address\n(format XX:XX:XX:XX:XX:XX)"];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Pubblic address";
        textField.text = currentAdr;
    }];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
                                                   //Do Some action here
                                                   //perform a write
                                                   [self writePubblicAddress:((UITextField*)alert.textFields[0]).text];
                                               }];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * action) {
                                                       //nothing
                                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                                   }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)alertLedConf{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Settings"
                                  message:@""
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    [alert setMessage:@"Select the led configuration"];
    
    UIAlertAction* action0 = [UIAlertAction actionWithTitle:@"Normal" style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                        //Do Some action here
                                                        //perform a write
                                                        [self writeLedConfiguration:@"LED_FW"];
                                                    }];
    UIAlertAction* action1 = [UIAlertAction actionWithTitle:@"User On" style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                        //Do Some action here
                                                        //perform a write
                                                        [self writeLedConfiguration:@"LED_USER_ON"];
                                                    }];
    UIAlertAction* action2 = [UIAlertAction actionWithTitle:@"User Off" style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                        //Do Some action here
                                                        //perform a write
                                                        [self writeLedConfiguration:@"LED_USER_OFF"];
                                                    }];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * action) {
                                                       //nothing
                                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                                   }];
    
    [alert addAction:action0];
    [alert addAction:action1];
    [alert addAction:action2];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];

}

-(void)alertLowPowerMode{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Settings"
                                  message:@""
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    [alert setMessage:@"Select the power mode"];
    
    UIAlertAction* action0 = [UIAlertAction actionWithTitle:@"Full run" style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                        //Do Some action here
                                                        //perform a write
                                                        [self writeLowPowerMode:@"PWR_MODE_FULL_RUN"];
                                                    }];
    UIAlertAction* action1 = [UIAlertAction actionWithTitle:@"Low power - mode 1" style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                        //Do Some action here
                                                        //perform a write
                                                        [self writeLowPowerMode:@"PWR_MODE_LOW_POWER_1"];
                                                    }];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * action) {
                                                       //nothing
                                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                                   }];
    
    [alert addAction:action0];
    [alert addAction:action1];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)alertFwUpgrade{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Settings"
                                  message:@""
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    [alert setMessage:@"Select the boot mode"];
    
    UIAlertAction* action0 = [UIAlertAction actionWithTitle:@"App" style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                        //Do Some action here
                                                        //perform a write
                                                        [self writeFWUpgrade:@"BOOT_APP"];
                                                    }];
    UIAlertAction* action1 = [UIAlertAction actionWithTitle:@"DFU" style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                        //Do Some action here
                                                        //perform a write
                                                        [self writeFWUpgrade:@"BOOT_DFU"];
                                                    }];
    UIAlertAction* action2 = [UIAlertAction actionWithTitle:@"OTA" style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                        //Do Some action here
                                                        //perform a write
                                                        [self writeFWUpgrade:@"BOOT_OTA"];
                                                    }];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * action) {
                                                       //nothing
                                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                                   }];
    
    [alert addAction:action0];
    [alert addAction:action1];
    [alert addAction:action2];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    NSInteger index = indexPath.section * 10 + indexPath.row;
    switch(index)
    {
        case 0: //local name
            [self alertNewLocalName: cell.detailTextLabel.text];
            break;
        case 1: //public address
            [self alertNewAddres:cell.detailTextLabel.text];
            break;
        case 2: //fw version
            [self asyncReadWithRegisterName:BlueSTSDK_REGISTER_NAME_FW_VER target:BlueSTSDK_REGISTER_TARGET_PERSISTENT];
            break;
        case 10: //led configuration
            [self alertLedConf];
            break;
        case 11: //low power mode
            [self alertLowPowerMode];
            break;
        case 12: //fw upgrade
            [self alertFwUpgrade];
            break;
    }
    
}



-(void) writeLocalName:(NSString *)name {
    if (self.configControl != nil) {
        BlueSTSDKRegister *reg = [BlueSTSDKWeSURegisterDefines lookUpWithRegisterName:BlueSTSDK_REGISTER_NAME_BLE_LOC_NAME];
        size_t s = reg.size * 2;
        unsigned char buffer[s];
        memset(buffer, 0x00, s);
        buffer[0] = 0x09;
        
        NSData* dataname = [name dataUsingEncoding:NSUTF8StringEncoding];
        [dataname getBytes:(void *)(buffer+1) length:MIN(s - 1, dataname.length)];
        
        
        NSData* data = [NSData dataWithBytes:buffer length:s];
        BlueSTSDKCommand* cmd = [BlueSTSDKCommand commandWithRegister:reg target:BlueSTSDK_REGISTER_TARGET_PERSISTENT data:data];
        
        [self.configControl write:cmd];
    }
}
-(void) writePubblicAddress:(NSString *)pubblicaddress {
    if (self.configControl != nil) {
        BlueSTSDKRegister *reg = [BlueSTSDKWeSURegisterDefines lookUpWithRegisterName:BlueSTSDK_REGISTER_NAME_BLE_PUB_ADDR];
        size_t s = reg.size * 2;
        unsigned char buffer[s];
        unsigned int value = 0;
        NSScanner *scanner = nil;
        memset(buffer, 0x00, s);
        
        NSString *regex = @"[0-9a-f][0-9a-f]:[0-9a-f][0-9a-f]:[0-9a-f][0-9a-f]:[0-9a-f][0-9a-f]:[0-9a-f][0-9a-f]:[0-9a-f][0-9a-f]";
        NSString *lowerstr = [pubblicaddress lowercaseString];
        
        NSPredicate *regExPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
        BOOL result = [regExPredicate evaluateWithObject: lowerstr];
        
        if (result) {
            NSArray *strarray = [pubblicaddress componentsSeparatedByString: @":"];
            int  i = 5;
            
            for(NSString *strvalue in strarray) {
                scanner = [NSScanner scannerWithString:strvalue];
                [scanner scanHexInt:&value];
                buffer[i--] = (unsigned char)value;
            }
            
            NSData* data = [NSData dataWithBytes:buffer length:s];
            BlueSTSDKCommand* cmd = [BlueSTSDKCommand commandWithRegister:reg target:BlueSTSDK_REGISTER_TARGET_PERSISTENT data:data];
            
            [self.configControl write:cmd];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Settings"
                                                            message:[NSString stringWithFormat:@"Invalid address\n%@", [pubblicaddress uppercaseString]]
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            
        }
    }
}
-(void) writeLedConfiguration:(NSString *)conf {
    if (self.configControl != nil) {
        BlueSTSDKRegister *reg = [BlueSTSDKWeSURegisterDefines lookUpWithRegisterName:BlueSTSDK_REGISTER_NAME_LED_CONFIG];
        size_t s = reg.size * 2;
        unsigned char buffer[s];
        
        unsigned char value = 0x00;
        if ([conf isEqualToString:@"LED_FW"]) {
            value = 0x00;
        }
        else if ([conf isEqualToString:@"LED_USER_OFF"]) {
            value = 0x12;
        }
        else if ([conf isEqualToString:@"LED_USER_ON"]) {
            value = 0x11;
        }
        buffer[0] = value;
        buffer[1] = 0x00;
        
        NSData* data = [NSData dataWithBytes:buffer length:s];
        BlueSTSDKCommand* cmd = [BlueSTSDKCommand commandWithRegister:reg target:BlueSTSDK_REGISTER_TARGET_PERSISTENT data:data];
        
        [self.configControl write:cmd];
    }
}
-(void) writeLowPowerMode:(NSString *)mode {
    if (self.configControl != nil) {
        BlueSTSDKRegister *reg = [BlueSTSDKWeSURegisterDefines lookUpWithRegisterName:BlueSTSDK_REGISTER_NAME_PWR_MODE_CONFIG];
        size_t s = reg.size * 2;
        unsigned char buffer[s];
        
        unsigned char value = 0x00;
        if ([mode isEqualToString:@"PWR_MODE_FULL_RUN"]) {
            value = 0x00;
        }
        else if ([mode isEqualToString:@"PWR_MODE_LOW_POWER_1"]) {
            value = 0x01;
        }
        buffer[0] = value;
        buffer[1] = 0x00;
        
        NSData* data = [NSData dataWithBytes:buffer length:s];
        BlueSTSDKCommand* cmd = [BlueSTSDKCommand commandWithRegister:reg target:BlueSTSDK_REGISTER_TARGET_PERSISTENT data:data];
        
        [self.configControl write:cmd];
    }
}
-(void) writeFWUpgrade:(NSString *)fwupgrade {
    if (self.configControl != nil) {
        BlueSTSDKRegister *reg = [BlueSTSDKWeSURegisterDefines lookUpWithRegisterName:BlueSTSDK_REGISTER_NAME_DFU_REBOOT];
        size_t s = reg.size * 2;
        unsigned char buffer[s];
        
        unsigned char value = 0x00;
        if ([fwupgrade isEqualToString:@"BOOT_APP"]) {
            value = 0x00;
        }
        else if ([fwupgrade isEqualToString:@"BOOT_DFU"]) {
            value = 0x01;
        }
        else if ([fwupgrade isEqualToString:@"BOOT_OTA"]) {
            value = 0x02;
        }
        buffer[0] = value;
        buffer[1] = 0x00;
        
        NSData* data = [NSData dataWithBytes:buffer length:s];
        BlueSTSDKCommand* cmd = [BlueSTSDKCommand commandWithRegister:reg target:BlueSTSDK_REGISTER_TARGET_SESSION data:data];
        
        [self.configControl write:cmd];
    }
}
-(void) configControl:(BlueSTSDKConfigControl *) configControl didRegisterReadResult:(BlueSTSDKCommand *)cmd error:(NSInteger)error {
    if (cmd == nil || cmd.registerField == nil)
        return;
    
    BlueSTSDKRegister *reg = cmd.registerField;
    NSData * payload = cmd.data;
    NSIndexPath *indexPath = nil;
    
    unsigned char buffer[payload.length];
    [payload getBytes:buffer length:payload.length];
    BlueSTSDKWeSURegisterName_e regname = [BlueSTSDKWeSURegisterDefines lookUpRegisterNameWithAddress:reg.address target:cmd.target];
    UITableViewCell *cell = nil;
    bool checksize = payload.length == reg.size * 2;
    NSString *text = @"";
    if (checksize && (error == 0 || error == 2)) {
        switch(regname)
        {
            case BlueSTSDK_REGISTER_NAME_BLE_LOC_NAME: //local name
                indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                text = [NSString stringWithUTF8String:(const char *)(&buffer[1])];
                break;
            case BlueSTSDK_REGISTER_NAME_BLE_PUB_ADDR: //address
                indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                text = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                        buffer[5],
                        buffer[4],
                        buffer[3],
                        buffer[2],
                        buffer[1],
                        buffer[0]];
                break;
            case BlueSTSDK_REGISTER_NAME_FW_VER: //address
                indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                text = [NSString stringWithFormat:@"%d.%d", buffer[0], buffer[1]];
                break;
            case BlueSTSDK_REGISTER_NAME_LED_CONFIG: //led config
                indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
                switch(buffer[0])
            {
                case 0x00:
                    text = @"Normal";
                    break;
                case 0x11:
                    text = @"User On";
                    break;
                case 0x12:
                    text = @"User Off";
                    break;
                default:
                    text = [NSString stringWithFormat:@"Unknown config 0x%0.2X", buffer[0]];
            }
                break;
            case BlueSTSDK_REGISTER_NAME_PWR_MODE_CONFIG: //power mode
                indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
                if (buffer[0] == 0x00)
                {
                    text = @"Full run";
                }
                else {
                    text = [NSString stringWithFormat:@"Low power - code %d", (int)buffer[0]];
                }
                break;
            default:
                break;
        }
        
        if (indexPath != nil) {
            cell = [self.tableView cellForRowAtIndexPath:indexPath];
            dispatch_async(dispatch_get_main_queue(),^{
                cell.detailTextLabel.text = text;
            });
        }
    }
}

-(void) configControl:(BlueSTSDKConfigControl *) configControl didRegisterWriteResult:(BlueSTSDKCommand *)cmd error:(NSInteger)error {
    if (error == 0 && cmd != nil && cmd.registerField != nil) {
        BlueSTSDKCommand *readCmd = [BlueSTSDKCommand commandWithRegister:cmd.registerField target:cmd.target];
        dispatch_async(dispatch_get_main_queue(),^{
            [self.configControl read:readCmd];
        });
    }
}

-(void) configControl:(BlueSTSDKConfigControl *)configControl didRequestResult:(BlueSTSDKCommand *)cmd success:(bool)success {
    
}

@end

