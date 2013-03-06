//
//  PMTimeConfigViewContoller.h
//  PM25
//
//  Created by xu yannan on 13-2-22.
//  Copyright (c) 2013年 BlueTiger. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PMTimeConfigViewContoller;

@protocol PMTimeConfigViewContollerDelegate <NSObject>
@optional
-(void) pMTimeConfigViewContoller:(PMTimeConfigViewContoller *) sender
                          timeStr: (NSString *) timeStr;
@end

@interface PMTimeConfigViewContoller : UIViewController
@property (weak, nonatomic) IBOutlet UIDatePicker *timePicker;
@property (nonatomic, weak) id <PMTimeConfigViewContollerDelegate> delegate;
@end
