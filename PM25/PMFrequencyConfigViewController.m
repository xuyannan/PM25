//
//  PMFrequencyConfigViewController.m
//  PM25
//
//  Created by xu yannan on 13-2-22.
//  Copyright (c) 2013年 BlueTiger. All rights reserved.
//

#import "PMFrequencyConfigViewController.h"
#import "ConfigViewController.h"

#define USER_CONFIG_KEY @"user_config"

@interface PMFrequencyConfigViewController ()
@property (nonatomic, strong)  NSArray *weekdays;
@property (nonatomic, strong)  NSMutableArray *selectedWeekdays;
@end

@implementation PMFrequencyConfigViewController


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidDisappear:(BOOL)animated {
    [self.delegate pMFrequencyConfigViewController:self selectedWeekDays:self.selectedWeekdays];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.weekdays = [[NSArray alloc] initWithObjects:@"周一", @"周二",@"周三",@"周四",@"周五",@"周六",@"周日", nil];
    self.selectedWeekdays = [[NSMutableArray alloc] init];
    NSArray *userConfigArray = [[NSUserDefaults standardUserDefaults] objectForKey:USER_CONFIG_KEY];
    NSString *daysStr = [userConfigArray objectAtIndex:1];
    if (daysStr) {
        self.selectedWeekdays = [[NSMutableArray alloc]initWithArray:[daysStr componentsSeparatedByString:@","]];
    } else {
        self.selectedWeekdays = [[NSMutableArray alloc]init];
    }
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
    return [self.weekdays count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"WeekDayCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier];
    
    // Configure the cell...
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [self.weekdays objectAtIndex: indexPath.row];
    
    NSString *thisWeekDay = [self.weekdays objectAtIndex: indexPath.row];

    if ([self.selectedWeekdays containsObject:thisWeekDay]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (! [self.selectedWeekdays containsObject:[self.weekdays objectAtIndex:indexPath.row] ]) {
        [self.selectedWeekdays addObject: [self.weekdays objectAtIndex: indexPath.row] ];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.selectedWeekdays removeObject:[self.weekdays objectAtIndex:indexPath.row]];
    }
    //NSLog(@"%@", [self.selectedWeekdays description]);
    
} 

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"WeekDayCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier];
    if (cell) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}


@end
