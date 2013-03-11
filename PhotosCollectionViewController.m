//
//  PhotosCollectionViewController.m
//  PM25
//
//  Created by xu yannan on 13-3-8.
//  Copyright (c) 2013年 BlueTiger. All rights reserved.
//

#import "PhotosCollectionViewController.h"

@interface PhotosCollectionViewController () <UICollectionViewDelegate>
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSArray *photosArray;
//@property (nonatomic, strong) int selected;
@end



@implementation PhotosCollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (UIImageView *)loadImage:(NSString *) name width:(float) width height:(float) height {
    UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:name]];
    [image setFrame:CGRectMake(image.frame.origin.x, image.frame.origin.y, width,  height)];
    return image;
}

- (void) viewWillAppear:(BOOL)animated {
    self.collectionView.delegate = self;
    self.photosArray = [[NSArray alloc]initWithObjects:@"background.jpg", @"background2.jpg", @"background3.jpg", nil];
    [super viewWillAppear:animated];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewControllerDelegate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    self.photos = [[NSMutableArray alloc]init];
    int w = 150;
    int h = 150;
    for (NSString *imageName in self.photosArray) {
        UIImageView *bg = [self loadImage:imageName width: w height:h];
        [self.photos addObject:bg];
    }
    return [self.photos count];
}
- (IBAction)backToMainView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Photo" forIndexPath:indexPath];
    if(!cell) {
        //cell = [[UICollectionViewCell alloc]initWithFrame:CGRectMake(0, 0, 72, 72)];
    }

    UIImageView *img = [self.photos objectAtIndex:indexPath.row];
    [cell addSubview:img];
    
    return cell;
}

-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *image = [self.photosArray objectAtIndex:indexPath.row];
    NSLog(@"%ld", (long)indexPath.row);
    [self.delegate photosCollectionViewController:self background: image];
}

@end
