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
//#define APPKEY @"5j1znBVAsnSf5xQyNQyq"

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
        self.station = @"";
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
    //NSComparisonResult r =  [u1 compare:u2];
    //NSLog(@"%@", u2);
    return [u1 localizedCompare:u2];
}


-(AqiAPI *) init {
    if (self = [super init]) {
        suppertedCities = @[@"三亚",@"三门峡",@"上海",@"东莞",@"东营",@"中山",@"临安",@"临汾",@"临沂",@"丹东",@"丽水",@"义乌",@"乌鲁木齐",@"九江",@"乳山",@"云浮",@"佛山",@"保定",@"克拉玛依",@"兰州",@"包头",@"北京",@"北海",@"南京",@"南充",@"南宁",@"南昌",@"南通",@"即墨",@"厦门",@"句容",@"台州",@"合肥",@"吉林",@"吴江",@"呼和浩特",@"咸阳",@"哈尔滨",@"唐山",@"嘉兴",@"嘉峪关",@"大同",@"大庆",@"大连",@"天津",@"太仓",@"太原",@"威海",@"宁波",@"安阳",@"宜兴",@"宜宾",@"宜昌",@"宝鸡",@"宿迁",@"富阳",@"寿光",@"岳阳",@"常州",@"常德",@"常熟",@"平度",@"平顶山",@"广州",@"库尔勒",@"廊坊",@"延安",@"开封",@"张家口",@"张家港",@"张家界",@"徐州",@"德州",@"德阳",@"惠州",@"成都",@"扬州",@"承德",@"抚顺",@"拉萨",@"招远",@"揭阳",@"攀枝花",@"文登",@"无锡",@"日照",@"昆山",@"昆明",@"曲靖",@"本溪",@"杭州",@"枣庄",@"柳州",@"株洲",@"桂林",@"梅州",@"武汉",@"汕头",@"汕尾",@"江门",@"江阴",@"沈阳",@"沧州",@"河源",@"泉州",@"泰安",@"泰州",@"泸州",@"洛阳",@"济南",@"济宁",@"海口",@"海门",@"淄博",@"淮安",@"深圳",@"清远",@"温州",@"渭南",@"湖州",@"湘潭",@"湛江",@"溧阳",@"滨州",@"潍坊",@"潮州",@"烟台",@"焦作",@"牡丹江",@"玉溪",@"珠海",@"瓦房店",@"盐城",@"盘锦",@"石嘴山",@"石家庄",@"福州",@"秦皇岛",@"章丘",@"绍兴",@"绵阳",@"聊城",@"肇庆",@"胶南",@"胶州",@"自贡",@"舟山",@"芜湖",@"苏州",@"茂名",@"荆州",@"荣成",@"莱州",@"莱芜",@"莱西",@"菏泽",@"营口",@"葫芦岛",@"蓬莱",@"衡水",@"衢州",@"西宁",@"西安",@"诸暨",@"贵阳",@"赤峰",@"连云港",@"遵义",@"邢台",@"邯郸",@"郑州",@"鄂尔多斯",@"重庆",@"金华",@"金坛",@"金昌",@"铜川",@"银川",@"锦州",@"镇江",@"长春",@"长沙",@"长治",@"阳江",@"阳泉",@"青岛",@"鞍山",@"韶关",@"马鞍山",@"齐齐哈尔"];
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


- (void) ajaxGetChineseApiDataForCity:(NSString *) city onSuccess:(void (^)(NSMutableArray *aqidata))onSuccess onError:(void (^)())onError {
    if (![suppertedCities containsObject:city]) {
        NSLog(@"没有%@的数据", city);
        //return nil;
    }
    NSLog(@"%@", city);
    NSString *url_str = [[NSString alloc]initWithFormat:@"%@?token=%@&city=%@", [apiUrls objectForKey:@"pm25"], APPKEY, city ];
    
    NSURL *url = [NSURL URLWithString: [url_str stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    [request setValue:@"text/json" forHTTPHeaderField:@"Content-Type"];
    //NSHTTPURLResponse *response;
    //NSError *error = nil;
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError != nil) {
            onError();
        } else {
            @try {
                NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                if([jsonData isKindOfClass:[NSDictionary class]]) {
                    NSLog(@"调用PM25.in出错: %@", [jsonData valueForKey:@"error"]);
                    onError();
                } else {
                    NSMutableArray *aqiData = [[NSMutableArray alloc] init];
                    NSArray *pmarray;
                    NSArray *aqiarray;
                    NSArray *desarray;
                    NSArray *updatearray;
                    NSArray *stationarray;
                    pmarray = [jsonData valueForKey:@"pm2_5"];
                    aqiarray = [jsonData valueForKey:@"aqi"];
                    desarray = [jsonData valueForKey:@"quality"];
                    updatearray = [jsonData valueForKey:@"time_point"];
                    stationarray = [jsonData valueForKey:@"position_name"];
                    for (int i = 0; i < pmarray.count; i ++ ) {
                        AqiData *_aqiData = [[AqiData alloc]init];
                        _aqiData.pm = [NSString stringWithFormat:@"%@", [pmarray objectAtIndex:i]];
                        _aqiData.desc = [desarray objectAtIndex:i];
                        _aqiData.aqi = [NSString stringWithFormat:@"%@", [aqiarray objectAtIndex:i]];
                        _aqiData.update = [updatearray objectAtIndex:i];
                        _aqiData.city = self.city;
                        _aqiData.station = [stationarray objectAtIndex:i];
                        [aqiData addObject:_aqiData];
                    }
                    onSuccess(aqiData);
                }
                
            }
            @catch (NSException *exception) {
                //return nil;
                onError();
            }
            @finally {
                //return nil;
            }
        }
    }];

}

-(NSMutableArray *)getChineseAqiDataForCity:(NSString *)city {
    NSMutableArray *aqiData = [[NSMutableArray alloc] init];
    if (![suppertedCities containsObject:city]) {
        NSLog(@"没有%@的数据", city);
        return nil;
    }
    NSLog(@"%@", city);
    NSArray *pmarray;
    NSArray *aqiarray;
    NSArray *desarray;
    NSArray *updatearray;
    NSArray *stationarray;
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
        @try {
            NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            if ([jsonData valueForKey:@"error"] != nil) {
                NSLog(@"PM25 请求出错: %@", [jsonData valueForKey:@"error"]);
                return nil;
            }
            pmarray = [jsonData valueForKey:@"pm2_5"];
            aqiarray = [jsonData valueForKey:@"aqi"];
            desarray = [jsonData valueForKey:@"quality"];
            updatearray = [jsonData valueForKey:@"time_point"];
            stationarray = [jsonData valueForKey:@"position_name"];
        }
        @catch (NSException *exception) {
            return nil;
        }
        @finally {
            return nil;
        }
        
    }
    //int iMax = pmarray.count;
    for (int i = 0; i < pmarray.count; i ++ ) {
        AqiData *_aqiData = [[AqiData alloc]init];
        _aqiData.pm = [NSString stringWithFormat:@"%@", [pmarray objectAtIndex:i]];
        _aqiData.desc = [desarray objectAtIndex:i];
        _aqiData.aqi = [NSString stringWithFormat:@"%@", [aqiarray objectAtIndex:i]];
        _aqiData.update = [updatearray objectAtIndex:i];
        _aqiData.city = self.city;
        _aqiData.station = [stationarray objectAtIndex:i];
        [aqiData addObject:_aqiData];
    }
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

- (NSMutableArray *)getAqiDataForCity:(NSString *)city {
    return [self getChineseAqiDataForCity:city];
    //return [self getUsemAqiDataForCity:city];
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
