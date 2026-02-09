//
//  MCVisionBarcodeResult.swift
//  MCFastVision
//
//  Created by MorganChen on 2026/2/9.
//  Copyright © 2026 MorganChen. All rights reserved.
//

import Vision

// 条码类型
// 二维码（2D）常见类型： .QR，.Aztec，.PDF417，.DataMatrix
// 条形码（1D）常见类型： .EAN13，.EAN8，.Code128，.Code39，.UPCE，.ITF14
public enum MCVisionBarcodeType {
    case barcode1D //条形码（1D）
    case code2D //二维码（2D）
}

public struct MCVisionBarcodeResult {
    public let payload: String // 条码内容（最重要）
    public let symbology: String //条码类型（区分条形码/二维码）QR / EAN13 / Code128 ...
    public let confidence: VNConfidence//置信度
    public let rect: CGRect    //rectInImage，boundingBox 是 normalized（左下角原点）
    public let type: MCVisionBarcodeType //条码类型
}
