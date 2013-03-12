//
//  PMViewController.m
//  PM25
//
//  Created by xu yannan on 13-2-21.
//  Copyright (c) 2013年 BlueTiger. All rights reserved.
//

#import "PMViewController.h"

#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManager.h>
#import "PhotosCollectionViewController.h"

#import "AQIViewController.h"
#import "ButtonsViewController.h"

#define CITY_LIST_KEY @"citylist"

@interface PMViewController () <CLLocationManagerDelegate, PhotosCollectionViewControllerDelegate, UIScrollViewAccessibilityDelegate, ButtonsViewControllerDelegate> {
    NSString *currentCity;
    NSMutableDictionary *cityDictionary;
    NSMutableArray *cityArray;
    UIImageView *backgroundView;
    NSString *currentImageName;
}

@property(nonatomic, strong) CLLocationManager *locationManager;
@property(nonatomic, strong) UIScrollView *scrollView;
@property(nonatomic, strong) ButtonsViewController *buttonsVC;
@property(weak,nonatomic) PhotosCollectionViewController *photosCollectionVC;

@end

@implementation PMViewController

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    cityArray = [[NSUserDefaults standardUserDefaults] objectForKey:CITY_LIST_KEY];
    if (!cityArray) {
        cityArray = [[NSMutableArray alloc]init];
        [cityArray addObject:@"北京市"];
        [cityArray addObject:@"广州市"];
        [cityArray addObject:@"上海市"];
        [cityArray addObject:@"成都市"];
    }
    if (!cityDictionary) {
        cityDictionary = [[NSMutableDictionary alloc]init];
    }
    for (NSString *city in cityArray) {
        AQIViewController *aqiVC = [[AQIViewController alloc]initWithCity: city];
        [cityDictionary setObject:aqiVC forKey:city];
    }
    
    // background
    currentImageName = [[NSUserDefaults standardUserDefaults]objectForKey:@"background"];
    
    currentImageName = currentImageName ? currentImageName : @"background.jpg";
    if(backgroundView) {
        [backgroundView removeFromSuperview];
    }

    backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed: currentImageName]];
    [self.view insertSubview:backgroundView atIndex:0];
    
    // scroll view
    [self getReadyForScrollView];
    
    // buttons
    CGRect bounds = [[UIScreen mainScreen] bounds];
    self.buttonsVC = [[ButtonsViewController alloc]initWithNibName:@"ButtonsViewController" bundle:nil];
    [self.buttonsVC.view setFrame:CGRectMake(bounds.size.width - 120, bounds.size.height - 60, 90, 30)];
    [self.view addSubview: self.buttonsVC.view];
    self.buttonsVC.delegate = self;
}

-(void)viewDidLoad {
    self.aqiViewController = [[AQIViewController alloc]initWithNibName:@"AQIViewController" bundle:nil];
    [self.scrollView addSubview:self.aqiViewController.view];
    
    [super viewDidLoad];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 10;
    [self.locationManager startUpdatingLocation];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
     [self.locationManager stopUpdatingLocation];
}


//更新所有AQIViewController
-(void) updateAqiViews {
    CGRect bounds = [[UIScreen mainScreen] bounds];
    NSLog(@"%f" , bounds.size.height);
    int index = 0;
    for (NSString *citykey in cityDictionary) {
        AQIViewController *avc = [cityDictionary objectForKey:citykey];
        [avc updateAqiData];
        NSLog(@"%@", [avc description]);
        [avc.view setFrame:CGRectMake(0, index * bounds.size.height, bounds.size.width, bounds.size.height)];
        [self.scrollView addSubview:avc.view];
        index ++;
    }
}

#pragma mark - getReadyForScrollView

-(void)getReadyForScrollView {
    if (!self.scrollView) {
        //CGRect bounds = self.view.superview.frame;
        CGRect bounds = [[UIScreen mainScreen]bounds];
        self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, bounds.size.width, bounds.size.height)];
        //self.scrollView.backgroundColor = [[UIColor alloc]initWithWhite:1 alpha:0.1];
        self.scrollView.delegate = self;
        self.scrollView.contentSize = CGSizeMake(bounds.size.width, bounds.size.height * [cityArray count]);
    }
    [self.view insertSubview:self.scrollView atIndex:1];
}

#pragma mark - CLLocationManagerDelegate method


-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation *location = [locations objectAtIndex:0];
    NSLog(@"lat:%f - lon:%f", location.coordinate.latitude, location.coordinate.longitude);
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            NSLog(@"Geocode failed with error: %@", error);
            //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"无法获取当前城市，请手动设置" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            //[alert show];
        } else {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            currentCity = placemark.administrativeArea;
            
        }
        currentCity = currentCity ? currentCity : @"北京市";
        
        if (![cityDictionary objectForKey:currentCity]) {
            AQIViewController *aqiVC = [[AQIViewController alloc]initWithCity:currentCity];
            [cityDictionary setObject:aqiVC forKey:currentCity];
        }
        
        [self updateAqiViews];
    }];
}
#pragma mark - PhotosCollectionViewControllerDelegate method

- (void) photosCollectionViewController:(PhotosCollectionViewController *)sender background:(NSString *) background {
    NSLog(@"%@", background);
    currentImageName  = background;
    [[NSUserDefaults standardUserDefaults]setObject:currentImageName forKey:@"background"];
    [self dismissViewControllerAnimated:true completion:nil];
}

#pragma mark - ButtonsViewControllerDelegate method
-(void)refreshAqiViews:(ButtonsViewController *)sender {
    NSLog(@"%@", @"refresh button pressed");
    for (NSString *citykey in cityDictionary) {
        AQIViewController *avc = [cityDictionary objectForKey:citykey];
        [avc updateAqiData];
    }
}

-(void)configButtonPressed:(ButtonsViewController *)sender {
    NSLog(@"%@", @"config button pressed");
    self.photosCollectionVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Photos"];
    self.photosCollectionVC.delegate = self;
    //self.navigationtroller mod
    [self presentViewController:self.photosCollectionVC animated:true completion:^{}];
}

@end