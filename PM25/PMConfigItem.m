//
//  PMConfigItem.m
//  PM25
//
//  Created by xu yannan on 13-2-28.
//  Copyright (c) 2013年 BlueTiger. All rights reserved.
//

#import "PMConfigItem.h"

@implementation PMConfigItem
/*
@synthesize key;
@synthesize label;
@synthesize defaultValue;
*/

-(PMConfigItem *) init {
    if(self = [super init]) {
        self.key = @"key";
        self.defaultValue = @"default";
        self.label = @"配置项";
    }
    return self;
}


-(PMConfigItem *) initWithKey:(NSString *)key label:(NSString *)label defaultValue:(NSString *)defaultValue {
    if(self = [super init]) {
        self.key = key;
        self.label = label;
        self.defaultValue = defaultValue;
    }
    return self;
}

-(NSString *) description {
    return [[NSString alloc]initWithFormat:@"key: %@, label: %@, value: %@", self.key, self.label, self.defaultValue ];
}
@end
