//
//  MCVisionFaceRectResult.swift
//  MCFastVision
//
//  Created by Rate Rebriduo on 2026/2/9.
//  Copyright © 2026 MorganChen. All rights reserved.
//

import UIKit
import Vision

public struct MCVisionFaceRectResult {
    /// face观察对象
    public var faceObservation: VNFaceObservation
    public let rect: CGRect
    public let confidence: VNConfidence
}
