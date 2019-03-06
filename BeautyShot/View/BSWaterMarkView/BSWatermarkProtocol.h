//
//  WMWatermarkProtocol.h
//  Blast
//
//  Created by leon on 8/16/16.
//  Copyright © 2016 codoon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BSMaterialProtocol.h"

@protocol BSWatermarkMaterialProtocol <NSObject>
@required
// 百分比（按1080x1080计算的百分比），一个方向只能有一个有效的
@property (nonatomic, assign) NSInteger top;
@property (nonatomic, assign) NSInteger left;
@property (nonatomic, assign) NSInteger bottom;
@property (nonatomic, assign) NSInteger right;

- (NSAttributedString *)attributedMaterialText;
- (UIImage *)materialImage;
/**
 * 获取放大后的文字
 * @param scaleRatio 放大比例
 */
- (NSAttributedString *)scaledAttributedMaterialText:(CGFloat)scaleRatio;

@end

@protocol BSWatermarkProtocol <BSMaterialProtocol>
@required
- (UIImage *)thumbnail;
- (NSURL *)thumbnailURL;
- (NSString *)text;
- (NSString *)hashtag;
- (NSURL *)hashtagURL;

- (UIImage *)imgWatermark;
- (UIImage *)imgWatermarkWithSize:(CGSize)size;
- (id<BSWatermarkMaterialProtocol>)waterMarkImageTypeMaterial;
/**
 * 根据水印文字 返回指定文字图片大小
 */
- (UIImage *)waterMarkMaterialTextImage:(CGSize)size;
/**
 * 根据水印文字 返回指定文字图片大小
 @parm material 指定水印
 */
- (UIImage*)waterMarkMaterialTextImage:(CGSize)size material:(id<BSWatermarkMaterialProtocol>)material;
/*
 * 水印文字详情
 */
- (NSMutableArray<id<BSWatermarkMaterialProtocol>>*)waterMarkTextTypeMaterial;
- (NSArray<id<BSWatermarkMaterialProtocol>> *)materials;
@end


