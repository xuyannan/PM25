//
//  AqiAPI.m
//  PM25
//
//  Created by xu yannan on 13-3-11.
//  Copyright (c) 2013年 BlueTiger. All rights reserved.
//

#import "AqiAPI.h"
#import "DDXMLDocument.h"

#define APPKEY @"QfEJyi3oWKSBCnKrqp1v"

@implementation AqiData
-(NSString *) description {
    return [[NSString alloc]initWithFormat:@"aqi data of %@: aqi:%@, pm:%@, desc:%@, upate:%@",self.city, self.aqi, self.pm, self.desc, self.update ];
}
-(AqiData *) init {
    if (self = [super init]) {
        self.pm = @"pm2.5";
        self.desc = @"desc";
        self.update = @"right now";
        self.aqi = @"aqi";
    }
    return self;
}
@end

@implementation AqiAPI {
    NSDictionary *apiUrls;
    NSDictionary *usemUrls; // 美使馆/领事馆api地址
    NSArray *suppertedCities;
}

NSInteger sort(id name1, id name2, void *context) {
    NSString *u1, *u2;
    
    u1 = (NSString *)name1;
    u2 = (NSString *)name2;
    NSLog(@"%@,%@", u1,u2);
    NSComparisonResult r =  [u1 compare:u2];
    NSLog(@"%d", r);
    //NSLog(@"%@", u2);
    return [u1 localizedCompare:u2];
}


-(AqiAPI *) init {
    if (self = [super init]) {
        suppertedCities = @[@"保定",@"北京",@"沧州",@"常州",@"长春",@"长沙",@"成都",@"承德",@"大连",@"东莞",@"佛山",@"福州",@"广州",@"贵阳",@"哈尔滨",@"海口",@"邯郸",@"杭州",@"合肥",@"衡水",@"呼和浩特",@"湖州",@"淮安",@"惠州",@"济南",@"嘉兴",@"江门",@"金华",@"昆明",@"拉萨",@"兰州",@"廊坊",@"丽水",@"连云港",@"南昌",@"南京",@"南宁",@"南通",@"宁波",@"秦皇岛",@"青岛",@"衢州",@"厦门",@"上海",@"绍兴",@"沈阳",@"深圳",@"石家庄",@"苏州",@"宿迁",@"台州",@"太原",@"泰州",@"唐山",@"天津",@"温州",@"乌鲁木齐",@"无锡",@"武汉",@"西安",@"西宁",@"邢台",@"徐州",@"盐城",@"扬州",@"银川",@"张家口",@"肇庆",@"镇江",@"郑州",@"中山",@"重庆",@"舟山",@"珠海"];
        /*
        NSArray *a = [suppertedCities sortedArrayUsingComparator:^(id a, id b){
            NSString *u1 = (NSString *)a;
            NSString *u2 = (NSString *)b;
            return [u1 localizedCompare:u2];
        }];
        NSLog(@"%@", [a componentsJoinedByString:@","]);
        */
        
        apiUrls = [[NSDictionary alloc]initWithObjectsAndKeys:
            [NSURL URLWithString:@"http://pm25.in/api/querys.json"], @"supported_cities",
            @"http://pm25.in/api/querys/pm2_5.json", @"pm25",
            nil];
        
        NSURL *beijingUrl = [NSURL URLWithString:@"http://aqi.cutefool.net/beijing"];
        NSURL *guangzhouUrl = [NSURL URLWithString:@"http://aqi.cutefool.net/guangzhou"];
        NSURL *shanghaiUrl = [NSURL URLWithString:@"http://aqi.cutefool.net/shanghai"];
        NSURL *chengduUrl = [NSURL URLWithString:@"http://aqi.cutefool.net/chengdu"];
        
        usemUrls = [[NSDictionary alloc]initWithObjectsAndKeys:beijingUrl, @"北京",guangzhouUrl, @"广州", shanghaiUrl, @"上海", chengduUrl, @"成都", nil];
    }
    return self;
}

-(AqiAPI *) initWithCity:(NSString *)city {
    if (self = [super init]) {
        if (!city) {
            self.city = @"北京";
        } else {
            self.city = city;
        }
    }
    return self;

}

-(AqiData *)getChineseAqiDataForCity:(NSString *)city {
    AqiData *aqiData = [[AqiData alloc]init];
    if (![suppertedCities containsObject:city]) {
        NSLog(@"没有%@的数据", city);
        return nil;
    }
    NSLog(@"%@", city);
    NSArray *pmarray;
    NSArray *aqiarray;
    NSArray *desarray;
    NSArray *updatearray;
    NSString *url_str = [[NSString alloc]initWithFormat:@"%@?token=%@&city=%@", [apiUrls objectForKey:@"pm25"], APPKEY, city ];
    
    NSURL *url = [NSURL URLWithString: [url_str stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    [request setValue:@"text/json" forHTTPHeaderField:@"Content-Type"];
    NSHTTPURLResponse *response;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if(error != nil) {
        NSLog(@"net work error: %@", error);
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"sorry...无法加载气象站数据，请过会再试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        //[alert show];
        return nil;
    } else {
        NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        pmarray = [jsonData valueForKey:@"pm2_5"];
        aqiarray = [jsonData valueForKey:@"aqi"];
        desarray = [jsonData valueForKey:@"quality"];
        updatearray = [jsonData valueForKey:@"time_point"];
    }
    aqiData.pm = pmarray ? [[NSString alloc]initWithFormat:@"%@",[pmarray lastObject]] : @"--";
    aqiData.desc = desarray ? [desarray lastObject] : @"--";
    aqiData.aqi = aqiarray ? [[NSString alloc]initWithFormat:@"%@",[aqiarray lastObject]] : @"--";
    aqiData.update = updatearray ? [updatearray lastObject] : @"--";
    aqiData.city = self.city;
    NSLog(@"%@", [aqiData description]);
    return aqiData;
}

//读取美领事馆数据
- (AqiData *)getUsemAqiDataForCity:(NSString *)city {
    AqiData *aqiData = [[AqiData alloc]init];
    city = city ? city : self.city;
    NSLog(@"%@", city);
    NSURL *url = [usemUrls objectForKey: city? city : self.city];
    
    if (!url) {
        NSLog(@"no USEM data for city: %@", city);
        return nil;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    [request setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
    NSHTTPURLResponse *response;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if(error != nil) {
        NSLog(@"net work error: %@", error);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"sorry...无法加载美帝数据，请过会再试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return nil;
    } else {
        DDXMLDocument *xmlDoc = [[DDXMLDocument alloc] initWithData:data options:0 error: &error];
        if (error) {
            NSLog(@"parse xml error: %@", [error localizedDescription]);
        }
        
        NSArray *resultNodes = [xmlDoc nodesForXPath:@"//Conc | //AQI | //Desc | //ReadingDateTime" error:&error];
        
        if ( ! resultNodes || [resultNodes count] == 0) {
            NSLog(@"%@ 无数据", self.city);
            return nil;
        }
        
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
        while ([aqiArray objectAtIndex:zero ] && [[aqiArray objectAtIndex:zero ] isEqualToString:@"-1"]) {
            [pmArray removeObjectAtIndex: zero];
            [descArray removeObjectAtIndex: zero];
            [udpateArray removeObjectAtIndex: zero];
            [aqiArray removeObjectAtIndex: zero];
        }
        
        aqiData.pm = [pmArray objectAtIndex:zero];
        aqiData.desc = [descArray objectAtIndex:zero];
        aqiData.update = [udpateArray objectAtIndex:zero];
        aqiData.aqi = [aqiArray objectAtIndex:zero];
        
    }
    
    return aqiData;
}

- (AqiData *)getAqiDataForCity:(NSString *)city {
    [self getChineseAqiDataForCity:city];
    return [self getUsemAqiDataForCity:city];
}

-(bool)isUsemDataSupportedForCity:(NSString *)city {
    NSURL *url = [usemUrls objectForKey:city];
    if (url) {
        return YES;
    } else {
        return NO;
    }
}

-(bool)isChineseDataSupportedForCity:(NSString *)city {
    return [suppertedCities containsObject:city];
}

-(NSArray *)usemDataSupportedCities {
    return [usemUrls allKeys];
}

-(NSArray *)supportedCities {
    return suppertedCities;
}
@end
