//
//  MCVisionRectangleConfig.swift
//  MCFastVision
//
//  Created by MorganChen on 2026/2/9.
//  Copyright © 2026 MorganChen. All rights reserved.
//

import Vision

/// 矩形检测配置结构体：用于配置 Apple Vision 框架 VNDetectRectanglesRequest 的检测参数
struct MCVisionRectangleConfig {
    /// 矩形检测最小置信度（0~1），低于该值的矩形结果会被过滤
    var minimumConfidence: VNConfidence = 0.5
    /// 最大检测结果数量，限制返回的矩形数量上限
    var maximumObservations: Int = 5

    /// 矩形最小尺寸（0~1），越小越容易检出小矩形，相对图片整体尺寸的比例，值越小越容易检出小矩形
    var minimumSize: Float = 0.2

    /// 矩形最小宽高比，用于过滤不符合比例的矩形（如过窄/过高的无效区域）
    /// 宽高比允许范围（比如纸张大概 0.6~1.8）
    var minimumAspectRatio: Float = 0.3
    /// 矩形最大宽高比，与最小宽高比配合限定有效矩形的比例范围
    var maximumAspectRatio: Float = 3.0

    /// 是否允许倾斜（倾斜太大也会过滤掉）
    /// 矩形倾斜容忍度（单位：度），值越大允许矩形倾斜角度越大，倾斜超限时会被过滤 
    var quadratureTolerance: Float = 20.0
}
