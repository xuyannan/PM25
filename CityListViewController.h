//
//  CityListViewController.h
//  PM25
//
//  Created by xu yannan on 13-3-15.
//  Copyright (c) 2013年 BlueTiger. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CityListViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@end
