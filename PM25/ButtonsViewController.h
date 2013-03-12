//
//  ButtonsViewController.h
//  
//
//  Created by xu yannan on 13-3-12.
//
//

#import <UIKit/UIKit.h>
@class ButtonsViewController;

@protocol ButtonsViewControllerDelegate <NSObject>
@optional
-(void) refreshAqiViews :(ButtonsViewController *) sender;
-(void) configButtonPressed: (ButtonsViewController *) sender;
@end

@interface ButtonsViewController : UIViewController
@property (weak, nonatomic) id <ButtonsViewControllerDelegate> delegate;
@end
