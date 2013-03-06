//
//  ConfigViewController.m
//  PM25
//
//  Created by xu yannan on 13-2-22.
//  Copyright (c) 2013年 BlueTiger. All rights reserved.
//

#import "ConfigViewController.h"
#import "PMTimeConfigViewContoller.h"
#import "PMFrequencyConfigViewController.h"
#import "PMConfigItem.h"

@interface ConfigViewController () <PMTimeConfigViewContollerDelegate, PMFrequencyConfigViewControllerDelegate>
@property (nonatomic, strong) NSMutableArray *userConfigArray;
@end

@implementation ConfigViewController

//static const NSString *USER_CONFIG_KEY =  @"user_comfig";
#define USER_CONFIG_KEY @"user_config"


#pragma mark - PMTimeConfigViewControllerDelegate

-(void) pMTimeConfigViewContoller:(PMTimeConfigViewContoller *)sender timeStr:(NSString *)timeStr {
    NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:0];
    UITableViewCell *cell =  [self.tableView cellForRowAtIndexPath:index];
    cell.detailTextLabel.text = timeStr;
    self.userConfigArray[0] = timeStr;
    [[NSUserDefaults standardUserDefaults]setObject:self.userConfigArray forKey:USER_CONFIG_KEY];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        //self.tableView.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //self.navController = [[UINavigationController alloc] initWithRootViewController:self];
    NSString *time = @"8:00 AM";
    NSString *frequency = @"周一,周二";
    
    self.userConfigArray = [[NSUserDefaults standardUserDefaults] objectForKey:USER_CONFIG_KEY];
    if (!self.userConfigArray) {
        self.userConfigArray = [[NSMutableArray alloc]init];
        [self.userConfigArray addObject:time];
        [self.userConfigArray addObject:frequency];
        [[NSUserDefaults standardUserDefaults]setObject:self.userConfigArray forKey:USER_CONFIG_KEY];
    }

}
/*
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [segue.destinationViewController setDelegate:self];
}
*/
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - PMFrequencyViewControllerDelegate

-(void)pMFrequencyConfigViewController:(PMFrequencyConfigViewController *)sender selectedWeekDays:(NSArray *)selectedWeekDays {
    NSIndexPath *index = [NSIndexPath indexPathForRow:1 inSection:0];
    UITableViewCell *cell =  [self.tableView cellForRowAtIndexPath:index];
    cell.detailTextLabel.text = [selectedWeekDays componentsJoinedByString:@","];
    self.userConfigArray[1] = [selectedWeekDays componentsJoinedByString:@","];
    [[NSUserDefaults standardUserDefaults]setObject:self.userConfigArray forKey:USER_CONFIG_KEY];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.userConfigArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ConfigTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier];
    // Configure the cell...
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    if (indexPath.row == 0) {
        cell.textLabel.text = @"跑步时间";
        cell.detailTextLabel.text = [self.userConfigArray objectAtIndex:0];
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"跑步频率";
        cell.detailTextLabel.text = [self.userConfigArray objectAtIndex:1];
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
    /*
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    PMConfigItem *item = [self.userConfigArray objectAtIndex:indexPath.row];
    */
    if(indexPath.row == 0) {
        PMTimeConfigViewContoller *timeConfigViewController = [[self storyboard]instantiateViewControllerWithIdentifier:@"TimeConfigViewController"];
        [timeConfigViewController setDelegate:self];
        [self.navigationController pushViewController:timeConfigViewController animated:YES];
    } else if (indexPath.row == 1) {
        PMFrequencyConfigViewController *frequencyConfigViewController = [[self storyboard]instantiateViewControllerWithIdentifier:@"FrequencyConfigViewController"];
        [frequencyConfigViewController setDelegate:self];
        [self.navigationController pushViewController:frequencyConfigViewController animated:YES];
    }
    
    //self.navigationController
    
}

@end
