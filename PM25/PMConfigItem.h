//
//  PMConfigItem.h
//  PM25
//
//  Created by xu yannan on 13-2-28.
//  Copyright (c) 2013年 BlueTiger. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PMConfigItem : NSObject

@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *label;
@property (nonatomic, strong) NSString *defaultValue;

-(PMConfigItem *) init;
-(PMConfigItem * ) initWithKey:(NSString *) key
                         label:(NSString *) label
                  defaultValue:(NSString *) defaultValue;
-(NSString *) description;
@end
