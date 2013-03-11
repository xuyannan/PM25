//
//  PhotosCollectionViewController.h
//  PM25
//
//  Created by xu yannan on 13-3-8.
//  Copyright (c) 2013年 BlueTiger. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PhotosCollectionViewController;

@protocol PhotosCollectionViewControllerDelegate <NSObject>
-(void) photosCollectionViewController: (PhotosCollectionViewController *) sender
                       background: (NSString *)background;
@end

@interface PhotosCollectionViewController : UICollectionViewController
@property (weak, nonatomic) IBOutlet UICollectionView *photosView;
@property (nonatomic, weak) id <PhotosCollectionViewControllerDelegate> delegate;

@end
