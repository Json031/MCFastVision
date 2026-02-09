//
//  MCVisionTextResult.swift
//  MCFastVision
//
//  Created by MorganChen on 2026/2/6.
//  Copyright © 2026 MorganChen. All rights reserved.
//

// Vision视觉识别结果模型
public struct MCVisionTextResult {
    /// 识别出来的文字
    public let text: String
    
    /// 置信度 0~1
    public let confidence: Float
    
    /// 文字所在区域（image坐标系，左上角为原点）
    public let rect: CGRect
}
