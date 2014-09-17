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
#import "ToolsViewController.h"
#import "CityListViewController.h"
#import "AqiAPI.h"
#import "ActivityIndicator.h"
#import "Constants.h"
#import "PhotoUtil.h"
#import "UMSocial.h"

#define CITY_LIST_KEY @"citylist"
#define BACKGROUND_LAYER_INDEX 0
#define PAGEVIEW_LAYER_INDEX 1
#define BUTTONS_LAYER_INDEX 2

@interface PMViewController () <CLLocationManagerDelegate, PhotosCollectionViewControllerDelegate, UIActionSheetDelegate ,ToolsViewControllerDelegate,UIGestureRecognizerDelegate, UIPageViewControllerDelegate, UIPageViewControllerDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
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
    ActivityIndicator *indicator;
}

@property(nonatomic, strong) CLLocationManager *locationManager;
//@property(nonatomic, strong) UIScrollView *scrollView;
@property(nonatomic, strong) ToolsViewController *buttonsVC;
@property(strong,nonatomic) PhotosCollectionViewController *photosCollectionVC;
@property(strong,nonatomic) CityListViewController *cityListVC;

@property (assign,nonatomic) NSInteger willTurnToPageIndex;
@property (strong, nonatomic) UIImagePickerController *imagePicker;

@end


@implementation PMViewController
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.locationManager requestWhenInUseAuthorization];
    located = NO;
    cityListVCOffset = 200;
    aqiAPI = [[AqiAPI alloc]init];
    
    CGRect bounds = [[UIScreen mainScreen] bounds];
    bounds = [self.view frame];
    
    
    cityArray = [[NSUserDefaults standardUserDefaults] objectForKey:CITY_LIST_KEY];
    if (!cityArray) {
        cityArray = [[NSMutableArray alloc]init];
        [[NSUserDefaults standardUserDefaults] setObject:cityArray forKey:CITY_LIST_KEY];
    }
    if (!cityDictionary) {
        cityDictionary = [[NSMutableDictionary alloc]init];
    }
    for (NSString *city in cityArray) {
        AQIViewController *aqiVC = [[AQIViewController alloc]initWithCity: city];
        if (aqiVC != nil) {
            [cityDictionary setObject:aqiVC forKey:city];
        }
    }

    // 监听程序由background切换到foreground
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForegroundNotification) name:UIApplicationWillEnterForegroundNotification object:nil];
}

-(void) getReadyForPageView {
    if (!self.pageViewController) {
        CGRect bounds = [[UIScreen mainScreen]bounds];
        bounds = self.view.bounds;
        self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                                  navigationOrientation:UIPageViewControllerNavigationOrientationVertical
                                                                                options:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:20.0f] forKey:UIPageViewControllerOptionInterPageSpacingKey]];
        self.pageViewController.delegate = self;
        self.pageViewController.dataSource = self;
        [self.pageViewController.view setFrame: bounds];
    }
    [self.view insertSubview:self.pageViewController.view atIndex:PAGEVIEW_LAYER_INDEX];
    [self refreshPageView];
}

- (void) refreshPageView {
    if ([arrayOfAqiViewController count] > 0) {
        AQIViewController *avc = [arrayOfAqiViewController objectAtIndex: self.currentPageIndex];
        // pageview的关键一步，设置要显示的页
        [self.pageViewController setViewControllers:@[avc] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    } else {
        NSLog(@"%@", @"没有任何城市");
    }
}


-(void) swipeLeft {
    NSLog(@"swipe left");
    [self showCityList];

}

-(void) swipeRight {
    NSLog(@"swipe right");
    NSMutableArray *newCityArray = [[[NSUserDefaults standardUserDefaults] objectForKey:CITY_LIST_KEY] mutableCopy];
    for (NSString *city in newCityArray) {
        NSLog(@"%@", city);
    }
    if (newCityArray == nil  || [newCityArray count] == 0) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"至少选一个城市" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    [self hideCityList];
    oldCityArray = [cityArray mutableCopy];
    cityArray = oldCityArray;
    
    if (arrayOfAqiViewController == nil) {
        arrayOfAqiViewController = [[NSMutableArray alloc] init];
    }
    
    for (NSString *city in newCityArray) {
        // 加入了新的城市
        if (![oldCityArray containsObject:city]) {
            AQIViewController *aqiVC = [cityDictionary objectForKey:city];
            if (!aqiVC) {
                aqiVC = [[AQIViewController alloc]initWithCity: city];
            }
            
            [cityDictionary setObject:aqiVC forKey:city];
            [arrayOfAqiViewController addObject:aqiVC];
            [cityArray addObject:city];
            //count ++;
        }
    }
    NSMutableArray *tmpAvcArray = [arrayOfAqiViewController mutableCopy];
    NSMutableArray *tmpCityArray = [cityArray mutableCopy];
    for (NSString *city in oldCityArray) {
        // 删除的城市
        if (![newCityArray containsObject:city]) {
            AQIViewController *aqiVC = [cityDictionary objectForKey:city];
            
            [tmpAvcArray removeObject:aqiVC];
            [tmpCityArray removeObject:city];
        }
    }
    arrayOfAqiViewController = tmpAvcArray;
    cityArray = tmpCityArray;
    
    self.currentPageIndex = 0;
    AQIViewController *avc = [arrayOfAqiViewController objectAtIndex: self.currentPageIndex];
    [self.pageViewController setViewControllers:@[avc] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    self.aqiViewController = [[AQIViewController alloc]initWithNibName:@"AQIViewController" bundle:nil];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 100;
    [self.locationManager startUpdatingLocation];
    
    cityArray = [[NSUserDefaults standardUserDefaults] objectForKey:CITY_LIST_KEY];
    [self getReadyForPageView];
    [self getReadyForAqiViewControllers];
    
    // guesture
    UISwipeGestureRecognizer *swipeLeftRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeLeft)];
    [swipeLeftRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft ];
    [self.view addGestureRecognizer:swipeLeftRecognizer];
    
    UISwipeGestureRecognizer *swipeRightRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight)];
    [swipeRightRecognizer setDirection:UISwipeGestureRecognizerDirectionRight ];
    [self.view addGestureRecognizer:swipeRightRecognizer];
    [self setBackground];
    
    self.buttonsVC = [[ToolsViewController alloc]initWithNibName:@"ToolsViewController" bundle:nil];
    [self.view insertSubview:self.buttonsVC.view atIndex: BUTTONS_LAYER_INDEX];
    self.buttonsVC.delegate = self;
    [self setButtonsView];
    
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

-(void)appWillEnterForegroundNotification {
    [self refreshCurrentCity];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.locationManager stopUpdatingLocation];
    //移除boserver
    [[NSNotificationCenter defaultCenter] removeObserver:self]; 
}

- (bool) isCityInArray:(NSString *) city {
    for (AQIViewController *avc in arrayOfAqiViewController) {
        if (avc.city == city) {
            return YES;
        }
    }
    return NO;
}


-(void) getReadyForAqiViewControllers {
    //当前城市放在第一个
    if (!arrayOfAqiViewController) {
        arrayOfAqiViewController = [[NSMutableArray alloc] init];
    }
    
    if (!cityDictionary) {
        cityDictionary = [[NSMutableDictionary alloc] init];
    }
    
    if (cityArray != nil && [cityArray count] > 0) {
        for (NSString *city in cityArray) {
            if ([cityDictionary objectForKey:city] != nil) {
                if(![self isCityInArray: city]) {
                    [arrayOfAqiViewController addObject:[cityDictionary objectForKey:city]];
                }
            } else {
                AQIViewController *aqiVC = [[AQIViewController alloc] initWithCity:city];
                [cityDictionary setObject:aqiVC forKey:city];
                if(![self isCityInArray: city]) {
                    [arrayOfAqiViewController addObject:aqiVC];
                }
            }
        }
    }
    
    //定位到了当前城市
    if (currentCity) {
        if([cityDictionary objectForKey: currentCity] != nil) {
        } else {
            AQIViewController *aqiVC = [[AQIViewController alloc] initWithCity:currentCity];
            [cityDictionary setObject:aqiVC forKey:currentCity];
        }
        if(![self isCityInArray: currentCity]) {
            [arrayOfAqiViewController addObject:[cityDictionary objectForKey:currentCity]];
        }
    }
    [self refreshPageView];
}

//更新某城市数据
-(void) refreshCurrentCity {
    AQIViewController *currentAQIVC = [arrayOfAqiViewController objectAtIndex:self.currentPageIndex];
    for (AQIViewController *avc in arrayOfAqiViewController) {
        NSLog(@"%@", avc.city);
    }
    [currentAQIVC updateAqiData];
}

#pragma mark - CLLocationManagerDelegate method

-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *location = [locations objectAtIndex:0];
    
    NSLog(@"lat:%f - lon:%f", location.coordinate.latitude, location.coordinate.longitude);
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    if (!indicator) {
        indicator = [[ActivityIndicator alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        indicator.title = NSLocalizedString(@"加载中，请稍候", nil); // @"加载中，请稍候...";
    }
    [indicator show];
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!located) {
            [self getReadyForPageView];
            // 一次定位后，立即停止，防止多次定位
            [self.locationManager stopUpdatingLocation];
            cityArray = [[NSUserDefaults standardUserDefaults] objectForKey:CITY_LIST_KEY];
            if (error) {
                NSLog(@"Geocode failed with error: %@", error);
                [indicator close];
                if (cityArray == nil || cityArray.count == 0) {
                    NSString *message = [[NSString alloc]initWithFormat:@"无法定位您目前所在的城市，请在列表进行选择"];
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alert show];
                    [self showCityList];
                } else {
                    NSString *message = [[NSString alloc]initWithFormat:@"无法定位您目前所在的城市"];
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alert show];
                    //[self getReadyForAqiViewControllers];
                    //[self getReadyForPageView];
                }
            } else {
                CLPlacemark *placemark = [placemarks objectAtIndex:0];
                currentCity = placemark.locality;
                NSLog(@"localtiy:%@,  country: %@, name: %@", placemark.locality, placemark.country, placemark.name);
                [indicator close];
                //currentCity = currentCity ? currentCity : @"北京";
                // 去掉"市"
                NSString *fixedCityName;
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"市.*$" options:NSRegularExpressionCaseInsensitive error:nil];
                fixedCityName = [regex stringByReplacingMatchesInString:currentCity options:0 range:NSMakeRange(0, [currentCity length]) withTemplate:@""];
                currentCity = fixedCityName;
                
                //currentCity = @"London";

                if ([aqiAPI isChineseDataSupportedForCity:currentCity]) {
                    if (![cityArray containsObject:currentCity]) {
                        NSMutableArray *tmpArray = [cityArray mutableCopy];
                        [tmpArray insertObject:currentCity atIndex:0];
                        cityArray = tmpArray;
                        [[NSUserDefaults standardUserDefaults]setObject:cityArray forKey:CITY_LIST_KEY];
                    }
                    
                    if ([cityDictionary objectForKey:currentCity]) {
                        AQIViewController *aqiVC = [[AQIViewController alloc]initWithCity:currentCity];
                        [cityDictionary setObject:aqiVC forKey:currentCity];
                    }
                    
                    [self getReadyForAqiViewControllers];
                    [self refreshPageView];
                    located = YES;
                } else {
                    NSString *message = [[NSString alloc]initWithFormat:@"您所处的[%@]目前还没有空气质量数据。请在列表中添加您所关心的城市", currentCity];
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alert show];
                    [self showCityList];
                    currentCity = nil;
                }
            }
        }
        
    }];
}

-(void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    cityArray = [[NSUserDefaults standardUserDefaults] objectForKey:CITY_LIST_KEY];
    NSString *message = [[NSString alloc]initWithFormat:@"无法定位您的位置，请确认已您充许本APP使用您的地址"];
    if (cityArray == nil || [cityArray count] == 0) {
        message = [[NSString alloc]initWithFormat:@"无法定位您的位置，请确认已您充许本APP使用您的地址。您可以从列表中选择您所关注的城市。"];
        [self showCityList];
    }
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
    [self getReadyForAqiViewControllers];
    [self getReadyForPageView];
    located = false;
}

#pragma mark - showActionSheet
- (void)showActionSheet {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"修改背景图" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从相册中选一张", @"用相机拍一张", @"换回默认背景", nil];
    [actionSheet showInView:self.view];
}

#pragma mark - blur image tool function
- (UIImage *)blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur {
    CIImage *inputImage = [CIImage imageWithCGImage:image.CGImage];
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"
                                  keysAndValues:kCIInputImageKey, inputImage,
                        @"inputRadius", @(blur), nil];
    
    CIImage *outputImage = filter.outputImage;
    CIContext *context = [CIContext contextWithOptions:nil]; // save it to self.context
    CGImageRef outImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
    return [UIImage imageWithCGImage:outImage];
}

#pragma mark - set background image
- (void) setBackground {
    currentImageName = [[NSUserDefaults standardUserDefaults]objectForKey:@"background"];
    currentImageName = currentImageName ? currentImageName : @"background.jpg";
    UIImage *tmpImage = [PhotoUtil loadImage:currentImageName];
    UIImage *blurBackgroundImg = [self blurryImage:tmpImage withBlurLevel:2];
    
    if(backgroundView) {
        [backgroundView setImage:blurBackgroundImg];
    } else {
        backgroundView = [[UIImageView alloc] initWithImage:blurBackgroundImg];
        [backgroundView setFrame:CGRectMake(0, 0 , self.view.frame.size.width, self.view.frame.size.height)];
        [self.view insertSubview:backgroundView atIndex:BACKGROUND_LAYER_INDEX];
        //[self.view addSubview:backgroundView];
    }
    //[indicator close];
}

#pragma mark - set buttons view
- (void) setButtonsView {
    [self.buttonsVC.view setFrame:CGRectMake(-1, self.view.frame.size.height - 40 , 160, 30)];
    
}

#pragma mark - PhotosCollectionViewControllerDelegate method

- (void) photosCollectionViewController:(PhotosCollectionViewController *)sender background:(NSString *) background {
    currentImageName  = background;
    [[NSUserDefaults standardUserDefaults]setObject:currentImageName forKey:@"background"];
    [self setBackground];
    [self dismissViewControllerAnimated:true completion:^{
        [self setButtonsView];
    }];
}

#pragma mark - ButtonsViewControllerDelegate method
-(void)refreshAqiViews:(ToolsViewController *)sender {
    NSLog(@"%@", @"refresh button pressed");
    [self refreshCurrentCity];
    
}

-(void)configButtonPressed:(ToolsViewController *)sender {
    NSLog(@"%@", @"config button pressed");
    /*
    if (!self.photosCollectionVC) {
        self.photosCollectionVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Photos"];
        self.photosCollectionVC.delegate = self;
    }
    [self presentViewController:self.photosCollectionVC animated:true completion:^{}];*/
    [self showActionSheet];
}

-(void) shareButtonPressed:(ToolsViewController *)sender {
    AQIViewController *avc = [arrayOfAqiViewController objectAtIndex: self.currentPageIndex];
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:nil
                                      shareText:[avc getShareContent]
                                     shareImage:nil //[UIImage imageNamed:@"icon.png"]
                                shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina, UMShareToSms, UMShareToTencent, UMShareToRenren, nil]
                                       delegate:nil];
}

#pragma mark - UIPageViewController method
-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    AQIViewController *currentAvc = (AQIViewController *) viewController;
    NSInteger currentIndex = [arrayOfAqiViewController indexOfObject:currentAvc];
    if (currentIndex == 0) {
        self.currentPageIndex = 0;
        return nil;
    }
    AQIViewController *avc = [arrayOfAqiViewController objectAtIndex:currentIndex - 1];
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
    return avc;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (completed) {
        AQIViewController *vc = (AQIViewController *)[previousViewControllers lastObject];
        NSInteger index = [arrayOfAqiViewController indexOfObject:vc];
        //NSLog(@"已转向，之前是: %@, index: %ld", vc.city, index);
        if (index > self.willTurnToPageIndex) {
            self.currentPageIndex = index - 1;
        } else {
            self.currentPageIndex = index + 1;
        }
    }
}

-(void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
    AQIViewController *vc = (AQIViewController *)[pendingViewControllers objectAtIndex:0];
    self.willTurnToPageIndex = [arrayOfAqiViewController indexOfObject:vc];
    //NSLog(@"即将转向:%@, index: %ld", vc.city, (long)[arrayOfAqiViewController indexOfObject:vc]);
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
    //[UIView beginAnimations:@"MoveViews" context:nil];
    //[UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];

    //[UIView commitAnimations];
    [UIView animateWithDuration:0.3 animations:^(){
        if (bounds.size.width - screenBounds.size.width >= cityListVCOffset) {
            [self.view setFrame:CGRectMake(0- cityListVCOffset, bounds.origin.y, bounds.size.width, bounds.size.height)];
        } else {
            [self.view setFrame:CGRectMake(0- cityListVCOffset, bounds.origin.y, bounds.size.width+cityListVCOffset, bounds.size.height)];
        }
    } completion:^(BOOL finished){
        if (!self.cityListVC) {
            self.cityListVC = [[CityListViewController alloc]initWithNibName:@"CityListViewController" bundle:nil];
            [self.cityListVC.tableView setFrame:CGRectMake(bounds.size.width,0,200,bounds.size.height)];
            [self.view addSubview:self.cityListVC.tableView];
        }
        [self setButtonsView];
    }];
    // 缓存当前城市列表
    oldCityArray = [cityArray mutableCopy];
}

-(void) hideCityList {
    CGRect bounds = self.view.frame;
    if (!self.cityListVC) {
        return;
    }
    //[UIView beginAnimations:@"MoveViews" context:nil];
    //[UIView setAnimationDuration:0.1];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView animateWithDuration:0.1 animations:^{
        [self.view setFrame:CGRectMake(0, bounds.origin.y, bounds.size.width, bounds.size.height)];
    } completion:^(BOOL finished){
        [self setButtonsView];
    }];
}

#pragma mark - UIActionSheetDelegate method
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ( buttonIndex == 0 || buttonIndex == 1) {
        if (!_imagePicker) {
            _imagePicker = [[UIImagePickerController alloc] init];
            _imagePicker.delegate = self;
            _imagePicker.allowsEditing = NO;
        }
    }
    
    if (buttonIndex == 0) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:_imagePicker animated:YES completion:nil];
            
        }
    } else if (buttonIndex == 1) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            _imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:_imagePicker animated:YES completion:nil];
        }
    } else if (buttonIndex == 2) {
        [[NSUserDefaults standardUserDefaults]setObject:@"background.jpg" forKey:@"background"];
        [self setBackground];
    }
}

#pragma mark - UIImagePickerControllerDelegate method
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES completion:nil];
    // background
    indicator = [[ActivityIndicator alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    indicator.title = NSLocalizedString(@"图片处理中，请稍候", nil);
    [indicator show];
    [PhotoUtil savePhoto:image completion:^(NSString *filename){
        [[NSUserDefaults standardUserDefaults]setObject:filename forKey:@"background"];
        [self setBackground];
        [indicator close];
    } error:nil];

    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        [PhotoUtil savePhotoToAlbum:image albumName:@"微空气"];
    }
}

@end