//
//  VisionTextConfig.swift
//  MCFastVision
//
//  Created by MorganChen on 2026/2/6.
//  Copyright © 2026 MorganChen. All rights reserved.
//

import Vision

struct MCVisionTextConfig {
    /// 识别语言（空表示自动）
    var languages: [String] = ["zh-Hans", "en-US"]
    
    /// 是否做语言纠错
    var usesLanguageCorrection: Bool = true
    
    /// 快速识别.fast / 精确识别.accurate
    var recognitionLevel: VNRequestTextRecognitionLevel = .accurate
    
    /// 是否启用自定义词库
    var customWords: [String] = []
}

