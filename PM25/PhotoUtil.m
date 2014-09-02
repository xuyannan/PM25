//
//  PhotoUtil.m
//  PM25
//
//  Created by xuyannan on 9/2/14.
//  Copyright (c) 2014 BlueTiger. All rights reserved.
//

#import "PhotoUtil.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"

@implementation PhotoUtil
+ (NSString *) savePhoto:(UIImage *)image {
    // 生成文件名
    CFUUIDRef uuidObj = CFUUIDCreate(nil);//create a new UUID
    NSString *uuidString = (NSString*)CFBridgingRelease(CFUUIDCreateString(nil, uuidObj));
    CFRelease(uuidObj);
    NSString *filename = [[NSString alloc] initWithFormat:@"%@%@",[uuidString substringToIndex:16], @".jpg" ];
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:filename];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0f);
    if ([imageData writeToFile:imagePath atomically:YES]) {
        return filename;
    } else {
        NSLog(@"saveing photo error");
        return nil;
    }
}

+ (void) savePhotoToAlbum: (UIImage *)image albumName:(NSString *) albumName {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    if (!albumName) {
        albumName = NSLocalizedString(@"appname", nil);
    }
    [library saveImage:image toAlbum:albumName withCompletionBlock:^(NSError *error) {
        if (error) {
            NSLog(@"error save image to albumn");
        }
    }];
    
}

+ (NSString *)saveAsset:(ALAsset *)asset {
    CGImageRef ref = [asset.defaultRepresentation fullResolutionImage];
    [asset.defaultRepresentation fullResolutionImage];
    UIImage *image = [UIImage imageWithCGImage:ref];
    return [self savePhoto:image];
}

+ (UIImage *)loadImage:(NSString *)filename {
    UIImage *image = [UIImage imageNamed:filename];
    if (image != nil) {
        return image;
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:filename];
    return [UIImage imageWithContentsOfFile:imagePath];
}

+ (UIImage *)createThumbnail:(UIImage *)image size:(CGSize)size {
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        if ([[UIScreen mainScreen] scale] == 2.0) {
            UIGraphicsBeginImageContextWithOptions(size, YES, 2.0);
        } else {
            UIGraphicsBeginImageContext(size);
        }
    } else {
        UIGraphicsBeginImageContext(size);
    }
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (void) savePhoto:(UIImage *)image named:(NSString *)filename {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:filename];
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0f);
    if ([imageData writeToFile:imagePath atomically:YES]) {
        NSLog(@"saveing photo %@ success", filename);
    } else {
        NSLog(@"saveing photo error");
    }
}

+ (void) savePhoto:(UIImage *)image completion:(void (^)(NSString *))callback error:(void (^)(void))error {
    dispatch_queue_t savePhotoQueue = dispatch_queue_create("save photo", NULL);
    dispatch_async(savePhotoQueue, ^{
        NSString *filename = [PhotoUtil savePhoto:image];
        if(!filename && !error) {
            error();
        } else if (callback) {
            callback(filename);
        }
    });
}

@end
