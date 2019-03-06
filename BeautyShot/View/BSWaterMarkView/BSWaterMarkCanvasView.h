//
//  WMWaterMarkCanvasView.h
//  Runtopia
//
//  Created by jsonmess on 21/05/2018.
//  Copyright © 2018 codoon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSWatermarkProtocol.h"

#define WaterMarkMaxCount   1 //最大支持水印数量

@class BSWaterMarkView;
@class BSWaterMarkItem;

/**
 * 水印贴纸Canvas
 * 管理和添加多个 贴纸
 */
@interface BSWaterMarkCanvasView : UIView

/**
 * 添加水印/贴纸
 * @param waterMark
 */
- (void)addWaterMarkWithMarkImage:(BSWaterMarkItem *)waterMark;

/**
 * 清除所有水印
 */
- (void)removeWaterMarks;


/**
 清除特定水印

 @param waterMark 需要清除的水印
 */
- (void)removeWaterMark:(BSWaterMarkItem *)waterMark;


/**
 * 遍历 用户当前添加的图文/图水印
 * @param block
 */

- (void)enumerateWaterMarkSourceUsingBlock:(void (^)(NSString *identifier, BSWaterMarkView *markView, BOOL stop))block;

/**
 * 获取 用户当前添加的水印
 * @return 水印数组
 */
- (NSArray<BSWaterMarkItem *>*)getAllWaterMarks;

/**
 * 获取当前文字水印在水印幕布上的frame
 * @param textTypeMaterial
 * @return
 */
- (CGRect)watermarkTextAspectFit:(BSWaterMarkItem *)textTypeMaterial;
@end
