//
//  DeviceTableViewCell.h
//  W2STSDKSampleApp
//
//  Created by Giovanni Visentini on 03/08/15.
//  Copyright (c) 2015 STCentralLab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *boardImage;
@property (strong, nonatomic) IBOutlet UILabel *boardName;
@property (strong, nonatomic) IBOutlet UILabel *boardDetails;

@end
