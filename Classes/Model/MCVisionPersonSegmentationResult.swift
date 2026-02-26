//
//  MCVisionPersonSegmentationResult.swift
//  Pods
//
//  Created by Morgan Chen on 2026/2/13.
//

import Vision

public struct MCVisionPersonSegmentationResult {
    /// Vision 观察对象（包含 pixelBuffer 蒙版）
    public let observation: VNPixelBufferObservation
    
    /// 置信度（通常为 1.0 或接近，因为是 semantic segmentation）
    public let confidence: Float
    
    /// 像素缓冲（CVPixelBuffer），可用于进一步处理（如抠图、虚化背景）
    public var pixelBuffer: CVPixelBuffer {
        observation.pixelBuffer
    }
}
