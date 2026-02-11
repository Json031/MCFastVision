//
//  MCVisionAnimalResult.swift
//  Pods
//
//  Created by Morgan Chen on 2026/2/11.
//  Copyright © 2020 Morgan Chen. All rights reserved.
//

import UIKit
import Vision

/// Vision 框架支持的动物类型（目前仅猫和狗）
public enum MCVisionAnimalType: String, CaseIterable, Codable, Sendable {
    case cat = "Cat"
    case dog = "Dog"
    
    // 如果未来 Apple 添加更多动物，可以在这里扩展
    // case bird = "Bird" // 示例，暂不支持
    
    /// 人类可读的中文标签
    public var displayName: String {
        switch self {
        case .cat: return "猫"
        case .dog: return "狗"
        }
    }
}

public struct MCVisionAnimalResult {
    /// Vision 观察对象
    public let observation: VNRecognizedObjectObservation
    
    /// 动物类型（枚举，更安全）
    public let animalType: MCVisionAnimalType
    
    /// 置信度 (0.0 - 1.0)
    public let confidence: Float
    
    /// 边界框（normalized，[0,1] 坐标系，origin 左下角）
    public let boundingBox: CGRect
    
    /// 文字/标签所在区域（image坐标系，左上角为原点，通常 boundingBox 经过坐标转换后）
    public let rect: CGRect
    
    // 如果还想保留原始 identifier 字符串（调试或兼容用），可以可选添加
    // public let rawIdentifier: String
    
    /// 人类可读的标签（直接用枚举的 displayName）
    public var label: String {
        animalType.displayName
    }
}
