//
//  AQIViewController.m
//  PM25
//
//  Created by xu yannan on 13-3-11.
//  Copyright (c) 2013年 BlueTiger. All rights reserved.
//

#import "AQIViewController.h"
#import "DDXMLDocument.h"
#import "AqiAPI.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManager.h>

@interface AQIViewController () {
    NSDictionary *citiesInPinyin;
    AqiAPI *aqiAPI;
}

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *pms;

@end

@implementation AQIViewController

- (NSString *)description {
    return [[NSString alloc]initWithFormat:@"An AQIViewController of city: %@", self.city ];
}

- (AQIViewController *) initWithCity:(NSString *)city {
    if (self = [super init]) {
        _city = city;
    }
    return self;
}

- (void) updateAqiData {
    NSLog(@"update aqi data for %@", self.city);
    aqiAPI = [[AqiAPI alloc]initWithCity:self.city];
    dispatch_queue_t getAqiDataQueue = dispatch_queue_create("get AQI data", NULL);
    dispatch_async(getAqiDataQueue, ^{
        AqiData *data = [aqiAPI getAqiData];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.aqi.text = data.aqi;
            self.pm.text = data.pm;
            self.desc.text = data.desc;
            self.update.text = data.update;
            // 去掉"市"
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"市$" options:NSRegularExpressionCaseInsensitive error:nil];
            self.city = [regex stringByReplacingMatchesInString:self.city options:0 range:NSMakeRange(0, [self.city length]) withTemplate:@""];
            
            self.currentCity.text = self.city;
        });
    });
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 半透明
    UIColor *transColor = [[UIColor alloc]initWithRed:0 green:0 blue:0 alpha:0.1];
    //self.view.superview.backgroundColor = transColor;
    self.view.backgroundColor = transColor;

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    // self.locationManager.locationServicesEnabled = true;
    self.locationManager = [[CLLocationManager alloc] init];
    //self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 10;
    [self.locationManager startUpdatingLocation];
    

    /*
    UIView *floatView = [[UIView alloc] initWithFrame:bounds];
    floatView.backgroundColor = [UIColor colorWithRed:(0/255.f) green:(0/255.f) blue:(0/255.f) alpha:0.2];
    floatView.tag = 1;
    [self.view addSubview:floatView];
    */
    for(UIView *view in self.view.subviews ) {
        if ([view isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)view;
            label.textColor = [UIColor colorWithRed:(255/255.f) green:(255/255.f) blue:(255/255.f) alpha:1];
        }
    }
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.locationManager stopUpdatingLocation];
}

// 获取实时PM2.5数据
-(void) getCurretnPmValue {
    NSURL *url;
    NSLog(@"%@", @"refresh...");
    
    NSString *currentCity;
    currentCity = self.city ? self.city : @"北京市";
    
    url = [citiesInPinyin objectForKey: currentCity];
    
}


@end
