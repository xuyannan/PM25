//
//  AQIViewController.h
//  PM25
//
//  Created by xu yannan on 13-3-11.
//  Copyright (c) 2013年 BlueTiger. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AQIViewController : UIViewController
@property (strong, nonatomic) NSString *city;
@property (weak, nonatomic) IBOutlet UILabel *currentCity;
@property (weak, nonatomic) IBOutlet UILabel *aqi;
@property (weak, nonatomic) IBOutlet UILabel *pm;
@property (weak, nonatomic) IBOutlet UILabel *desc;
@property (weak, nonatomic) IBOutlet UILabel *update;
@property (weak, nonatomic) IBOutlet UIButton *refreshButton;

-(void) updateAqiData;
-(AQIViewController *) initWithCity:(NSString *) city;
-(NSString *)description;
@end
