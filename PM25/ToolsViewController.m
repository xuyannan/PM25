//
//  ToolsViewController.m
//  PM25
//
//  Created by xuyannan on 9/2/14.
//  Copyright (c) 2014 BlueTiger. All rights reserved.
//

#import "ToolsViewController.h"

@interface ToolsViewController ()

@end

@implementation ToolsViewController

- (IBAction)syncButtonPressed:(id)sender {
    [self.delegate refreshAqiViews:self];
}

- (IBAction)brushButtonPressed:(id)sender {
    [self.delegate configButtonPressed:self];
}

- (IBAction)shareButtonPressed:(id)sender {
    [self.delegate shareButtonPressed:self];
}




- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
