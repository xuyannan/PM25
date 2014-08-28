//
//  ActivityIndicator.h
//  PM25
//
//  Created by xuyannan on 8/27/14.
//  Copyright (c) 2014 BlueTiger. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ActivityIndicator : UIView {
    UIActivityIndicatorView *indicator;
    UILabel *titleLabel;
    Boolean isShow;
}

@property (nonatomic, strong) NSString *title;

- (void) show;
- (void) close;


@end
