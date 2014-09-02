//
//  ToolsViewController.h
//  PM25
//
//  Created by xuyannan on 9/2/14.
//  Copyright (c) 2014 BlueTiger. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ToolsViewController;

@protocol ToolsViewControllerDelegate <NSObject>
@optional
-(void) refreshAqiViews :(ToolsViewController *) sender;
-(void) configButtonPressed: (ToolsViewController *) sender;
-(void) shareButtonPressed: (ToolsViewController *) sender;

@end

@interface ToolsViewController : UIViewController
@property (weak, nonatomic) id <ToolsViewControllerDelegate> delegate;
@end
