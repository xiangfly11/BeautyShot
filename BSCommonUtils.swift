//
//  BSCommonUtils.swift
//  BeautyShot
//
//  Created by Jiaxiang Li on 2019/3/11.
//  Copyright © 2019 XiaoFan Wang. All rights reserved.
//

import Foundation

/// 将设计标准长度尺寸375与当前屏幕尺寸的比例进行计算，获得当前屏幕应该显示的宽度
///
/// - Parameter width: 设计长度
/// - Returns: 当前屏幕的长度
func convertDesignWidthToCurrentWidh(width: Float) -> CGFloat {
    let screenWidh = UIScreen.main.bounds.size.width
    let ratio = screenWidh / 375.0
    
    return ratio * CGFloat(width)
}

/// 将设计标准高度尺寸667与当前屏幕尺寸的比例进行计算，获得当前屏幕应该显示的高度
///
/// - Parameter height: 设计高度
/// - Returns: 当前屏幕高度
func convertDesignHeightToCurrentHeight(height: Float) -> CGFloat {
    let screenHeight = UIScreen.main.bounds.size.height
    let ratio = screenHeight / 667.0
    
    return ratio * CGFloat(height)
}


/// 将设计字体大小转换成屏幕适配尺寸
///
/// - Parameter size: 设计字体大小
/// - Returns: 实际屏幕适配字体大小
func adjustFontSize(size: Float) -> CGFloat {
    let screenWidh = UIScreen.main.bounds.size.width
    let ratio = screenWidh / 375.0
    
    return ratio * CGFloat(size)
}
