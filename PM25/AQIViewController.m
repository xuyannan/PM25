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
@property (nonatomic)bool isLoaded;
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
    if (!self.city) {
        return;
    }
    aqiAPI = [[AqiAPI alloc]init ];
    aqiAPI.city = self.city;
    
    dispatch_queue_t getAqiDataQueue = dispatch_queue_create("get AQI data", NULL);
    dispatch_async(getAqiDataQueue, ^{
        AqiData *dataOfChinese = [aqiAPI getChineseAqiDataForCity:self.city];
        //AqiData *dataOfUsem = [aqiAPI getUsemAqiDataForCity:self.city];
        AqiData *dataOfUsem = NULL;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.aqi.text = dataOfChinese.aqi;
            self.pm.text = dataOfChinese.pm;
            self.desc.text = dataOfChinese.desc;
            self.update.text = dataOfChinese.update;
            
            if (dataOfUsem) {
                self.usemAqi.text = dataOfUsem.aqi;
                self.usemPm.text = dataOfUsem.pm;
                self.usemDesc.text = dataOfUsem.desc;
                self.usemUpdate.text = dataOfUsem.update;
            } else if ([aqiAPI isUsemDataSupportedForCity:self.city]) {
                self.usemAqi.text = @"--";
                self.usemPm.text = @"--";
                self.usemDesc.text = @"--";
                self.usemUpdate.text = @"--";
            } else {
                [self.usemAqiTitle removeFromSuperview];
                [self.usemAqi removeFromSuperview];
                [self.usemPm removeFromSuperview];
                [self.usemDesc removeFromSuperview];
                [self.usemUpdate removeFromSuperview];
            }
            
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
    
    self.currentCity.text = self.city;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
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
    
    self.isLoaded = true;
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
    [self updateAqiData];
}
-(IBAction) oneFingerSwipeDown:(UISwipeGestureRecognizer *) recognizer {
    NSLog(@"swipe down");
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
    currentCity = self.city ? self.city : @"北京";
    
    url = [citiesInPinyin objectForKey: currentCity];
    
}


@end
