//
//  ButtonsViewController.m
//  
//
//  Created by xu yannan on 13-3-12.
//
//

#import "ButtonsViewController.h"

@interface ButtonsViewController ()<ButtonsViewControllerDelegate>

@end

@implementation ButtonsViewController

- (IBAction)refresh:(id)sender {
    [self.delegate refreshAqiViews:self];
}
- (IBAction)showConfigView:(id)sender {
    [self.delegate configButtonPressed:self];
}


@end
