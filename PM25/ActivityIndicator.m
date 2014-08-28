//
//  ActivityIndicator.m
//  PM25
//
//  Created by xuyannan on 8/27/14.
//  Copyright (c) 2014 BlueTiger. All rights reserved.
//

#import "ActivityIndicator.h"
#import "Constants.h"

@implementation ActivityIndicator

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        isShow = NO;
        int y = 0;
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        if ([window.rootViewController respondsToSelector:@selector(edgesForExtendedLayout)]) {
        } else {
            y = -20;
        }
        [self setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self addSubview: indicator];
        indicator.center = CGPointMake(SCREEN_WIDTH / 2, SCREEN_WIDTH / 2);
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
        
        titleLabel.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.center = CGPointMake(SCREEN_WIDTH / 2, SCREEN_WIDTH / 2 + 26);
        titleLabel.textColor = [UIColor colorWithWhite:1 alpha:.8];
        [self addSubview:titleLabel];
    }
    return self;
}

- (void) show {
    if (isShow) {
        return;
    }
    
    if (_title) {
        titleLabel.text = _title;
    }
    
    self.hidden = NO;
    isShow = YES;
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    UIView *topView = window.rootViewController.view;
    //[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:YES];
    [topView addSubview:self];
    [indicator startAnimating];
}

- (void) close {
    if (!isShow) {
        return;
    }
    self.hidden = YES;
    isShow = NO;
    [self removeFromSuperview];
}
@end
