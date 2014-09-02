//
//  PhotoUtil.h
//  PM25
//
//  Created by xuyannan on 9/2/14.
//  Copyright (c) 2014 BlueTiger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface PhotoUtil : NSObject
// 保存UIImage对象到app document，返回生成的照片名，失败的话返回nil
+ (NSString *) savePhoto: (UIImage *) image;
+ (void) savePhoto: (UIImage *) image completion:(void(^)(NSString *))callback error:(void(^)(void))error;

+ (void) savePhoto:(UIImage *) image named:(NSString *)filename;

// 保存ALAsset对象(系统中的照片)到appdocument
+ (NSString *) saveAsset: (ALAsset *) asset;

// 加载照片，返回UIImage对象
+ (UIImage *) loadImage:(NSString *) filename;

// 将照片存到指定的目录
+ (void) savePhotoToAlbum: (UIImage *)image albumName:(NSString *) albumName;
@end
