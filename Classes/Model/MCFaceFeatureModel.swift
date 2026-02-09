//
//  MCFaceFeatureModel.swift
//  MCFastVision
//
//  Created by Morgan Chen on 2020/11/12.
//  Copyright © 2020 Morgan Chen. All rights reserved.
//

import UIKit
import Vision
class MCFaceFeatureModel: NSObject {
    /// face观察对象
    public var faceObservation: VNFaceObservation
    
    /// 关键点
    public var landmarks: VNFaceLandmarks2D

    /// 所有属性数组
    public var landmarkArr = [VNFaceLandmarkRegion2D?]()
    
    // 整张脸的置信度，范围是 0 ~ 1
    public var confidence: VNConfidence {
        return faceObservation.confidence
    }

    /// 初始化方法
    init(faceObservation: VNFaceObservation) {
        self.faceObservation = faceObservation
        self.landmarks = faceObservation.landmarks!

        super.init()

        let face = self.landmarks

        /// 脸部轮廓
        landmarkArr.append(face.faceContour)
        /// 左眼, 右眼
        landmarkArr.append(face.leftEye)
        landmarkArr.append(face.rightEye)
        /// 左睫毛, 右睫毛
        landmarkArr.append(face.leftEyebrow)
        landmarkArr.append(face.rightEyebrow)
        /// 左眼瞳, 右眼瞳
        landmarkArr.append(face.leftPupil)
        landmarkArr.append(face.rightPupil)
        /// 鼻子, 鼻嵴, 正中线
        landmarkArr.append(face.nose)
        landmarkArr.append(face.noseCrest)
        landmarkArr.append(face.medianLine)
        /// 外唇, 内唇
        landmarkArr.append(face.outerLips)
        landmarkArr.append(face.innerLips)
    }
}
