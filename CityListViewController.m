//
//  CityListViewController.m
//  PM25
//
//  Created by xu yannan on 13-3-15.
//  Copyright (c) 2013年 BlueTiger. All rights reserved.
//

#import "CityListViewController.h"
#import "AqiAPI.h"

@interface CityListViewController () {
    NSArray *cities;
    NSMutableArray *selectedCities;
    NSArray *usemDataSupportedCities;
}

@end

#define CITY_LIST_KEY @"citylist"
@implementation CityListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    
    return self;
}

-(void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    AqiAPI *aqiApi = [[AqiAPI alloc]init];
    cities = [aqiApi supportedCities];
    selectedCities = [[NSUserDefaults standardUserDefaults] objectForKey:CITY_LIST_KEY];
    usemDataSupportedCities = [aqiApi usemDataSupportedCities];
    //[self.tableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //CGRect bounds = [[UIScreen mainScreen] bounds];
    //[self.tableView setFrame:CGRectMake(bounds.size.width, bounds.origin.y, 150, self.tableView.frame.size.height)];
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [cities count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell For City";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    NSString *city = [cities objectAtIndex: indexPath.row ];
    cell.textLabel.text = [[NSString alloc]initWithFormat:@"%@", city];
    if ([selectedCities containsObject:city]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    if ([usemDataSupportedCities containsObject:city]) {
        cell.detailTextLabel.text = @"支持美使馆数据";
    } else {
        cell.detailTextLabel.text = @"";
    }
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell) {
        NSString *city = [cities objectAtIndex:indexPath.row];
        if ([selectedCities containsObject:city]) {
            if ([selectedCities count] == 1) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"至少选一个城市" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
                return;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
                [selectedCities removeObject:city];
            }
        } else {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [selectedCities addObject:city];
        }
        NSLog(@"%@", [selectedCities componentsJoinedByString:@","]);
        [[NSUserDefaults standardUserDefaults] setObject:selectedCities forKey:CITY_LIST_KEY];
    }
}

@end
