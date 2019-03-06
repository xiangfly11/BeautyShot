//
//  WMWaterMarkView.m
//  Runtopia
//
//  Created by jsonmess on 18/05/2018.
//  Copyright © 2018 codoon. All rights reserved.
//

#import "BSWaterMarkView.h"
#import "BSWaterMarkCanvasView.h"
#import "BSWatermarkProtocol.h"
#import "BSWaterMarkItem.h"
#define WATERMARKPREFIX @"BlastWaterMark"

#define WATERMARKDEFAULTSIZE     CGSizeMake(90.0f, 90.0f)

#define WATERMARKBTNSIZE    CGSizeMake(36.0f, 36.0f)

@interface BSWaterMarkView ()

@property(nonatomic, strong) UIImageView *mWaterMarkView;//水印贴纸

@property(nonatomic, weak)  BSWaterMarkCanvasView *mCanvasView;

@property(nonatomic, strong) UIImageView *mDeleteBtn; //删除

@property(nonatomic, strong) UIImageView *mScaleBtn; // 放大缩小

@property(nonatomic, strong) NSString *mIdentifier;//标识

@property(nonatomic, assign) CGPoint touchStartPoint; //移动起点

@property(nonatomic, assign) CGPoint prevPoint;//初始位置

@property(nonatomic, assign) CGFloat deltaAngle; //旋转角度

@property(nonatomic, assign) BOOL mIsEditable;//当前水印是否可以编辑



@end


@implementation BSWaterMarkView


#pragma mark init

+ (instancetype)createWaterMarkWith:(BSWaterMarkItem *)waterMark
                             canvas:(BSWaterMarkCanvasView *)canvasView {

    CGSize canvasSize = canvasView.frame.size;
    CGRect defaultFrame = CGRectMake(0.5*(canvasSize.width-WATERMARKDEFAULTSIZE.width),
                                     0.5*(canvasSize.height-WATERMARKDEFAULTSIZE.height),
                                     WATERMARKDEFAULTSIZE.width,
                                     WATERMARKDEFAULTSIZE.height);

    BSWaterMarkView *waterMarkView = [[BSWaterMarkView alloc] initWithFrame:defaultFrame];
    waterMarkView.mCanvasView = canvasView;
    [waterMarkView setTheWaterMarkWith:waterMark];
    return  waterMarkView;

}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpView];
    }
    return self;
}

/*
 * config view
 */
- (void)setUpView {
    self.mIdentifier = [self createWaterMarkIdentifier];
    self.mIsEditable = YES;//默认是可以编辑
    self.backgroundColor = [UIColor clearColor];
    self.mWaterMarkView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.mWaterMarkView.backgroundColor = [UIColor clearColor];
    [self.mWaterMarkView setContentMode:UIViewContentModeScaleAspectFill];
    [self.mWaterMarkView setClipsToBounds:YES];

    [self addSubview:self.mWaterMarkView];
    //删除按钮
    self.mDeleteBtn = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.mDeleteBtn.userInteractionEnabled = YES;
    UIImage *deleteIcon = [UIImage imageNamed:@"btn_delete_watermark"];
    self.mDeleteBtn.image = deleteIcon;
    self.mDeleteBtn.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.mDeleteBtn];

    //放大缩小
    self.mScaleBtn = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.mScaleBtn.userInteractionEnabled = YES;
    UIImage *scaleIcon = [UIImage imageNamed:@"btn_scale_watermark"];
    self.mScaleBtn.image = scaleIcon;
    self.mScaleBtn.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.mScaleBtn];
    // gestures
    [self setUpGestures];
    //subView frame
    [self updateSubViewLayout:WATERMARKDEFAULTSIZE];
    self.deltaAngle = atan2(self.frame.origin.y+self.frame.size.height - self.center.y,
                            self.frame.origin.x+self.frame.size.width - self.center.x);
}


/**
 *  config gestures
 */
- (void)setUpGestures {

    /// 删除水印操作
    UITapGestureRecognizer *deleteTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(deleteWaterMark:)];
    [self.mDeleteBtn addGestureRecognizer:deleteTap];
    /// 放大旋转操作
    UIPanGestureRecognizer *panScaleGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                      action:@selector(scaleWaterMark:)];
    [self.mScaleBtn addGestureRecognizer:panScaleGesture];

    UITapGestureRecognizer *bgTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(tap:)];
    [self.mWaterMarkView addGestureRecognizer:bgTap];

    /// 拖动手势
    UIPanGestureRecognizer *dragMoveGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                      action:@selector(dragWaterMark:)];
    [self addGestureRecognizer:dragMoveGesture];

}

#pragma mark Setting and Getting
- (NSString *)identifier {

    return self.mIdentifier;
}

- (void)setIsTopWaterMark:(BOOL)isTopWaterMark {
    _isTopWaterMark = isTopWaterMark;
    if (isTopWaterMark) {
        if ([self.delegate respondsToSelector:@selector(makeWaterMarkBecomeFirstResponder:)]) {
            [self.delegate makeWaterMarkBecomeFirstResponder:self.identifier] ;
        }
    }
    if (self.mIsEditable){
        [self.mDeleteBtn setHidden:!isTopWaterMark];
        [self.mScaleBtn setHidden:!isTopWaterMark];
        [self setUserInteractionEnabled:YES];
        [self.mWaterMarkView.layer setBorderColor:[UIColor whiteColor].CGColor];
        [self.mWaterMarkView.layer setBorderWidth:isTopWaterMark ? 1.0f : 0.0f];
    }
}

-(CGSize)mWaterMarkSize {
    return  self.mWaterMarkView.bounds.size;
}

#pragma mark Public function
- (void)setTheWaterMarkWith:(BSWaterMarkItem *)waterMark {
    _waterMark = waterMark;
    UIImage*image = waterMark.waterMarkImg;
    [self.mWaterMarkView setImage:image];
    CGSize aspectSize = [self watermarkAspectFit:image];
    CGFloat aspectRatio = aspectSize.height/aspectSize.width;
    [self updateSubViewLayout:CGSizeMake(aspectSize.width, aspectSize.width*aspectRatio)];
    //根据服务器配置，更新初始位置
    [self updateDefaultOrigin];

}

- (void)clear {
    [self deleteWaterMark:nil];
}

-(void)canEditable:(BOOL)editable
{
    self.mIsEditable = editable;
    [self setUserInteractionEnabled:editable];
    [self.mDeleteBtn setHidden:!editable];
    [self.mScaleBtn setHidden:!editable];
    [self.mWaterMarkView.layer setBorderWidth:editable ? 1.0f : 0.0f];
}

/**
 * 删除水印
 * @param sender
 */
- (void)deleteWaterMark:(id)sender {
    if (self.superview) {
        [self removeFromSuperview];
    }
    if (self.refTextWaterMarkLabel.superview) {
        [self.refTextWaterMarkLabel removeFromSuperview];
    }
    if ([self.delegate respondsToSelector:@selector(removeWaterMarkWithIdentifer: watherMark:)]) {
        [self.delegate removeWaterMarkWithIdentifer:self.identifier watherMark:_waterMark];
    }
}

/**
 * 拖动水印
 * @param gesture
 */
- (void)dragWaterMark:(UIPanGestureRecognizer *)gesture {

    CGPoint touch = [gesture locationInView:self.superview];

    [self translateUsingTouchLocation:touch] ;

    self.touchStartPoint = touch;
}
/**
 * 放大缩小水印
 * @param gesture
 */
- (void)scaleWaterMark:(UIPanGestureRecognizer *)gesture {
    CGFloat ratio = self.mWaterMarkView.frame.size.height / self.mWaterMarkView.frame.size.width;
    if ([gesture state] == UIGestureRecognizerStateBegan) {
        self.prevPoint = [gesture locationInView:self];
        [self setNeedsDisplay];
    } else if ([gesture state] == UIGestureRecognizerStateChanged) {
        //阀值,不能无限缩小，这里定义为默认大小的1/3
        if (self.mWaterMarkView.bounds.size.height <= WATERMARKDEFAULTSIZE.height / 3
                || self.mWaterMarkView.bounds.size.width <= WATERMARKDEFAULTSIZE.width / 3) {
            self.prevPoint = [gesture locationInView:self];
            CGFloat tmpHeight = self.mWaterMarkView.frame.size.height+1.0f;
            CGFloat tmpWidth = tmpHeight/ratio;
            [self updateSubViewLayout:CGSizeMake(tmpWidth, tmpHeight)];
            return;
        } else {
            //执行缩小
            CGPoint point = [gesture locationInView:self];
            CGFloat wChange = 0.0;
            wChange = (point.x - self.prevPoint.x);
            if (ABS(wChange) > 50.0f) {
                self.prevPoint = [gesture locationOfTouch:0 inView:self];
                return;
            }
            CGFloat scaledWidth = self.mWaterMarkView.bounds.size.width + (wChange);
            CGFloat scaledHeight = scaledWidth*ratio;
            //限制放大程度;
            if (ratio > 1 && scaledHeight > self.mCanvasView.bounds.size.height-WATERMARKBTNSIZE.height) {
                //宽小于高,判断高 是否放大超出边界;
                scaledHeight = self.bounds.size.height - WATERMARKBTNSIZE.width;
                scaledWidth = scaledHeight / ratio;
            }
            if (ratio <1 && scaledWidth > self.mCanvasView.bounds.size.width-WATERMARKBTNSIZE.width) {
                //宽大于高
                scaledWidth = self.bounds.size.width - WATERMARKBTNSIZE.width;
                scaledHeight = scaledWidth * ratio;
            }
            [self updateSubViewLayout:CGSizeMake(scaledWidth, scaledHeight)];
            self.prevPoint = [gesture locationOfTouch:0
                                               inView:self];
            // 旋转
            /* Rotation */
            CGFloat ang = atan2([gesture locationInView:self.superview].y - self.center.y,
                    [gesture locationInView:self.superview].x - self.center.x);
            CGFloat angleDiff = self.deltaAngle + ang;
            self.transform = CGAffineTransformMakeRotation(angleDiff);
            [self setNeedsDisplay];
        }
    } else if ([gesture state] == UIGestureRecognizerStateEnded) {
        self.prevPoint = [gesture locationInView:self];
        [self setNeedsDisplay];
    }
}

#pragma mark Gesture and Touch

- (void)tap:(UITapGestureRecognizer *)tapGesture {
    self.isTopWaterMark = YES;
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
   self.isTopWaterMark = YES;
    UITouch *touch = [touches anyObject] ;
    self.touchStartPoint = [touch locationInView:self.superview] ;
}


#pragma mark Others
/**
 *  服务器默认水印位置
 */
- (void)updateDefaultOrigin {

    CGRect tempFrame = self.frame;
    tempFrame.origin = CGPointMake(self.mCanvasView.frame.size.width * 0.5 - self.frame.size.width * 0.5, self.mCanvasView.frame.size.height * 0.5 - self.frame.size.height * 0.5);
    self.frame = tempFrame;
}


/**
 *  根据size 更新当前水印frame
 *
 * @param warkImageSize 水印素材大小
 */
- (void)updateSubViewLayout:(CGSize)warkImageSize {
    CGSize size = CGSizeMake(warkImageSize.width+WATERMARKBTNSIZE.width, warkImageSize.height+WATERMARKBTNSIZE.height);
    if (self.mIsEditable) {
    self.bounds = (CGRect){{0,0},size};

    [self.mDeleteBtn setFrame:CGRectMake(0,size.height-WATERMARKBTNSIZE.height,
                                         WATERMARKBTNSIZE.width, WATERMARKBTNSIZE.height)];
    [self.mWaterMarkView setFrame:CGRectMake(CGRectGetMidX(self.mDeleteBtn.frame), WATERMARKBTNSIZE.height*0.5f,warkImageSize.width, warkImageSize.height)];
    [self.mScaleBtn setFrame:CGRectMake(CGRectGetMaxX(self.mWaterMarkView.frame)-WATERMARKBTNSIZE.width*0.5,
                                        0,WATERMARKBTNSIZE.width, WATERMARKBTNSIZE.height)];
    }else {
        self.bounds = (CGRect){{0,0},size};
        [self.mWaterMarkView setFrame:self.bounds];
    }
}

- (void)translateUsingTouchLocation:(CGPoint)touchPoint
{
    CGPoint newCenter = CGPointMake(self.center.x + touchPoint.x - self.touchStartPoint.x,
            self.center.y + touchPoint.y - self.touchStartPoint.y) ;
    // 限制用户 拖动的范围，不能超出 size *0.5
    if (newCenter.x > self.superview.bounds.size.width)
    {
        newCenter.x = self.superview.bounds.size.width;
    }
    if (newCenter.x < 0)
    {
        newCenter.x = 0;
    }

    if (newCenter.y > self.superview.bounds.size.height)
    {
        newCenter.y = self.superview.bounds.size.height;
    }
    if (newCenter.y < 0)
    {
        newCenter.y = 0;
    }
    self.center = newCenter;
    /***
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    if (self.center.x + 0.2 * width > self.superview.frame.size.width) {
        CGPoint center = CGPointMake(self.center.x - (self.center.x + 0.2 * width - width), self.center.y);
        self.center = center;
    }
    
    if (self.center.x - 0.2 * width < 0) {
        CGPoint center = CGPointMake(self.center.x - (self.center.x - 0.2 * width), self.center.y);
        self.center = center;
    }
    
    if (self.center.y + 0.2 * height > self.superview.frame.size.height) {
        CGPoint center = CGPointMake(self.center.x, self.center.y - (self.center.y + 0.2 * height - height));
        self.center = center;
    }
    
    if (self.center.y - 0.2 * height < 0) {
        CGPoint center = CGPointMake(self.center.x, self.center.y - (self.center.y - 0.2 * height));
        self.center = center;
    }
     ***/
}

/**
 * 生成水印贴纸唯一标识
 * @return 标识
 */
- (NSString *)createWaterMarkIdentifier {
    //生成唯一标识id
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef uuidStr = CFUUIDCreateString(NULL, uuid);
    NSString *uuidString = [NSString stringWithFormat:@"%@-%@", WATERMARKPREFIX, uuidStr];
    CFRelease(uuid);
    CFRelease(uuidStr);
    return uuidString;
}


/**
 * 计算水印图片的适当缩放显示size
 * 以当前屏幕宽度为基准，宽高1:1
 */
- (CGSize)watermarkAspectFit:(UIImage*)image {

    if (image == nil ) {
        return CGSizeZero;
    }
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGSize imageSize = image.size;
    //v2.15.0
    // 根据运营要求，初始水印位置和大小按照 1080*1080基准 排布
    CGFloat ratio = screenSize.width/1080.0f;
    imageSize = CGSizeMake(imageSize.width*ratio, imageSize.height*ratio);
    //1.如果图片高度 大于宽度
    //1.2 预留出 按钮的宽度
    if (imageSize.height >= imageSize.width && imageSize.height > screenSize.width) {
        //需要缩放
        CGFloat s_h_Ratio = imageSize.height / screenSize.width;
        imageSize = CGSizeMake(imageSize.width/s_h_Ratio, screenSize.width);
        CGFloat h_w_Ratio = imageSize.height/imageSize.width;
        imageSize = CGSizeMake((imageSize.height-WATERMARKBTNSIZE.height)/h_w_Ratio, imageSize.height-WATERMARKBTNSIZE.height);
    } else if (imageSize.width > imageSize.height && imageSize.width > screenSize.width) {
        CGFloat s_w_Ratio = imageSize.width / screenSize.width;
        imageSize = CGSizeMake(screenSize.width, imageSize.height/s_w_Ratio);
         CGFloat h_w_Ratio = imageSize.height/imageSize.width;
            imageSize = CGSizeMake(imageSize.width-WATERMARKBTNSIZE.width, (imageSize.width-WATERMARKBTNSIZE.width)*h_w_Ratio);
    }

    return  imageSize;
}

@end
