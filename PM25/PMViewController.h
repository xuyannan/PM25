//
//  PMViewController.h
//  PM25
//
//  Created by xu yannan on 13-2-21.
//  Copyright (c) 2013年 BlueTiger. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PMViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *result;
@property (weak, nonatomic) IBOutlet UILabel *pmValue;
@property (weak, nonatomic) IBOutlet UILabel *updateTime;
@property (weak, nonatomic) IBOutlet UILabel *aqiValue;
@property (weak, nonatomic) IBOutlet UILabel *currentCity;

- (IBAction)refresh:(UIButton *)sender;
@end
