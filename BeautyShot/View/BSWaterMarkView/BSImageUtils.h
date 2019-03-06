//
//  WMImageUtils.h
//  WMCamera
//
//  Created by leon on 11/12/15.
//  Copyright © 2015 Codoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BSImageUtils : NSObject

+ (UIImage *)cropImageAsMaxSquare:(UIImage *)aImage;

+ (UIImage *)cropImage:(UIImage *)aImage usingCropRect:(CGRect)cropRect;

+ (UIImage *)compressImage:(UIImage *)aImage maxSize:(CGSize)maxSize;

+ (UIImage *)transparentImageSize:(CGSize)size;

+ (UIImage *)addImage:(UIImage *)aImage overlay:(UIImage *)overlay atPoint:(CGPoint)point;

+ (UIImage *)addImage:(UIImage *)aImage overlay:(UIImage *)overlay inRect:(CGRect)rect;

+ (UIImage *)addTheImageWithOutScale:(UIImage *)aImage overlay:(UIImage *)overlay inCenterPoint:(CGPoint)center;

+ (UIImage *)captureLayer:(CALayer *)layer;

+ (UIImage *)captureLayer:(CALayer *)layer scale:(CGFloat)scale;

+ (UIImage *)compressImageData:(NSData *)imageData maxPixelSize:(CGFloat)maxPixelSize;

+ (UIImage *)fixOrientationForImage:(UIImage *)aImage;

+ (UIImage *)fixOrientationForImage:(UIImage *)aImage oritation:(UIDeviceOrientation)oritation frontCamera:(BOOL)frontCamera;

+ (UIImage *)transformImageWithImage:(UIImage *)image transform:(CGAffineTransform)rotateTransform;

+ (CGSize)compressSize:(CGSize)size maxSize:(CGSize)maxSize;

+ (UIImage *)grayImage:(UIImage *)srcImage;

@end
