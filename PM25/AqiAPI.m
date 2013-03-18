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

-(AqiAPI *) init {
    if (self = [super init]) {
        suppertedCities = @[
                           @"上海",@"东莞",@"中山",
                           @"丽水",
                           @"乌鲁木齐",
                           @"佛山",
                           @"保定",
                           @"兰州",
                           @"北京",
                           @"南京",
                           @"南宁",
                           @"南昌",
                           @"南通",
                           @"厦门",
                           @"台州",
                           @"合肥",
                           @"呼和浩特",
                           @"哈尔滨",
                           @"唐山",
                           @"嘉兴",
                           @"大连",
                           @"天津",
                           @"太原",
                           @"宁波",
                           @"宿迁",
                           @"常州",
                           @"广州",
                           @"廊坊",
                           @"张家口",
                           @"徐州",
                           @"惠州",
                           @"成都",
                           @"扬州",
                           @"承德",
                           @"拉萨",
                           @"无锡",
                           @"昆明",
                           @"杭州",
                           @"武汉",
                           @"江门",
                           @"沈阳",
                           @"沧州",
                           @"泰州",
                           @"济南",
                           @"海口",
                           @"淮安",
                           @"深圳",
                           @"温州",
                           @"湖州",
                           @"珠海",
                           @"盐城",
                           @"石家庄",
                           @"福州",
                           @"秦皇岛",
                           @"绍兴",
                           @"肇庆",
                           @"舟山",
                           @"苏州",
                           @"衡水",
                           @"衢州",
                           @"西宁",
                           @"西安",
                           @"贵阳",
                           @"连云港",
                           @"邢台",
                           @"邯郸",
                           @"郑州",
                           @"重庆",
                           @"金华",
                           @"银川",
                           @"镇江",
                           @"长春",
                           @"长沙",
                           @"青岛"
        ];
        
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
    //if (![suppertedCities containsObject:city]) {
    //    return nil;
    //}
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
        return nil;
    } else {
        NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        pmarray = [jsonData valueForKey:@"pm2_5"];
        aqiarray = [jsonData valueForKey:@"aqi"];
        desarray = [jsonData valueForKey:@"quality"];
        updatearray = [jsonData valueForKey:@"time_point"];
    }
    aqiData.pm = [[NSString alloc]initWithFormat:@"%@",[pmarray lastObject]];
    aqiData.desc = [desarray lastObject];
    aqiData.aqi = [[NSString alloc]initWithFormat:@"%@",[aqiarray lastObject]];
    aqiData.update = [updatearray lastObject];
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
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    [request setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
    NSHTTPURLResponse *response;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if(error != nil) {
        NSLog(@"net work error: %@", error);
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

-(NSArray *)usemDataSupportedCities {
    return [usemUrls allKeys];
}

-(NSArray *)supportedCities {
    return suppertedCities;
}
@end
