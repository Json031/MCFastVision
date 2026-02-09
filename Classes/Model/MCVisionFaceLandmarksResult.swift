//
//  MCVisionFaceLandmarksResult.swift
//  MCFastVision
//
//  Created by MorganChen on 2026/2/9.
//  Copyright © 2026 MorganChen. All rights reserved.
//

import UIKit
import Vision

public struct MCVisionFaceLandmarksResult {
    /// face观察对象
    public var faceObservation: VNFaceObservation

    public let rect: CGRect                  // 人脸框（image坐标）
    public let confidence: VNConfidence    //置信度

    // 关键点（image坐标系）
    public let leftEye: [CGPoint] // 左眼
    public let rightEye: [CGPoint] // 右眼

    public let leftEyebrow: [CGPoint] // 左眼眉毛
    public let rightEyebrow: [CGPoint]// 右眼眉毛
    
    public let leftPupil: [CGPoint] // 左眼瞳
    public let rightPupil: [CGPoint]// 右眼瞳
    
    public let nose: [CGPoint] // 鼻子
    public let noseCrest: [CGPoint] // 鼻梁
    public let medianLine: [CGPoint] // 正中线

    public let outerLips: [CGPoint] // 外唇
    public let innerLips: [CGPoint] // 内唇

    public let faceContour: [CGPoint] // 面部轮廓
    
    // 所有关键点（image坐标系）
    public var landmarkArr: [[CGPoint]] {
        get {
            var landmarkArr: [[CGPoint]] = [[CGPoint]]()
            /// 左眼, 右眼
            landmarkArr.append(leftEye)
            landmarkArr.append(rightEye)
            /// 左睫毛, 右睫毛
            landmarkArr.append(leftEyebrow)
            landmarkArr.append(rightEyebrow)
            /// 左眼瞳，右眼瞳
            landmarkArr.append(leftPupil)
            landmarkArr.append(rightPupil)
            /// 鼻子, 鼻嵴, 正中线
            landmarkArr.append(nose)
            landmarkArr.append(noseCrest)
            landmarkArr.append(medianLine)
            /// 外唇, 内唇
            landmarkArr.append(outerLips)
            landmarkArr.append(innerLips)
            /// 脸部轮廓
            landmarkArr.append(faceContour)
            return landmarkArr
        }
    }
}
