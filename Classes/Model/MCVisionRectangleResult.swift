//
//  MCVisionRectangleResult.swift
//  MCFastVision
//
//  Created by MorganChen on 2026/2/9.
//  Copyright © 2026 MorganChen. All rights reserved.
//
import UIKit
import Vision

public struct MCVisionRectangleResult {
    public let confidence: VNConfidence
    public let rect: CGRect

    /// 四个角点（image 坐标系）
    public let topLeft: CGPoint
    public let topRight: CGPoint
    public let bottomLeft: CGPoint
    public let bottomRight: CGPoint
}

