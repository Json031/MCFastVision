//
//  MCFastVisionDetectType.swift
//  Pods
//
//  Created by Morgan Chen on 2026/2/9.
//

// 视觉检测识别类型
public enum MCFastVisionDetectType {
    case text           //文字识别
    case code           //条码/二维码
    case rectangle      //矩形检测器在图像中查找表示真实世界矩形形状的区域
    case faceRectangles //人脸框
    case faceLandmarks  //检测图像中的所有面部，然后再分析面部特征
}
