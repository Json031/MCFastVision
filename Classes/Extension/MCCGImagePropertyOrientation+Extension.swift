//
//  MCCGImagePropertyOrientation+Extension.swift
//  MCFastVision
//
//  Created by MorganChen on 2026/2/6.
//  Copyright © 2026 MorganChen. All rights reserved.
//

/// CGImagePropertyOrientation 扩展：实现 UIImage.Orientation 到 CGImagePropertyOrientation 的便捷转换
/// 核心用途：解决 Apple Vision 框架/Image I/O 框架中，图片方向（UIImage.Orientation）与 CGImage 方向不兼容的问题，
///          保证视觉检测时图片方向正确，避免检测结果偏移/翻转
extension CGImagePropertyOrientation {
    /// 初始化方法：从 UIImage.Orientation 转换为对应的 CGImagePropertyOrientation
    /// 适配逻辑：覆盖 UIImage 所有方向类型（up/down/left/right 及镜像类型），保证转换无遗漏
    /// - Parameter uiOrientation: UIImage 的原始方向（通常来自 UIImage.imageOrientation）
    init(_ uiOrientation: UIImage.Orientation) {
        switch uiOrientation {
        case .up: self = .up
        case .down: self = .down
        case .left: self = .left
        case .right: self = .right
        case .upMirrored: self = .upMirrored
        case .downMirrored: self = .downMirrored
        case .leftMirrored: self = .leftMirrored
        case .rightMirrored: self = .rightMirrored
        @unknown default:
            self = .up
        }
    }
}
