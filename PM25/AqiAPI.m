//
//  AqiAPI.m
//  PM25
//
//  Created by xu yannan on 13-3-11.
//  Copyright (c) 2013年 BlueTiger. All rights reserved.
//

#import "AqiAPI.h"
#import "DDXMLDocument.h"

@implementation AqiData
@end

@implementation AqiAPI

-(AqiAPI *) initWithCity:(NSString *)city {
    if (self = [super init]) {
        if (!city) {
            self.city = @"北京市";
        } else {
            self.city = city;
        }
    }
    return self;
}

- (AqiData *)getAqiData {
    AqiData *aqiData = [[AqiData alloc]init];
    NSURL *beijingUrl = [NSURL URLWithString:@"http://aqi.cutefool.net/beijing"];
    NSURL *guangzhouUrl = [NSURL URLWithString:@"http://aqi.cutefool.net/guangzhou"];
    NSURL *shanghaiUrl = [NSURL URLWithString:@"http://aqi.cutefool.net/shanghai"];
    NSURL *chengduUrl = [NSURL URLWithString:@"http://aqi.cutefool.net/chengdu"];
    
    NSDictionary *citiesInPinyin = [[NSDictionary alloc]initWithObjectsAndKeys:beijingUrl, @"北京市",guangzhouUrl, @"广州市", shanghaiUrl, @"上海市", chengduUrl, @"成都市", nil];
    
    NSURL *url = [citiesInPinyin objectForKey:self.city];
    
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
@end
