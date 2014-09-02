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
#import "ActivityIndicator.h"
#import "Constants.h"

@interface AQIViewController ()  <UITableViewDataSource, UITableViewDelegate> {
    NSDictionary *citiesInPinyin;
    AqiAPI *aqiAPI;
    ActivityIndicator *indicator;
    NSString *shareContent;
}

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *aqiData;
@property (nonatomic) bool isLoaded;
@end

@implementation AQIViewController
@synthesize stationsDataTV;
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
    if (!indicator) {
        indicator = [[ActivityIndicator alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        indicator.title = NSLocalizedString(@"加载中，请稍候", nil); // @"加载中，请稍候...";
    }
    [indicator show];
    
    dispatch_queue_t getAqiDataQueue = dispatch_queue_create("get AQI data", NULL);
    dispatch_async(getAqiDataQueue, ^{
        
        [aqiAPI ajaxGetChineseApiDataForCity:self.city onSuccess:^(NSMutableArray *aqidata) {
            NSMutableArray *dataOfChinese = aqidata;
            if (dataOfChinese == nil || [dataOfChinese count] == 0) {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"无法获取数据，请稍候再试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [indicator close];
                [alertView show];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [indicator close];
                    AqiData *avgData = [dataOfChinese lastObject];
                    self.aqi.text = avgData.aqi;
                    self.pm.text = avgData.pm;
                    self.desc.text = avgData.desc;
                    if (avgData.desc.length > 3) {
                        [self.desc  setFont:[UIFont boldSystemFontOfSize:24]];
                    }
                    // 替换日期中的T和Z
                    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[TZ]" options:NSRegularExpressionCaseInsensitive error:nil];
                    NSString *update = [regex stringByReplacingMatchesInString:avgData.update options:0 range:NSMakeRange(0, [avgData.update length]) withTemplate:@""];
                    self.update.text = update;
                    self.aqiData = [dataOfChinese mutableCopy];
                    [self.aqiData removeLastObject];
                    [self.stationsDataTV reloadData];
                    shareContent = [NSString stringWithFormat:@"%@ 空气质量：%@，污染指数：%@，PM2.5浓度：%@。更新于 %@。分享自 %@", self.city, avgData.desc, avgData.aqi, avgData.pm, update, WEIAIR_WEIBO];
                });
            }
        } onError:^{
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"无法获取数据，请稍候再试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [indicator close];
            [alertView show];
        }];
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
    UIColor *transColor = [[UIColor alloc]initWithRed:0 green:0 blue:0 alpha:0.2];
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
    
    self.stationsDataTV.delegate = self;
    self.stationsDataTV.dataSource = self;

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
- (void) getCurretnPmValue {
    NSURL *url;
    NSLog(@"%@", @"refresh...");
    
    NSString *currentCity;
    currentCity = self.city ? self.city : @"北京";
    
    url = [citiesInPinyin objectForKey: currentCity];
    
}

#pragma mark - custom cell's subview
- (void) customTextView: (UITextView *) textView {
    textView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 15);
    [textView setFont:[UIFont systemFontOfSize:16]];
    [textView setTextColor: [UIColor colorWithWhite:1 alpha:1]];
    textView.backgroundColor = [UIColor clearColor];
}

#pragma mark - UITableViewController method
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.aqiData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell For Station";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    int lineHeight = 20;
    UITextView *stationNameVC = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, 150, lineHeight)];
    UITextView *dataVC = [[UITextView alloc]initWithFrame:CGRectMake(stationNameVC.frame.size.width, 0, 150, lineHeight)];
    [self customTextView:stationNameVC];
    [self customTextView:dataVC];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        [cell addSubview:stationNameVC];
        [cell addSubview:dataVC];
    } else {
    }
    
    AqiData *data = [self.aqiData objectAtIndex:indexPath.row];
    cell.backgroundColor = [UIColor clearColor];
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [UIColor clearColor];
    
    stationNameVC.text = data.station;
    dataVC.text =  [NSString stringWithFormat:@"%@ / %@", data.aqi, data.pm];
    cell.selectedBackgroundView = selectionColor;
    cell.textLabel.textColor = [UIColor colorWithWhite:1 alpha:1];
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}

-(NSString *)getShareContent {
    if (shareContent == nil || [shareContent length] == 0) {
        return WEIAIR_WEIBO;
    }
    return shareContent;
}

@end
