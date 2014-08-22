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
#import "CityListViewController.h"
#import "AqiAPI.h"

#define CITY_LIST_KEY @"citylist"
#define BACKGROUND_LAYER_INDEX 0
#define PAGEVIEW_LAYER_INDEX 1
#define BUTTONS_LAYER_INDEX 2

@interface PMViewController () <CLLocationManagerDelegate, PhotosCollectionViewControllerDelegate, ButtonsViewControllerDelegate,
UIGestureRecognizerDelegate, UIPageViewControllerDelegate, UIPageViewControllerDataSource> {
    NSString *currentCity;
    NSMutableDictionary *cityDictionary;
    NSMutableArray *cityArray;
    UIImageView *backgroundView;
    NSString *currentImageName;
    bool located; // 开关，控制只定位一次
    NSMutableArray *arrayOfAqiViewController;
    int cityListVCOffset;
    NSMutableArray *oldCityArray;
    
    AqiAPI *aqiAPI;
}

@property(nonatomic, strong) CLLocationManager *locationManager;
//@property(nonatomic, strong) UIScrollView *scrollView;
@property(nonatomic, strong) ButtonsViewController *buttonsVC;
@property(strong,nonatomic) PhotosCollectionViewController *photosCollectionVC;
@property(strong,nonatomic) CityListViewController *cityListVC;

@end

@implementation PMViewController
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.locationManager requestAlwaysAuthorization];
    located = NO;
    cityListVCOffset = 150;
    aqiAPI = [[AqiAPI alloc]init];
    
    CGRect bounds = [[UIScreen mainScreen] bounds];
    bounds = [self.view frame];
    
    cityArray = [[NSUserDefaults standardUserDefaults] objectForKey:CITY_LIST_KEY];
    if (!cityArray) {
        cityArray = [[NSMutableArray alloc]init];
        [cityArray addObject:@"北京"];
        [cityArray addObject:@"广州"];
        [cityArray addObject:@"上海"];
        [cityArray addObject:@"成都"];
        [[NSUserDefaults standardUserDefaults] setObject:cityArray forKey:CITY_LIST_KEY];
    }
    oldCityArray = [cityArray mutableCopy];
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
    [backgroundView setFrame:CGRectMake(0, 0 , self.view.frame.size.width, self.view.frame.size.height)];
    [self.view insertSubview:backgroundView atIndex:BACKGROUND_LAYER_INDEX];

    // buttons
    if (self.buttonsVC) {
        [self.buttonsVC.view removeFromSuperview];
    }
    self.buttonsVC = [[ButtonsViewController alloc]initWithNibName:@"ButtonsViewController" bundle:nil];
    [self.buttonsVC.view setFrame:CGRectMake(self.view.frame.size.width - 100, self.view.frame.size.height - 40 , 90, 30)];
    [self.view insertSubview:self.buttonsVC.view atIndex:BUTTONS_LAYER_INDEX];
    self.buttonsVC.delegate = self;
    // 监听程序由background切换到foreground
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForegroundNotification) name:UIApplicationWillEnterForegroundNotification object:nil];
}

-(void) getReadyForPageView {
    if (!self.pageViewController) {
        CGRect bounds = [[UIScreen mainScreen]bounds];
        bounds = self.view.bounds;
        self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                                  navigationOrientation:UIPageViewControllerNavigationOrientationVertical
                                                                                options:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:50.0f] forKey:UIPageViewControllerOptionInterPageSpacingKey]];
        self.pageViewController.delegate = self;
        self.pageViewController.dataSource = self;
        [self.pageViewController.view setFrame: bounds];
        AQIViewController *avc = [arrayOfAqiViewController objectAtIndex: self.currentPageIndex];
        // pageview的关键一步，设置要显示的页
        [self.pageViewController setViewControllers:@[avc] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    }
    [self.view insertSubview:self.pageViewController.view atIndex:PAGEVIEW_LAYER_INDEX];
}


-(void) swipeLeft {
    NSLog(@"swipe left");
    [self showCityList];

}

-(void) swipeRight {
    NSLog(@"swipe right");
    [self hideCityList];
    NSMutableArray *newCityArray = [[NSUserDefaults standardUserDefaults] objectForKey:CITY_LIST_KEY];
    //NSLog(@"%@", [newCityArray componentsJoinedByString:@","]);
    //NSLog(@"%@", [oldCityArray componentsJoinedByString:@","]);
    for (NSString *city in newCityArray) {
        // 加入了新的城市
        if (![oldCityArray containsObject:city]) {
            AQIViewController *aqiVC = [cityDictionary objectForKey:city];
            if (!aqiVC) {
                aqiVC = [[AQIViewController alloc]initWithCity: city];
            }
            
            [cityDictionary setObject:aqiVC forKey:city];
            [arrayOfAqiViewController addObject:aqiVC];
            //count ++;
        }
    }
    for (NSString *city in oldCityArray) {
        // 删除的城市
        if (![newCityArray containsObject:city]) {
            AQIViewController *aqiVC = [cityDictionary objectForKey:city];
            [arrayOfAqiViewController removeObject:aqiVC];
        }
    }
    
    self.currentPageIndex = 0;
    AQIViewController *avc = [arrayOfAqiViewController objectAtIndex: self.currentPageIndex];
    [self.pageViewController setViewControllers:@[avc] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    oldCityArray = [cityArray mutableCopy];
}



-(void)viewDidLoad {
    [super viewDidLoad];
    [self.locationManager startUpdatingLocation];
    self.aqiViewController = [[AQIViewController alloc]initWithNibName:@"AQIViewController" bundle:nil];
    
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
    
    UISwipeGestureRecognizer *swipeRightRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight)];
    [swipeRightRecognizer setDirection:UISwipeGestureRecognizerDirectionRight ];
    [self.view addGestureRecognizer:swipeRightRecognizer];
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

#pragma mark - CLLocationManagerDelegate method

-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *location = [locations objectAtIndex:0];
    
    NSLog(@"lat:%f - lon:%f", location.coordinate.latitude, location.coordinate.longitude);
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!located) {
            // 一次定位后，立即停止，防止多次定位
            [self.locationManager stopUpdatingLocation];
            if (error) {
                NSLog(@"Geocode failed with error: %@", error);
            } else {
                CLPlacemark *placemark = [placemarks objectAtIndex:0];
                currentCity = placemark.locality;
            }
            currentCity = currentCity ? currentCity : @"北京";
            // 去掉"市"
            NSString *fixedCityName;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"市$" options:NSRegularExpressionCaseInsensitive error:nil];
            fixedCityName = [regex stringByReplacingMatchesInString:currentCity options:0 range:NSMakeRange(0, [currentCity length]) withTemplate:@""];
            currentCity = fixedCityName;
            
            if ([aqiAPI isChineseDataSupportedForCity:currentCity]) {
                if (![cityArray containsObject:currentCity]) {
                    [cityArray addObject:currentCity];
                    [[NSUserDefaults standardUserDefaults]setObject:cityArray forKey:CITY_LIST_KEY];
                }
                
                if (![cityDictionary objectForKey:currentCity]) {
                    AQIViewController *aqiVC = [[AQIViewController alloc]initWithCity:currentCity];
                    [cityDictionary setObject:aqiVC forKey:currentCity];
                }
            } else {
                NSString *message = [[NSString alloc]initWithFormat:@"您所处的[%@]目前还没有空气质量数据。请向左滑动屏幕添加您所关心的城市~", currentCity];
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
                currentCity = [cityArray objectAtIndex:0];
            }
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
    if (!self.photosCollectionVC) {
        self.photosCollectionVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Photos"];
        self.photosCollectionVC.delegate = self;
    }
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
    
    NSInteger currentIndex = [arrayOfAqiViewController indexOfObject:currentAvc];
    
    if (currentIndex == [arrayOfAqiViewController count] - 1) {
        return nil;
    }
    currentIndex ++;
    AQIViewController *avc = [arrayOfAqiViewController objectAtIndex:currentIndex];
    self.currentPageIndex = currentIndex;
    return avc;

}

#pragma mark - UIPageViewDatasource method
-(NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return [arrayOfAqiViewController count];
}

#pragma  mark - control CityListViewController
-(void) showCityList {
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGRect bounds = self.view.frame;
    //挪mainView
    [UIView beginAnimations:@"MoveViews" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    if (bounds.size.width - screenBounds.size.width >= cityListVCOffset) {
        [self.view setFrame:CGRectMake(0- cityListVCOffset, bounds.origin.y, bounds.size.width, bounds.size.height)];
    } else {
        [self.view setFrame:CGRectMake(0- cityListVCOffset, bounds.origin.y, bounds.size.width+cityListVCOffset, bounds.size.height)];
    }
    //挪buttonView
    [self.buttonsVC.view setFrame:CGRectMake(200, self.view.frame.size.height - 40 , 90, 30)];
    [UIView commitAnimations];
    
    if (!self.cityListVC) {
        self.cityListVC = [[CityListViewController alloc]initWithNibName:@"CityListViewController" bundle:nil];
        [self.cityListVC.tableView setFrame:CGRectMake(bounds.size.width,0,150,bounds.size.height)];
        [self.view addSubview:self.cityListVC.tableView];
    }
    
}

-(void) hideCityList {
    CGRect bounds = self.view.frame;
    if (!self.cityListVC) {
        return;
    }
    [UIView beginAnimations:@"MoveViews" context:nil];
    [UIView setAnimationDuration:0.1];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [self.view setFrame:CGRectMake(0, bounds.origin.y, bounds.size.width, bounds.size.height)];
    
    //挪buttonView;
    [self.buttonsVC.view setFrame:CGRectMake(200, self.view.frame.size.height - 40 , 90, 30)];
    [UIView commitAnimations];
}

@end