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

#define CELL_W 150
#define CELL_H 150


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
    //double scale =  CELL_W / image.image.size.width;
    //image.bounds = CGRectMake(0,0,100, 100);
    //NSLog(@"%f", scale);
    image.contentMode = UIViewContentModeTopLeft;
    
    [image setFrame:CGRectMake(image.frame.origin.x, image.frame.origin.y, width, width)];
    return image;
}

- (void) viewWillAppear:(BOOL)animated {
    self.collectionView.delegate = self;
    self.photosArray = [[NSArray alloc]initWithObjects:@"background.jpg", @"background2.jpg", @"background3.jpg", @"sunset.jpg", nil];
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

    for (NSString *imageName in self.photosArray) {
        UIImageView *bg = [self loadImage:imageName width: CELL_W height:CELL_H];
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
    
    NSString *imageName = [[NSUserDefaults standardUserDefaults] objectForKey:@"background"];
    double checkmark_size = 24;
    double checkmark_adjuest = 4;
    if (imageName && [imageName isEqualToString: [self.photosArray objectAtIndex: indexPath.row ]]) {
        UIImageView *checkmark = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"checkmark.png"]];
        checkmark.frame = CGRectMake( CELL_W-checkmark_size-checkmark_adjuest, CELL_H-checkmark_size-checkmark_adjuest, checkmark_size , checkmark_size );
        //checkmark.bounds.origin.x = 100;
        [cell addSubview:checkmark];
    }
    return cell;
}

-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *image = [self.photosArray objectAtIndex:indexPath.row];
    NSLog(@"%ld", (long)indexPath.row);
    [self.delegate photosCollectionViewController:self background: image];
}

@end
