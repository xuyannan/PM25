//
//  PMFrequencyConfigViewController.h
//  PM25
//
//  Created by xu yannan on 13-2-22.
//  Copyright (c) 2013年 BlueTiger. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PMFrequencyConfigViewController;

@protocol PMFrequencyConfigViewControllerDelegate <NSObject>
-(void) pMFrequencyConfigViewController: (PMFrequencyConfigViewController *) sender
            selectedWeekDays: (NSArray *)selectedWeekDays;
@end

@interface PMFrequencyConfigViewController : UITableViewController
@property (nonatomic, weak) id <PMFrequencyConfigViewControllerDelegate> delegate;
@end
