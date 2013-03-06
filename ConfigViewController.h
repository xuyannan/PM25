//
//  ConfigViewController.h
//  PM25
//
//  Created by xu yannan on 13-2-22.
//  Copyright (c) 2013年 BlueTiger. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConfigViewController : UITableViewController
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableDictionary *userConfig;

//@property (nonatomic, strong) UINavigationController *navController;
@end
