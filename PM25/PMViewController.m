//
//  PMViewController.m
//  PM25
//
//  Created by xu yannan on 13-2-21.
//  Copyright (c) 2013年 BlueTiger. All rights reserved.
//

#import "PMViewController.h"
#import "DDXMLDocument.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManager.h>

@interface PMViewController () <CLLocationManagerDelegate> {
    NSDictionary *citiesInPinyin;
}
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic)  int pm;
@property (nonatomic, strong) NSMutableArray *pms;
@property (nonatomic, strong) NSString *city;

@end

@interface PMValue : NSObject
@property NSString *pm;
@property NSString *update;
@property NSString *desc;
@end

@implementation PMViewController

// 获取实时PM2.5数据
-(void) getCurretnPmValue {
    NSURL *url;
    NSLog(@"%@", @"refresh...");
    
    NSString *currentCity;
    currentCity = self.city ? self.city : @"北京市";
    
    url = [citiesInPinyin objectForKey: currentCity];
    
    dispatch_queue_t getPmQueue = dispatch_queue_create("get pm value", NULL);
    dispatch_async(getPmQueue, ^{
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
        NSHTTPURLResponse *response;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
        NSError *error = nil;
        DDXMLDocument *xmlDoc = [[DDXMLDocument alloc] initWithData:data options:0 error: &error];
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
        }
        
        NSArray *resultNodes = [xmlDoc nodesForXPath:@"//Conc | //AQI | //Desc | //ReadingDateTime" error:&error];
        
        NSMutableArray *pmArray = [[NSMutableArray alloc] init];
        NSMutableArray *aqiArray = [[NSMutableArray alloc] init];
        NSMutableArray *descArray = [[NSMutableArray alloc] init];
        NSMutableArray *udpateArray = [[NSMutableArray alloc] init];
        //DDXMLElement *latestNode = resultNodes[0];
        
        for (DDXMLElement *resultElement in resultNodes) {
            NSString *name = [resultElement name];
            NSString *value = [resultElement stringValue];
            
            if ([name isEqualToString:@"Conc"]) {
                [pmArray addObject: value];
            } else if ([name isEqualToString:@"AQI"]) {
                [aqiArray addObject: value];
            } else if ([name isEqualToString:@"Desc"]) {
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\(.*\\)" options:NSRegularExpressionCaseInsensitive error:nil];
                NSString *modifiedValue = [regex stringByReplacingMatchesInString:value options:0 range:NSMakeRange(0, [value length]) withTemplate:@""];
                [descArray addObject: modifiedValue];
            } else if ([name isEqualToString:@"ReadingDateTime"]) {
                [udpateArray addObject: value];
            }
        }
        NSInteger zero = [[[NSNumber alloc]initWithInt:0] integerValue];
        // 排除未读表的情况
        if ([[aqiArray objectAtIndex:zero ] isEqualToString:@"-1"]) {
            [pmArray removeObjectAtIndex: zero];
            [descArray removeObjectAtIndex: zero];
            [udpateArray removeObjectAtIndex: zero];
            [aqiArray removeObjectAtIndex: zero];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.pmValue.text = [pmArray objectAtIndex:zero];
            self.result.text = [descArray objectAtIndex:zero];
            self.updateTime.text = [udpateArray objectAtIndex:zero];
            self.aqiValue.text = [aqiArray objectAtIndex:zero];
            self.currentCity.text = currentCity;
            self.refreshButton.titleLabel.text = @"刷新"; // = [UIBUtton alloc] initWi
            self.refreshButton.enabled = YES;
        });
        
    });
    //dispatch_release(getPmQueue);

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSURL *beijingUrl = [NSURL URLWithString:@"http://www.beijingaqifeed.com/BeijingAQI/BeijingAir.xml"];
    NSURL *guangzhouUrl = [NSURL URLWithString:@"http://www.beijingaqifeed.com/gzaqi/guangzhouairrss.xml"];
    NSURL *shanghaiUrl = [NSURL URLWithString:@"http://www.beijingaqifeed.com/shanghaiaqi/shanghaiairrss.xml"];
    NSURL *chengduUrl = [NSURL URLWithString:@"http://www.beijingaqifeed.com/chengduaqi/chengduairrss.xml"];
    
    citiesInPinyin = [[NSDictionary alloc]initWithObjectsAndKeys:beijingUrl, @"北京市",guangzhouUrl, @"广州市", shanghaiUrl, @"上海市", chengduUrl, @"成都市", nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    // self.locationManager.locationServicesEnabled = true;
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 10;
    [self.locationManager startUpdatingLocation];
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.locationManager stopUpdatingLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)refresh:(UIButton *)sender {
    self.refreshButton.titleLabel.text = @"读取中...";
    self.refreshButton.enabled = NO;
    [self getCurretnPmValue];
}

#pragma mark - CLLocationManagerDelegate method


-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation *location = [locations objectAtIndex:0];
    NSLog(@"lat:%f - lon:%f", location.coordinate.latitude, location.coordinate.longitude);
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            NSLog(@"Geocode failed with error: %@", error);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"无法获取当前城市，请手动设置" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        } else {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            NSLog(@"city: %@, code: %@", placemark.administrativeArea, placemark.locality);
            self.city = placemark.administrativeArea;
        }
        [self getCurretnPmValue];
        
    }];
}


@end