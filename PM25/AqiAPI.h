//
//  AqiAPI.h
//  PM25
//
//  Created by xu yannan on 13-3-11.
//  Copyright (c) 2013年 BlueTiger. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AqiData : NSObject
@property (copy, nonatomic) NSString *pm;
@property (copy, nonatomic) NSString *aqi;
@property (copy, nonatomic) NSString *update;
@property (copy, nonatomic) NSString *desc;
@property (copy, nonatomic) NSString *city;
-(NSString *) description;
-(AqiData *) init;
@end


@interface AqiAPI : NSObject
@property (strong, nonatomic) NSString *city;
-(AqiAPI *) initWithCity:(NSString *)city;
-(AqiData *) getAqiDataForCity:(NSString *)city;
-(AqiData *) getUsemAqiDataForCity:(NSString *)city;
-(AqiData *) getChineseAqiDataForCity:(NSString *)city;

-(bool) isChineseDataSupportedForCity:(NSString *)city;

-(bool) isUsemDataSupportedForCity:(NSString *)city;
-(NSArray *) usemDataSupportedCities;
-(NSArray *) supportedCities;
@end

