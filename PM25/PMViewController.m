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

@interface PMViewController () <CLLocationManagerDelegate, PhotosCollectionViewControllerDelegate, UIScrollViewDelegate, ButtonsViewControllerDelegate,
UIGestureRecognizerDelegate, UIPageViewControllerDelegate, UIPageViewControllerDataSource> {
    NSString *currentCity;
    NSMutableDictionary *cityDictionary;
    NSMutableArray *cityArray;
    UIImageView *backgroundView;
    NSString *currentImageName;
    bool located; // 开关，控制只定位一次
    NSMutableArray *arrayOfAqiViewController;
}

@property(nonatomic, strong) CLLocationManager *locationManager;
@property(nonatomic, strong) UIScrollView *scrollView;
@property(nonatomic, strong) ButtonsViewController *buttonsVC;
@property(weak,nonatomic) PhotosCollectionViewController *photosCollectionVC;

@end

@implementation PMViewController
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    located = NO;
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
    //[self getReadyForScrollView];
    
    // buttons
    CGRect bounds = [[UIScreen mainScreen] bounds];
    self.buttonsVC = [[ButtonsViewController alloc]initWithNibName:@"ButtonsViewController" bundle:nil];
    [self.buttonsVC.view setFrame:CGRectMake(bounds.size.width - 120, bounds.size.height - 60, 90, 30)];
    [self.view addSubview: self.buttonsVC.view];
    self.buttonsVC.delegate = self;

    // 监听程序由background切换到foreground
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForegroundNotification) name:UIApplicationWillEnterForegroundNotification object:nil];
}

-(void) getReadyForPageView {
    if (!self.pageViewController) {
        CGRect bounds = [[UIScreen mainScreen]bounds];
        self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                                  navigationOrientation:UIPageViewControllerNavigationOrientationVertical
                                                                                options:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:50.0f] forKey:UIPageViewControllerOptionInterPageSpacingKey]];
        self.pageViewController.delegate = self;
        self.pageViewController.dataSource = self;
        [self.pageViewController.view setFrame: bounds];
        //self.view.gestureRecognizers = self.pageViewController.gestureRecognizers;
        //关键一步
        AQIViewController *avc = [arrayOfAqiViewController objectAtIndex: self.currentPageIndex];
        [self.pageViewController setViewControllers:@[avc] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        //preload next view
        if (self.currentPageIndex + 1 < [arrayOfAqiViewController count]) {
            AQIViewController *preloadAvc = [arrayOfAqiViewController objectAtIndex: (self.currentPageIndex + 1)];
            NSLog(@"preload data for city: %@", preloadAvc.city);
            [preloadAvc updateAqiData];
        }
    }
    [self.view insertSubview:self.pageViewController.view atIndex:1];
}

-(void) swipeLeft {
    NSLog(@"swipe left");
}


-(void)viewDidLoad {
    [super viewDidLoad];
    self.aqiViewController = [[AQIViewController alloc]initWithNibName:@"AQIViewController" bundle:nil];
    [self.scrollView addSubview:self.aqiViewController.view];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 100;
    [self.locationManager startUpdatingLocation];
    
    // guesture
    UISwipeGestureRecognizer *swipeLeftRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeLeft)];
    [swipeLeftRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft ];
    [self.view addGestureRecognizer:swipeLeftRecognizer];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

-(void)appWillEnterForegroundNotification {
    [self refreshAll];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.locationManager stopUpdatingLocation];
    //移除boserver
    [[NSNotificationCenter defaultCenter] removeObserver:self]; 
}

-(void) updateAqiForCity: (NSString *) city atIndex: (int) index {
    CGRect bounds = [[UIScreen mainScreen] bounds];
    AQIViewController *avc = [cityDictionary objectForKey:city];
        [avc.view setFrame:CGRectMake(0, index * bounds.size.height, bounds.size.width, bounds.size.height)];
    [self.scrollView addSubview:avc.view];
    [avc updateAqiData];
}

//更新所有AQIViewController
-(void) updateAqiViews {
    int index = 0;
    //当前城市放在首屏
    if (currentCity) {
        [self updateAqiForCity:currentCity atIndex:index];
        index ++;
    }
    for (NSString *citykey in cityDictionary) {
        if ([citykey isEqualToString:currentCity]) {
            continue;
        }
        [self updateAqiForCity:citykey atIndex:index];
        index ++;
    }
}

-(void) getReadyForAqiViewControllers {
    //当前城市放在第一个
    if (!arrayOfAqiViewController) {
        arrayOfAqiViewController = [[NSMutableArray alloc] init];
    }
    if (currentCity) {
        [arrayOfAqiViewController addObject: [cityDictionary objectForKey: currentCity]];
    }
    for (NSString *citykey in cityDictionary) {
        if ([citykey isEqualToString:currentCity]) {
            continue;
        }
        [arrayOfAqiViewController addObject: [cityDictionary objectForKey: citykey]];
    }
}

//更新所有城市数据
-(void) refreshAll {
    for (NSString *citykey in cityDictionary) {
        AQIViewController *avc = [cityDictionary objectForKey:citykey];
        [avc updateAqiData];
    }
}

#pragma mark - getReadyForScrollView

-(void)getReadyForScrollView {
    if (!self.scrollView) {
        CGRect bounds = [[UIScreen mainScreen]bounds];
        self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, bounds.size.width, bounds.size.height)];
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
        // 一次定位后，立即停止，防止多次定位
        [self.locationManager stopUpdatingLocation];
        if (error) {
            NSLog(@"Geocode failed with error: %@", error);
        } else {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            currentCity = placemark.administrativeArea;
            
        }
        currentCity = currentCity ? currentCity : @"北京市";
        if (![cityDictionary objectForKey:currentCity]) {
            AQIViewController *aqiVC = [[AQIViewController alloc]initWithCity:currentCity];
            [cityDictionary setObject:aqiVC forKey:currentCity];
        }
        if (!located) {
            //[self updateAqiViews];
            [self getReadyForAqiViewControllers];
            [self getReadyForPageView];
            located = YES;
        }
        
    }];
}
#pragma mark - PhotosCollectionViewControllerDelegate method

- (void) photosCollectionViewController:(PhotosCollectionViewController *)sender background:(NSString *) background {
    currentImageName  = background;
    [[NSUserDefaults standardUserDefaults]setObject:currentImageName forKey:@"background"];
    [self dismissViewControllerAnimated:true completion:nil];
}

#pragma mark - ButtonsViewControllerDelegate method
-(void)refreshAqiViews:(ButtonsViewController *)sender {
    NSLog(@"%@", @"refresh button pressed");
    [self refreshAll];
}

-(void)configButtonPressed:(ButtonsViewController *)sender {
    NSLog(@"%@", @"config button pressed");
    self.photosCollectionVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Photos"];
    self.photosCollectionVC.delegate = self;
    //self.navigationtroller mod
    [self presentViewController:self.photosCollectionVC animated:true completion:^{}];
}

#pragma mark - UIPageViewController method
-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    AQIViewController *currentAvc = (AQIViewController *) viewController;
    NSInteger currentIndex = [arrayOfAqiViewController indexOfObject:currentAvc];
    self.currentPageIndex = currentIndex;
    if (currentIndex == 0) {
        return nil;
    }
    AQIViewController *avc = [arrayOfAqiViewController objectAtIndex:currentIndex - 1];
    self.currentPageIndex -= 1;
    return avc;
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    AQIViewController *currentAvc = (AQIViewController *) viewController;
    
    //NSLog(@"curreont aqi view controller: %@" , [currentAvc description]);
    
    NSInteger currentIndex = [arrayOfAqiViewController indexOfObject:currentAvc];
    
    if (currentIndex == [arrayOfAqiViewController count] - 1) {
        return nil;
    }
    currentIndex ++;
    AQIViewController *avc = [arrayOfAqiViewController objectAtIndex:currentIndex];
    /*
    NSLog(@"--current page: %d, city is %@", currentIndex, avc.city);
    if (currentIndex + 1 < [arrayOfAqiViewController count] ) {
        AQIViewController *preloadAvc = [arrayOfAqiViewController objectAtIndex:(currentIndex + 1)];
        NSLog(@"preload data for city: %@", preloadAvc.city);
        [preloadAvc updateAqiData];
    }
     */
    self.currentPageIndex = currentIndex;
    return avc;

}

#pragma mark - UIPageViewDatasource method
-(NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return [arrayOfAqiViewController count];
}
/*
-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return NO;
}*/
@end