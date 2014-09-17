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
    NSMutableArray *cities;
    NSMutableArray *selectedCities;
    NSArray *usemDataSupportedCities;
    NSMutableArray *citiesCache;
    AqiAPI *aqiApi;
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
    aqiApi = [[AqiAPI alloc]init];
    cities = [[aqiApi supportedCities] mutableCopy];
    citiesCache = [cities mutableCopy];
    selectedCities = [[[NSUserDefaults standardUserDefaults] objectForKey:CITY_LIST_KEY] mutableCopy];
    usemDataSupportedCities = [aqiApi usemDataSupportedCities];
    [self.tableView reloadData];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.searchBar.delegate = self;
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    
    //cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"table_bg.png"]];
    UIView* bgview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    bgview.opaque = YES;
    bgview.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"table_bg.png"]];
    [cell setBackgroundView:bgview];
    
    // Configure the cell...
    NSString *city = [cities objectAtIndex: indexPath.row ];
    cell.textLabel.text = [[NSString alloc]initWithFormat:@"%@", city];
    cell.textLabel.textColor = [UIColor colorWithWhite:1 alpha:1 ];

    
    //cell.detailTextLabel.textColor = [UIColor colorWithWhite:1 alpha:1 ];
    [cell.textLabel setBackgroundColor:[UIColor colorWithWhite:1 alpha:0 ]];
    [cell.detailTextLabel setBackgroundColor:[UIColor colorWithWhite:1 alpha:0 ]];
    if ([selectedCities containsObject:city]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    if ([usemDataSupportedCities containsObject:city]) {
        //cell.detailTextLabel.text = @"支持美使馆数据";
        cell.detailTextLabel.text = @"";
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

#pragma mark - UISearchBarDelegate
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    citiesCache = [[aqiApi supportedCities]mutableCopy];
    if([searchText isEqualToString:@""] || searchText==nil){
        cities = citiesCache;
        [self.tableView reloadData];
        return;
    }
    
    [cities removeAllObjects];
    for (NSString *city in citiesCache) {
        NSRange r = [city rangeOfString:searchText];
        if(r.location != NSNotFound) {
            if(r.location== 0)//that is we are checking only the start of the names.
            {
                [cities addObject:city];
            }
        }
    }
    [self.tableView reloadData];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    cities = [[aqiApi supportedCities] mutableCopy];
    [self.tableView reloadData];
}

@end
