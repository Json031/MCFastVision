//
//  VisionDrawConfig.swift
//  MCFastVision
//
//  Created by MorganChen on 2026/2/5.
//  Copyright © 2026 MorganChen. All rights reserved.
//


//MCFastVision.drawConfig.landmarkStrokeColor = .yellow
//MCFastVision.drawConfig.confidenceFontSize = 16
//MCFastVision.drawConfig.confidenceBackgroundColor = .blue.withAlphaComponent(0.5)
struct MCVisionDrawConfig {
    /// 关键点线条颜色
    var landmarkStrokeColor: UIColor = .green
    /// 关键点填充颜色
    var landmarkFillColor: UIColor = .clear
    /// 关键点线条宽度
    var landmarkLineWidth: CGFloat = 2.0

    /// 人脸框颜色
    var faceBoxStrokeColor: UIColor = .red
    /// 人脸框线条宽度
    var faceBoxLineWidth: CGFloat = 2.0

    /// 置信度文字颜色
    var confidenceTextColor: UIColor = .green
    /// 置信度字体大小
    var confidenceFontSize: CGFloat = 13
    /// 置信度字体对齐方式
    var alignmentMode: CATextLayerAlignmentMode = .center
    
    /// 置信度背景色
    var confidenceBackgroundColor: UIColor = UIColor.clear

    /// 置信度标签 padding
    var confidencePadding: UIEdgeInsets = UIEdgeInsets(top: 2, left: 6, bottom: 2, right: 6)

    /// 是否绘制人脸框
    var showFaceBox: Bool = true
    /// 是否绘制置信度
    var showConfidence: Bool = true
    
    /// 人像分割 / 人物蒙版生成
    /// 遮罩透明度
    var personSegmentationMaskOpacity: Float = 0.7
    /// 人像分割遮罩相对于图片显示区域的内/外边距（支持正负值）
    /// - 正值：向内收缩（缩小遮罩区域）
    /// - 负值：向外扩展（放大遮罩区域）
    /// - 单位：像素（基于 imageView 的坐标系）
    var personSegmentationMaskPadding: UIEdgeInsets = .zero  // 默认无偏移
    /// 人像分割遮罩颜色（包括 alpha 通道，决定了叠加时的着色效果）
    /// - 默认绿色半透明，可改为绿色、蓝色、黄色等
    var personSegmentationMaskColor: UIColor = UIColor.green.withAlphaComponent(0.66)
}
