//
//  WMWaterMarkView.h
//  Runtopia
//
//  Created by jsonmess on 18/05/2018.
//  Copyright © 2018 codoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BSWaterMarkCanvasView;
@class BSWaterMarkItem;
/**
 * 水印View Delegate
 */
@protocol BSWatermarkProtocol;
@protocol BSWaterMarkViewDelegate <NSObject>

/**
 * 移除水印
 * @param identifier
 */
- (void)removeWaterMarkWithIdentifer:(NSString *)identifier watherMark:(id<BSWatermarkProtocol>) waterMark;

/**
 * 调整水印层级
 * @param identifier
 */
- (void)makeWaterMarkBecomeFirstResponder:(NSString *)identifier;

@end


/**
 * 单个水印
 */
@interface BSWaterMarkView : UIView

@property(nonatomic, readonly) NSString *identifier; //唯一标识一个水印

@property(nonatomic, weak) id <BSWaterMarkViewDelegate> delegate; //delegate

@property(nonatomic, assign) BOOL isTopWaterMark; //是否是顶部

@property(nonatomic, strong) BSWaterMarkItem *waterMark;

@property (nonatomic, weak) UILabel *refTextWaterMarkLabel; //关联文字

@property(nonatomic, assign) CGSize mWaterMarkSize;


/**
 * 生成一个水印
 *
 * @param 水印数据
 * @param canvasView 水印幕布View
 * @return instance
 */
+(instancetype)createWaterMarkWith:(BSWaterMarkItem *)waterMark
                            canvas:(BSWaterMarkCanvasView*)canvasView;

/**
 * 设置水印
 *
 * @param watermark watermark
 */
- (void)setTheWaterMarkWith:(BSWaterMarkItem *)waterMark;


/**
 * 清除水印
 */
- (void)clear;

/**
 * 当前水印是否可以编辑
 * @param editable
 */
- (void)canEditable:(BOOL)editable;

@end
