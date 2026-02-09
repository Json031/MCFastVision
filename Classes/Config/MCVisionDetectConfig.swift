//
//  MCVisionDetectConfig.swift
//  MCFastVision
//
//  Created by MorganChen on 2026/2/9.
//  Copyright © 2026 MorganChen. All rights reserved.
//

/// 全局配置（外部可改）
public struct MCVisionDetectConfig {
    /// 最低置信度要求，默认0，范围0～1，低于置信度过滤
    var minConfidence: CGFloat = 0
    
    /// 全局绘制配置
    var drawConfig: MCVisionDrawConfig = MCVisionDrawConfig()
    
    /// 全局矩形检测配置
    var rectangleConfig: MCVisionRectangleConfig = MCVisionRectangleConfig()
    
    /// 全局文本检测配置
    var textConfig: MCVisionTextConfig = MCVisionTextConfig()
}
