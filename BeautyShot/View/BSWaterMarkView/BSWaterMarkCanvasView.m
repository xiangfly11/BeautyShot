//
//  WMWaterMarkCanvasView.m
//  Runtopia
//
//  Created by jsonmess on 21/05/2018.
//  Copyright © 2018 codoon. All rights reserved.
//

#import "BSWaterMarkCanvasView.h"
#import "BSWaterMarkView.h"
#import "BSWaterMarkItem.h"

@interface BSWaterMarkCanvasView () <BSWaterMarkViewDelegate>

@property (nonatomic, strong) NSMutableDictionary *mWaterMarkDic;

@property (nonatomic, strong) NSMutableArray *mWaterMarkIndexs;//顺序索引

//已经添加的水印视图 key:waterMark.wmid  object:view
@property (nonatomic, strong) NSMutableDictionary *mSelectedWaterMarkViewDic;


//已经添加过的水印对象
@property (nonatomic, strong) NSMutableArray *mSelectedWaterMark;

@property (nonatomic, strong) UIButton *bgBtn;//背景button

@end

@implementation BSWaterMarkCanvasView

/**
 * 初始化
 * @param frame
 * @return
 */
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

/**
 * config View
 */
- (void)setUp {
    self.mWaterMarkDic = [NSMutableDictionary dictionary];
    self.mWaterMarkIndexs = [NSMutableArray array];
    //背景透明
    self.backgroundColor = [UIColor clearColor];
    self.bgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.bgBtn setBackgroundColor:[UIColor clearColor]];
    [self.bgBtn addTarget:self
                   action:@selector(cleanAllWarterMarkSelectedStatus:)
         forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.bgBtn];
    [self.bgBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

/**
 * 清除所有水印选中状态
 */
- (void)cleanAllWarterMarkSelectedStatus:(id)sender {
    if (self.mWaterMarkDic.allKeys.count <= 0) {
        return;
    }
    for (NSString *identifier in self.mWaterMarkDic.allKeys) {
        BSWaterMarkView *markView = [self.mWaterMarkDic objectForKey:identifier];
        [markView setIsTopWaterMark:NO];
    }
}

- (void)addWaterMarkWithMarkImage:(BSWaterMarkItem *)waterMark {
    if (waterMark == nil || WaterMarkMaxCount == 0) {
        return;
    }

    
    //如果有相同的水印已经添加过那么清除该水印
    for (id<BSWatermarkProtocol> item in self.mSelectedWaterMark) {
        if ([waterMark isKindOfClass:[BSWaterMarkItem class]] && [item isKindOfClass:[BSWaterMarkItem class]]) {
            BSWaterMarkItem *waterMarkItem = (BSWaterMarkItem *)waterMark;
            BSWaterMarkItem *checkMarkItem = (BSWaterMarkItem *)item;
            if (checkMarkItem.wmId == waterMarkItem.wmId) {
                [self removeWaterMark:waterMarkItem];
                return;
            }
        }
    }
    
    [self.mSelectedWaterMark addObject:waterMark];
    BSWaterMarkView *markView;
        markView = [BSWaterMarkView createWaterMarkWith:waterMark canvas:self];
        [self.mWaterMarkDic setObject:markView forKey:markView.identifier];
        [self.mWaterMarkIndexs addObject:markView.identifier];
        //将水印视图加入对应的字典
        if ([waterMark isKindOfClass:[BSWaterMarkItem class]]) {
            BSWaterMarkItem *item = (BSWaterMarkItem *)waterMark;
            [self.mSelectedWaterMarkViewDic setObject:markView forKey:item.wmId];
        }
        [self addSubview:markView];
        [markView setDelegate:self];
        [markView setIsTopWaterMark:YES];

}

- (void)removeWaterMarks {
//    if (self.mWaterMarkDic.allKeys.count <= 0) {
//        return;
//    }
    for (NSString *identifier in self.mWaterMarkDic.allKeys) {
        BSWaterMarkView *markView = [self.mWaterMarkDic objectForKey:identifier];
        [markView clear];
    }
    [self.mWaterMarkIndexs removeAllObjects];
    [self.mSelectedWaterMark removeAllObjects];
    [self.mSelectedWaterMarkViewDic removeAllObjects];
}


- (void)removeWaterMark:(BSWaterMarkItem *)waterMark {
    if ([waterMark isKindOfClass:[BSWaterMarkItem class]]) {
        BSWaterMarkItem *item = (BSWaterMarkItem *)waterMark;
        id view = [self.mSelectedWaterMarkViewDic objectForKey:item.wmId];
        if (view && [view isKindOfClass:[BSWaterMarkView class]]) {
            BSWaterMarkView *waterMarkView = (BSWaterMarkView *)view;
            if (waterMarkView.superview) {
                [waterMarkView removeFromSuperview];
                [self.mSelectedWaterMarkViewDic removeObjectForKey:item.wmId];
            }
        }
        
        
        if ([self.mSelectedWaterMark containsObject:item]) {
            [self.mSelectedWaterMark removeObject:item];
        }
    }
}

- (void)enumerateWaterMarkSourceUsingBlock:(void (^)(NSString *identifier, BSWaterMarkView *markView, BOOL stop))block {
    if (self.mWaterMarkDic.allKeys.count <= 0) {
        return;
    }
    if (block) {
        [self.mWaterMarkIndexs enumerateObjectsUsingBlock:^(NSString *identStr, NSUInteger idx, BOOL *stop) {
            BSWaterMarkView *markView = [self.mWaterMarkDic objectForKey:identStr];
            if (idx == self.mWaterMarkIndexs.count - 1) {
                 block(identStr, markView, true);
            }else {
                block(identStr, markView, false);
            }
            
        }];
    }
}


- (NSArray <BSWatermarkProtocol> *)getAllWaterMarks {
    NSMutableArray <BSWatermarkProtocol> *marks = [NSMutableArray<BSWatermarkProtocol> array];
    if (self.mWaterMarkDic.allKeys.count > 0) {
        for (NSString *identifier in self.mWaterMarkDic.allKeys) {
            BSWaterMarkView *markView = [self.mWaterMarkDic objectForKey:identifier];
            id <BSWatermarkProtocol> mark = markView.waterMark;
            [marks addObject:mark];
        }
    }
    return marks;
}


#pragma mark -- Setter && Getter
- (NSMutableArray *)mSelectedWaterMark {
    if (!_mSelectedWaterMark) {
        _mSelectedWaterMark = [NSMutableArray new];
    }
    
    return _mSelectedWaterMark;
}

- (NSMutableDictionary *)mSelectedWaterMarkViewDic {
    if (!_mSelectedWaterMarkViewDic) {
        _mSelectedWaterMarkViewDic = [NSMutableDictionary new];
    }
    
    return _mSelectedWaterMarkViewDic;
}


#pragma mark WMWaterMarkViewDelegate

- (void)removeWaterMarkWithIdentifer:(NSString *)identifier watherMark:(BSWaterMarkItem *)waterMark {

    if (identifier == nil) {
        return;
    }
    if ([self.mWaterMarkDic.allKeys containsObject:identifier]) {
        [self.mWaterMarkDic removeObjectForKey:identifier];
    }
    if ([self.mWaterMarkIndexs containsObject:identifier]) {
        [self.mWaterMarkIndexs removeObject:identifier];
    }
    
    if ([self.mSelectedWaterMark containsObject:waterMark]) {
        [self.mSelectedWaterMark removeObject:waterMark];
    }
    
    if ([waterMark isKindOfClass:[BSWaterMarkItem class]]) {
        BSWaterMarkItem *item = (BSWaterMarkItem *)waterMark;
        [self.mSelectedWaterMarkViewDic removeObjectForKey:item.wmId];
    }
}

- (void)makeWaterMarkBecomeFirstResponder:(NSString *)identifier {

    //移除其他所有 被选中的状态
    if (self.mWaterMarkDic.allKeys.count <= 0) {
        return;
    }
    for (NSString *tmp in self.mWaterMarkDic.allKeys) {
        if (![tmp isEqualToString:identifier]) {
            BSWaterMarkView *markView = [self.mWaterMarkDic objectForKey:tmp];
            [markView setIsTopWaterMark:NO];
        }
    }
}

@end
