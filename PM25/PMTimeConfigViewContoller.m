//
//  PMTimeConfigViewContoller.m
//  PM25
//
//  Created by xu yannan on 13-2-22.
//  Copyright (c) 2013年 BlueTiger. All rights reserved.
//

#import "PMTimeConfigViewContoller.h"
#import "ConfigViewController.h"

@interface PMTimeConfigViewContoller ()

@end

@implementation PMTimeConfigViewContoller


- (void)viewDidLoad
{
    [super viewDidLoad];
    	// Do any additional setup after loading the view.
    NSMutableArray *userConfigArray = [[NSUserDefaults standardUserDefaults]objectForKey:@"user_config"];
    NSString *time = [userConfigArray objectAtIndex:0];
    NSString *timeStr = [[NSString alloc]initWithFormat:@"2009-9-29 %@:00 +0800", time ];
    
    //NSDate *toDate = [[NSDate alloc] initWi];
    //self.timePicker.date = toDate;
}

- (void) viewDidDisappear:(BOOL)animated {
    NSDate *time = [self.timePicker date];
    NSLog(@"%@, %@", @"hello", [time description]);
    NSLocale *zhLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale: zhLocale];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    NSLog(@"%@", [time description]);
    //NSString *selectedTime = [time description];
    
    
    NSCalendar *calender = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSUInteger units = NSHourCalendarUnit|NSMinuteCalendarUnit;
    NSDateComponents *components = [calender components:units fromDate:time];
    
    NSString *msg = [NSString stringWithFormat:@"%d:%d", [components hour], [components minute]];
    [self.delegate pMTimeConfigViewContoller:self timeStr:msg];
    
    //[self.timePicker ]
}


@end
