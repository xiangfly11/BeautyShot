//
//  BSWaterMarkItem.h
//  BeautyShot
//
//  Created by Jiaxiang Li on 2019/3/4.
//  Copyright © 2019 XiaoFan Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BSWatermarkProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface BSWaterMarkItem : NSObject<BSWatermarkProtocol>

@property (nonatomic, strong) NSString *identifierStr;
@property (nonatomic, strong) NSString *wmId;
@property (nonatomic, strong, nullable) UIImage *waterMarkImg;

@end

NS_ASSUME_NONNULL_END
