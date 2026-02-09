//
//  MCFastVision.swift
//  MCFastVision
//
//  Created by Morgan Chen on 2020/11/12.
//  Copyright © 2020 Morgan Chen. All rights reserved.
//

import UIKit
import Vision

/// 全局图层名称常量
let boxLineOverlayLayerName: String = "BoxLineOverlayLayer"

/// Vision 计算机视觉识别检测工具类
/// 封装 Apple Vision 框架的核心能力，提供统一的视觉识别接口
/// 支持：文字识别、条码/二维码识别、矩形检测、人脸检测（框/关键点）
public class MCFastVision: NSObject {
    // MARK: - 类型别名（简化闭包定义，提升代码可读性）
    /// 通用视觉检测回调闭包
    /// - Parameters:
    ///   - bigRectArr: 检测到的目标矩形数组（核心返回值，如人脸框、条码框、矩形框）
    ///   - backArr: 扩展返回数据（不同检测类型对应不同数据：人脸关键点/条码内容/自定义数据等）
    typealias MCVisionDetectHandle = ((_ bigRectArr: [CGRect]?, _ backArr: [Any]?) -> ())
    
    /// 文字识别专属回调闭包
    /// - Parameter results: 文字识别结果数组（封装为 MCVisionTextResult 模型，含文本、位置、置信度）
    typealias MCVisionTextRecognizeHandle = (_ results: [MCVisionTextResult]) -> Void
    
    // MARK: - 全局配置
    /// 视觉检测全局配置项（外部可直接修改，全局生效）
    /// 配置项说明：
    /// - enableHighPerformanceMode: 高性能模式开关（默认开启，优先保证检测速度）
    /// - minDetectArea: 最小检测区域（过滤小尺寸目标，减少无效检测）
    /// - needKeyPoints: 人脸关键点返回开关（默认开启）
    public var mcVisionDetectConfig: MCVisionDetectConfig = MCVisionDetectConfig()
    
    // MARK: - MCFastVision单例
    /// 单例对象（保证全局配置唯一，避免重复初始化 Vision 请求）
    static let shared = MCFastVision()
    private override init() { super.init() }
}

// MARK: - 视觉识别
extension MCFastVision {
    /// 识别图片(根据不同类型)
    /// - Parameters:
    ///   - type: 视觉检测识别类型
    ///   - image: 视觉检测识别图片对象
    ///   - completeBack: 回调
    class func visionDetectImage(type: MCFastVisionDetectType, image: UIImage, _ completeBack: @escaping MCVisionDetectHandle) {
        //1. 转成ciimage
        guard let ciImage = CIImage(image: image) else {
            completeBack(nil, nil)
            return
        }
        
        //2. 创建处理request
        let requestHandle = VNImageRequestHandler(ciImage: ciImage, options: [:])
        
        //3. 创建baseRequest
        //大多数识别请求request都继承自VNImageBasedRequest
        var baseRequest = VNImageBasedRequest()
        
        //4. 设置回调
        let completionHandle: VNRequestCompletionHandler = { request, error in
            let observations = request.results
            faceFeatureDectect(observations, image: image, completeBack)
        }
        
        //5. 创建识别请求
        switch type {
        case .text:
            baseRequest = VNDetectTextRectanglesRequest(completionHandler: completionHandle)
            // 设置识别具体文字
            baseRequest.setValue(true, forKey: "reportCharacterBoxes")
        case .code:
            let request = VNDetectBarcodesRequest(completionHandler: completionHandle)
            request.symbologies = VNDetectBarcodesRequest.supportedSymbologies
            baseRequest = request //设置可识别的条码种类
        case .faceLandmarks:
            baseRequest = VNDetectFaceLandmarksRequest(completionHandler: completionHandle)
        case .rectangle:
            //矩形检测器在图像中查找表示真实世界矩形形状的区域
            baseRequest = VNDetectRectanglesRequest(completionHandler: completionHandle)
        case .faceRectangles:
            baseRequest = VNDetectFaceRectanglesRequest(completionHandler: completionHandle)
        }
        
        //6. 在global线程发送请求，防止阻塞主线程
        DispatchQueue.global().async {
            do{
                try requestHandle.perform([baseRequest])
            }catch{
                completeBack(nil, nil)
            }
        }
    }
    
    
    /// 人脸特征检测核心方法
    /// 功能说明：解析 Vision 框架返回的人脸检测结果，转换为业务可用的人脸框/关键点数据
    /// 处理逻辑：
    /// 1. 校验输入的 observations 有效性，过滤无效数据
    /// 2. 将 Vision 坐标系转换为 UI 坐标系（适配 UIImage 方向）
    /// 3. 根据全局配置（mcVisionDetectConfig）判断是否返回关键点
    /// 4. 封装人脸框数组 + 关键点数组，通过闭包回调返回
    /// - Parameters:
    ///   - observations: Vision 框架返回的人脸检测结果数组（VNDetectFaceRectanglesObservation/VNDetectFaceLandmarksObservation 类型）
    ///   - image: 待检测的原始图片（用于坐标系转换、尺寸适配）
    ///   - complecHandle: 检测结果回调闭包（主线程回调，避免 UI 操作异常）
    ///     - bigRectArr: 人脸矩形框数组（UI 坐标系，可直接用于绘制人脸框）
    ///     - backArr: 人脸扩展数据数组（根据配置返回：开启关键点则为 [VNFaceLandmarks2D]，否则为空）
    class func faceFeatureDectect(_ observations: [Any]?, image: UIImage, _ complecHandle: MCVisionDetectHandle) {
        //1. 获取识别到的VNRectangleObservation
        guard let boxArr = observations as? [VNFaceObservation] else { return }
        
        //2. 创建存储数组
        var faceArr = [MCFaceFeatureModel]()
        
        //3. 遍历所有特征
        for feature in boxArr {
            if feature.confidence < 0.6 {
                continue
            }
            let faceFeature = MCFaceFeatureModel(faceObservation: feature)
            faceFeature.faceObservation = feature
            faceArr.append(faceFeature)
        }
        
        //4. 回调
        complecHandle([], faceArr)
    }
    
    /// 视觉检测：针对 UIImageView 内的图片进行全类型视觉检测（文字/条码/矩形/人脸）
    /// 功能说明：自动读取 imageView.image 进行检测，根据全局配置（mcVisionDetectConfig）执行对应检测逻辑，
    ///          检测完成后通过 successBlock/failedBlock 回调结果状态，具体检测数据通过全局回调/属性返回（需结合业务场景适配）
    /// 适用场景：快速检测 UIImageView 展示的图片，无需手动传入 UIImage，简化调用流程
    /// 异常处理：自动校验 imageView.image 有效性，无图片/图片异常时触发 failedBlock
    /// - Parameters:
    ///   - imageView: 待检测的 UIImageView 实例（需保证 imageView.image 不为 nil）
    ///   - successBlock: 检测成功回调（无返回值，仅通知检测完成，具体结果需结合 MCFastVision 其他回调获取）
    ///   - failedBlock: 检测失败回调
    ///     - err: 失败原因描述（如"图片为空"、"检测请求初始化失败"等）
    class func detectImageView(imageView: UIImageView, successBlock: (() -> Void)? = nil, failedBlock: ((_ err: String) -> Void)? = nil) {
        guard let image: UIImage = imageView.image else {
            failedBlock?("未获取到待识别的图片")
            return
        }
        visionDetectImage(type: .faceLandmarks, image: image, { (bigRects, smallRects) in
            // bigRects 最大框
            let bigMax = MCVisionCoordinateConverter.maxRect(from: bigRects ?? [])
            
            // 1) 优先用 bigRects
            if let bigRect = bigMax {

                // 裁剪大区域
                let bigCrop: UIImage? = image.cropWithRect(cropRect: bigRect)
                imageView.image = bigCrop
                

                let smallRects: [CGRect] = smallRects as? [CGRect] ?? []
                // 2) 如果还想基于大区域再裁剪 smallRects（可选）
                if !(smallRects.isEmpty) {

                    // smallRects 是基于原图坐标的
                    // 要映射到 bigCrop 的坐标系：smallRect - bigRect.origin
                    let mappedSmallRects: [CGRect] = smallRects.map { r in
                        CGRect(
                            x: r.origin.x - bigRect.origin.x,
                            y: r.origin.y - bigRect.origin.y,
                            width: r.size.width,
                            height: r.size.height
                        )
                    }.filter { r in
                        // 过滤掉越界的
                        r.origin.x >= 0 &&
                        r.origin.y >= 0 &&
                        r.maxX <= bigRect.width &&
                        r.maxY <= bigRect.height
                    }

                    // 取映射后的最大 smallRect 再裁剪
                    if let mappedSmallMax = MCVisionCoordinateConverter.maxRect(from: mappedSmallRects) {
                        guard let smallCrop: UIImage = bigCrop?.cropWithRect(cropRect: mappedSmallMax) else {
                            failedBlock?("检测失败，内容裁剪出现异常")
                            return
                        }
                        imageView.image = smallCrop
                        successBlock?()
                        // 如果希望最终显示小框裁剪结果，就用这一行替换
                        // self.imageView.image = smallCrop
                        // 如果希望只是拿 smallCrop 去做下一步识别，这里就别改 imageView
                    }
                }
                //"无识别结果"
                successBlock?()
                return
            }
            let faceFeatureModels: [MCFaceFeatureModel] = smallRects as? [MCFaceFeatureModel] ?? []
            if faceFeatureModels.count > 0 {
                drawFaceLandmarks(imageView: imageView, faces: faceFeatureModels, successBlock: successBlock, failedBlock: failedBlock)
                return
            }
            let rect: CGRect? = smallRects?.first as? CGRect
            if rect != nil {
                // smallRects 最大框
                let smallMax: CGRect = MCVisionCoordinateConverter.maxRect(from: smallRects as? [CGRect] ?? []) ?? .zero
                if (smallMax != .zero) {
                    // 3) 如果没有 bigRects，fallback 用 smallRects
                    imageView.image = image.cropWithRect(cropRect: smallMax)
                    successBlock?()
                    return
                }
            }
            // 4) 都没有
            successBlock?()
        })
    }
}
// MARK: - 人脸识别
extension MCFastVision {
    
    /// 人脸关键点检测：针对 UIImageView 内的图片进行人脸关键点精准检测
    /// 功能说明：基于 Apple Vision 框架实现人脸关键点（眼睛/鼻子/嘴巴/下巴等）检测，
    ///          自动处理坐标系转换（Vision 坐标系 → UI 坐标系），封装为结构化的 MCVisionFaceLandmarksResult 模型返回，
    ///          检测逻辑受全局配置 mcVisionDetectConfig 控制（如 needKeyPoints、minDetectArea 等）
    /// 适用场景：人脸特征分析、美颜/美妆贴纸、人脸交互等需要人脸关键点的业务场景
    /// 异常处理：自动校验图片有效性、人脸检测结果有效性，异常时触发 failedBlock 并返回具体错误信息
    /// - Parameters:
    ///   - imageView: 待检测的 UIImageView 实例（需保证 imageView.image 不为 nil，且图片包含可检测的人脸）
    ///   - successBlock: 检测成功回调（主线程触发，可直接更新 UI）
    ///     - results: 人脸关键点检测结果数组，每个元素对应一张人脸的完整关键点信息（封装为 MCVisionFaceLandmarksResult 模型）
    ///   - failedBlock: 检测失败回调
    ///     - err: 失败原因描述（如"图片为空"、"未检测到人脸"、"关键点解析失败"等）
    public class func visionDetectFaceLandmarks(
        imageView: UIImageView,
        successBlock: ((_ results: [MCVisionFaceLandmarksResult]) -> Void)? = nil,
        failedBlock: ((_ err: String) -> Void)? = nil
    ) {

        guard let image: UIImage = imageView.image else {
            failedBlock?("未获取到待检测的图片")
            return
        }

        guard let cgImage: CGImage = image.cgImage else {
            failedBlock?("未获取到待检测的图片")
            return
        }

        // ⚠️ Vision 需要方向，否则坐标会错位
        let orientation = CGImagePropertyOrientation(
            rawValue: UInt32(image.imageOrientation.rawValue)
        ) ?? .up

        let request = VNDetectFaceLandmarksRequest { request, error in

            if let error = error {
                failedBlock?("检测失败：\(error.localizedDescription)")
                return
            }

            guard let observations: [VNFaceObservation] = request.results as? [VNFaceObservation] else {
                failedBlock?("检测失败，请求结果异常")
                return
            }

            if observations.isEmpty {
                successBlock?([])
                return
            }

            var results: [MCVisionFaceLandmarksResult] = []

            for obs: VNFaceObservation in observations {

                if obs.confidence < Float(MCFastVision.shared.mcVisionDetectConfig.minConfidence) { continue }

                // 人脸框（normalized → image）
                let faceRect = MCVisionCoordinateConverter.convertRect(obs.boundingBox, image)

                // landmarks 可能为空（比如检测到脸，但没检测出关键点）
                guard let landmarks = obs.landmarks else {
                    results.append(
                        MCVisionFaceLandmarksResult(
                            faceObservation: obs,
                            rect: faceRect,
                            confidence: obs.confidence,
                            leftEye: [],
                            rightEye: [],
                            leftEyebrow: [],
                            rightEyebrow: [],
                            leftPupil: [],
                            rightPupil: [],
                            nose: [],
                            noseCrest: [],
                            medianLine: [],
                            outerLips: [],
                            innerLips: [],
                            faceContour: []
                        )
                    )
                    continue
                }

                // 关键点：landmark点是“相对于人脸框的归一化坐标”
                // 所以需要：landmark → faceRect → image坐标
                let leftEye: [CGPoint] = convertLandmarkPoints(landmarks.leftEye, faceRect)
                let rightEye: [CGPoint] = convertLandmarkPoints(landmarks.rightEye, faceRect)

                let leftEyebrow: [CGPoint] = convertLandmarkPoints(landmarks.leftEyebrow, faceRect)
                let rightEyebrow: [CGPoint] = convertLandmarkPoints(landmarks.rightEyebrow, faceRect)
                
                let leftPupil: [CGPoint] = convertLandmarkPoints(landmarks.leftPupil, faceRect)
                let rightPupil: [CGPoint] = convertLandmarkPoints(landmarks.rightPupil, faceRect)

                let nose: [CGPoint] = convertLandmarkPoints(landmarks.nose, faceRect)
                let noseCrest: [CGPoint] = convertLandmarkPoints(landmarks.noseCrest, faceRect)
                let medianLine: [CGPoint] = convertLandmarkPoints(landmarks.medianLine, faceRect)

                let outerLips: [CGPoint] = convertLandmarkPoints(landmarks.outerLips, faceRect)
                let innerLips: [CGPoint] = convertLandmarkPoints(landmarks.innerLips, faceRect)

                let faceContour: [CGPoint] = convertLandmarkPoints(landmarks.faceContour, faceRect)

                results.append(
                    MCVisionFaceLandmarksResult(
                        faceObservation: obs,
                        rect: faceRect,
                        confidence: obs.confidence,
                        leftEye: leftEye,
                        rightEye: rightEye,
                        leftEyebrow: leftEyebrow,
                        rightEyebrow: rightEyebrow,
                        leftPupil: leftPupil,
                        rightPupil: rightPupil,
                        nose: nose,
                        noseCrest: noseCrest,
                        medianLine: medianLine,
                        outerLips: outerLips,
                        innerLips: innerLips,
                        faceContour: faceContour
                    )
                )
            }

            DispatchQueue.main.async {
                let config = MCFastVision.shared.mcVisionDetectConfig.drawConfig
                if config.showConfidence {
                    DispatchQueue.main.async {
                        MCFastVision.drawVisionRecognitionFaceLandmarksResult(imageView: imageView, results: results)
                        drawFaceLandmarks(imageView: imageView, faceLandmarksResults: results, successBlock: {
                            successBlock?(results)
                        }, failedBlock: failedBlock)
                    }
                }
                successBlock?(results)
            }
        }

        // 只要 landmarks（不用额外配置也行）
        // request.revision = VNDetectFaceLandmarksRequestRevision3  // 可选

        let handler = VNImageRequestHandler(
            cgImage: cgImage,
            orientation: orientation,
            options: [:]
        )

        DispatchQueue.global().async {
            do {
                try handler.perform([request])
            } catch {
                failedBlock?("检测失败，发送请求出现异常")
            }
        }
    }
    
    /// 把 landmark 点转换成 image 坐标（核心）
    /// - Parameters:
    ///   - region: landmark
    ///   - faceRect: 人脸框
    /// - Returns: image 坐标
    private class func convertLandmarkPoints(
        _ region: VNFaceLandmarkRegion2D?,
        _ faceRect: CGRect
    ) -> [CGPoint] {

        guard let region = region else { return [] }

        var points: [CGPoint] = []
        points.reserveCapacity(region.pointCount)

        for i in 0..<region.pointCount {

            let p = region.normalizedPoints[i]
            // p.x p.y 是相对 faceRect 的归一化坐标

            let x = faceRect.origin.x + CGFloat(p.x) * faceRect.size.width
            let y = faceRect.origin.y + (1 - CGFloat(p.y)) * faceRect.size.height
            // ⚠️ y 方向需要翻转，因为 Vision landmark 的 y 原点在左下

            points.append(CGPoint(x: x, y: y))
        }

        return points
    }
    
    /// 人脸矩形框检测：针对 UIImageView 内的图片进行人脸区域（矩形框）检测
    /// 功能说明：基于 Apple Vision 框架的 VNDetectFaceRectanglesRequest 实现人脸框检测，
    ///          自动完成 Vision 坐标系到 UI 坐标系的转换（适配 UIImageView 图片方向/尺寸），
    ///          并根据全局配置 mcVisionDetectConfig.minDetectArea 过滤小尺寸无效人脸框，
    ///          最终将检测结果封装为 MCVisionFaceRectResult 模型返回
    /// 适用场景：人脸定位、人脸区域裁剪、人脸数量统计等仅需人脸框的轻量级业务场景
    /// 异常处理：自动校验图片有效性、人脸检测结果，无图片/未检测到人脸/检测请求异常时触发 failedBlock
    /// - Parameters:
    ///   - imageView: 待检测的 UIImageView 实例（需确保 imageView.image 不为 nil，否则直接触发 failedBlock）
    ///   - successBlock: 检测成功回调（主线程触发，可直接用于 UI 绘制人脸框）
    ///     - results: 人脸矩形框检测结果数组，每个元素对应一张人脸的框信息（封装为 MCVisionFaceRectResult 模型）
    ///   - failedBlock: 检测失败回调
    ///     - err: 失败原因描述（如"图片为空"、"未检测到有效人脸"、"人脸检测请求初始化失败"等）
    public class func visionDetectFaceRectangles(
        imageView: UIImageView,
        successBlock: ((_ results: [MCVisionFaceRectResult]) -> Void)? = nil,
        failedBlock: ((_ err: String) -> Void)? = nil
    ) {

        guard let image: UIImage = imageView.image else {
            failedBlock?("未获取到待检测的图片")
            return
        }

        guard let cgImage: CGImage = image.cgImage else {
            failedBlock?("未获取到待检测的图片")
            return
        }

        // ⚠️ Vision 需要方向，否则坐标会错位
        let orientation = CGImagePropertyOrientation(
            rawValue: UInt32(image.imageOrientation.rawValue)
        ) ?? .up

        let request = VNDetectFaceRectanglesRequest { request, error in

            if let error = error {
                failedBlock?("检测失败：\(error.localizedDescription)")
                return
            }

            guard let observations = request.results as? [VNFaceObservation] else {
                failedBlock?("检测失败，请求结果异常")
                return
            }

            if observations.isEmpty {
                failedBlock?("未检测到人脸")
                return
            }

            var results: [MCVisionFaceRectResult] = []

            for obs: VNFaceObservation in observations {

                if obs.confidence < Float(MCFastVision.shared.mcVisionDetectConfig.minConfidence) {
                    // 置信度低于预期最低值，过滤掉
                    continue
                }

                // boundingBox 是 normalized（左下角原点）
                let rectInImage = MCVisionCoordinateConverter.convertRect(obs.boundingBox, image)

                results.append(
                    MCVisionFaceRectResult(
                        faceObservation: obs,
                        rect: rectInImage,
                        confidence: obs.confidence
                    )
                )
            }

            DispatchQueue.main.async {
                let boxLineOverlayLayer: CALayer = newBoxLineOverlayLayer(imageView: imageView)
                //        全局绘制配置
                let config = MCFastVision.shared.mcVisionDetectConfig.drawConfig
                // 绘制人脸框
                // boundingBox 是 normalized，且坐标原点在左下角
                if config.showFaceBox {
                    for result: MCVisionFaceRectResult in results {
                        let conf: CGFloat = CGFloat(result.faceObservation.confidence)
                        let boundingBox: CGRect = result.faceObservation.boundingBox
                        drawBoxAndConfInImageView(imageView: imageView, boxLineOverlayLayer: boxLineOverlayLayer, conf: conf, boundingBox: boundingBox)
                    }
                }
                successBlock?(results)
            }
        }

        let handler = VNImageRequestHandler(
            cgImage: cgImage,
            orientation: orientation,
            options: [:]
        )

        DispatchQueue.global().async {
            do {
                try handler.perform([request])
            } catch {
                failedBlock?("检测失败，发送请求出现异常")
            }
        }
    }

}

// MARK: - 文本识别
extension MCFastVision {
    
    /// Text Recognize文本识别
    /// - Parameters:
    ///   - image: 图片
    ///   - config: 文本配置
    ///   - completion: 回调
    public class func visionRecognizeText(
        imageView: UIImageView,
        successBlock: ((_ results: [MCVisionTextResult]) -> Void)? = nil,
        failedBlock: ((_ err: String) -> Void)? = nil
    ) {
    
        guard let image: UIImage = imageView.image else {
            failedBlock?("未获取到待识别的图片")
            return
        }
        guard let cgImage: CGImage = image.cgImage else {
            failedBlock?("未获取到待识别的图片")
            return
        }
        
        // ⚠️ Vision 需要方向，否则结果坐标可能错位
        let orientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue))
        
        let request = VNRecognizeTextRequest { request, error in
            if error != nil {
                failedBlock?("检测失败：\(error?.localizedDescription ?? "")")
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                failedBlock?("检测失败，请求结果异常")
                return
            }
            
            var results: [MCVisionTextResult] = []
            
            for obs: VNRecognizedTextObservation in observations {
                
                // topCandidates(1) 就够用了
                guard let candidate = obs.topCandidates(1).first else { continue }
                
                let text = candidate.string
                let conf = candidate.confidence
                
                if conf < Float(MCFastVision.shared.mcVisionDetectConfig.minConfidence) {
                    continue
                }
                
                // obs.boundingBox 是 normalized（左下角原点）
                let rectInImage = MCVisionCoordinateConverter.convertRect(obs.boundingBox, image)
                
                results.append(
                    MCVisionTextResult(
                        text: text,
                        confidence: conf,
                        rect: rectInImage
                    )
                )
            }
            let config = MCFastVision.shared.mcVisionDetectConfig.drawConfig
            if config.showConfidence {
                DispatchQueue.main.async {
                    MCFastVision.drawVisionRecognitionTextResult(imageView: imageView, results: results)
                }
            }
            successBlock?(results)
        }
        
        let config = MCFastVision.shared.mcVisionDetectConfig.textConfig
        // 配置
        request.recognitionLevel = config.recognitionLevel
        request.usesLanguageCorrection = config.usesLanguageCorrection
        
        if !config.languages.isEmpty {
            request.recognitionLanguages = config.languages
        }
        
        if !config.customWords.isEmpty {
            // ✅给 OCR 一个“词库提示”，让它在识别时更倾向于把模糊字符识别成提供的这些词。
            // 比如要识别的文本里经常出现：设备型号：SN-AX200 工单号：WO20260206 公司产品名：MorganAI
            // 特定英文缩写：IDFA、UUID、BLE，这些词 OCR 很容易识别错，比如：
            // WO20260206 被识别成 W020260206，IDFA 被识别成 IDPA
            // 这时候塞进 customWords，识别准确率会明显提升。
            request.customWords = config.customWords
        }
        
        // 执行
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation ?? .up, options: [:])
        
        DispatchQueue.global().async {
            do {
                try handler.perform([request])
            } catch {
                failedBlock?("检测失败，发送请求出现异常")
            }
        }
    }
}
// MARK: - 二维码识别/条形码识别
extension MCFastVision {
    
    /// 条码/二维码识别：针对 UIImageView 内的图片进行多类型条码/二维码解析
    /// 功能说明：基于 Apple Vision 框架的 VNDetectBarcodesRequest 实现条码识别，
    ///          支持自定义识别码制，自动过滤无效条码，完成坐标系转换（Vision → UI），
    ///          最终将条码内容、码制、位置等信息封装为 MCVisionBarcodeResult 模型返回
    /// 适用场景：扫码支付、商品溯源、信息录入等需要解析条码/二维码的业务场景
    /// 异常处理：自动校验图片有效性、条码识别结果，无图片/未识别到条码/识别请求异常时触发 failedBlock
    /// - Parameters:
    ///   - imageView: 待检测的 UIImageView 实例（需确保 imageView.image 不为 nil，否则直接触发 failedBlock）
    ///   - symbologies: 指定要识别的条码/二维码类型（默认支持主流码制：QR码、EAN13、Code128等），可根据业务需求自定义
    ///   - successBlock: 识别成功回调（主线程触发，可直接使用识别结果）
    ///     - results: 条码识别结果数组，每个元素对应一个识别到的条码信息（封装为 MCVisionBarcodeResult 模型）
    ///   - failedBlock: 识别失败回调
    ///     - err: 失败原因描述（如"图片为空"、"未识别到有效条码"、"条码识别请求初始化失败"等）
    public class func visionRecognizeBarcode(
        imageView: UIImageView,
        symbologies: [VNBarcodeSymbology] = [.QR, .EAN13, .Code128, .UPCE, .PDF417, .Aztec, .DataMatrix],
        successBlock: ((_ results: [MCVisionBarcodeResult]) -> Void)? = nil,
        failedBlock: ((_ err: String) -> Void)? = nil
    ) {

        guard let image: UIImage = imageView.image else {
            failedBlock?("未获取到待识别的图片")
            return
        }

        guard let cgImage: CGImage = image.cgImage else {
            failedBlock?("未获取到待识别的图片")
            return
        }

        // ⚠️ Vision 需要方向，否则坐标会错位
        let orientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue)) ?? .up

        let request = VNDetectBarcodesRequest { request, error in
            if let error = error {
                failedBlock?("识别失败：\(error.localizedDescription)")
                return
            }

            guard let observations = request.results as? [VNBarcodeObservation] else {
                failedBlock?("检测失败，请求结果异常")
                return
            }

            var results: [MCVisionBarcodeResult] = []

            for obs: VNBarcodeObservation in observations {
                //置信度过滤
                if obs.confidence < Float(MCFastVision.shared.mcVisionDetectConfig.minConfidence) {
                    continue
                }

                // 条码内容（大多数情况用这个）
                let payload = obs.payloadStringValue ?? ""

                // 类型：QR / EAN13 / Code128 ...
                let symbology = obs.symbology.rawValue

                // 置信度（0~1）
                let confidence = obs.confidence

                // boundingBox 是 normalized（左下角原点）
                let rectInImage = MCVisionCoordinateConverter.convertRect(obs.boundingBox, image)
                
                //
                let type: MCVisionBarcodeType = {
                    // 二维码（2D）常见类型： .QR，.Aztec，.PDF417，.DataMatrix
                    // 条形码（1D）常见类型： .EAN13，.EAN8，.Code128，.Code39，.UPCE，.ITF14
                    switch obs.symbology {
                    case .QR, .Aztec, .PDF417, .DataMatrix:
                        return .code2D
                    default:
                        return .barcode1D
                    }
                }()

                results.append(
                    MCVisionBarcodeResult(
                        payload: payload,
                        symbology: symbology,
                        confidence: confidence,
                        rect: rectInImage,
                        type: type
                    )
                )
            }

            DispatchQueue.main.async {
                let config = MCFastVision.shared.mcVisionDetectConfig.drawConfig
                if config.showConfidence {
                    DispatchQueue.main.async {
                        MCFastVision.drawVisionRecognitionBarcodeResult(imageView: imageView, results: results)
                    }
                }
                successBlock?(results)
            }
        }

        // 只识别你指定的类型（不指定也可以，但指定更快）
        request.symbologies = symbologies

        let handler = VNImageRequestHandler(
            cgImage: cgImage,
            orientation: orientation,
            options: [:]
        )

        DispatchQueue.global().async {
            do {
                try handler.perform([request])
            } catch {
                failedBlock?("识别失败：\(error.localizedDescription)")
            }
        }
    }
}

// MARK: - 矩形检测

extension MCFastVision {
    
    /// 矩形检测：针对 UIImageView 内的图片进行矩形区域精准检测
    /// 功能说明：基于 Apple Vision 框架的 VNDetectRectanglesRequest 实现矩形检测，
    ///          自动过滤小尺寸/不规则矩形，完成 Vision 坐标系到 UI 坐标系的转换（适配图片方向与尺寸），
    ///          最终将矩形四个顶点、边界框等信息封装为 MCVisionRectangleResult 模型返回
    /// 适用场景：文档扫描（提取纸张边框）、屏幕/卡片识别、物体轮廓定位等需要检测矩形区域的业务场景
    /// 异常处理：自动校验图片有效性、矩形检测结果，无图片/未检测到有效矩形/检测请求异常时触发 failedBlock
    /// - Parameters:
    ///   - imageView: 待检测的 UIImageView 实例（需确保 imageView.image 不为 nil，否则直接触发 failedBlock）
    ///   - successBlock: 检测成功回调（主线程触发，可直接用于 UI 绘制矩形框）
    ///     - results: 矩形检测结果数组，每个元素对应一个检测到的矩形信息（封装为 MCVisionRectangleResult 模型）
    ///   - failedBlock: 检测失败回调
    ///     - err: 失败原因描述（如"图片为空"、"未检测到有效矩形"、"矩形检测请求初始化失败"等）
    public class func visionDetectRectangles(
        imageView: UIImageView,
        successBlock: ((_ results: [MCVisionRectangleResult]) -> Void)? = nil,
        failedBlock: ((_ err: String) -> Void)? = nil
    ) {

        guard let image: UIImage = imageView.image else {
            failedBlock?("未获取到待识别的图片")
            return
        }

        guard let cgImage: CGImage = image.cgImage else {
            failedBlock?("未获取到待识别的图片")
            return
        }

        // ⚠️ Vision 需要方向，否则坐标会错位
        let orientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue)) ?? .up

        let request = VNDetectRectanglesRequest { request, error in

            if let error = error {
                failedBlock?("矩形检测失败：\(error.localizedDescription)")
                return
            }

            guard let observations = request.results as? [VNRectangleObservation] else {
                failedBlock?("检测失败，请求结果异常")
                return
            }

            var results: [MCVisionRectangleResult] = []

            for obs: VNRectangleObservation in observations {
                //置信度过滤
                if obs.confidence < Float(MCFastVision.shared.mcVisionDetectConfig.minConfidence) {
                    continue
                }

                let rectInImage = MCVisionCoordinateConverter.convertRect(obs.boundingBox, image)
                let boundingBox: CGRect = obs.boundingBox
                let imageSize: CGSize = image.size

                // 四个角点（normalized -> image坐标）
                let tl = MCVisionCoordinateConverter.convertVisionNormalizedPointToImagePoint(point: obs.topLeft, boundingBox: boundingBox, imageSize: imageSize)
                let tr = MCVisionCoordinateConverter.convertVisionNormalizedPointToImagePoint(point: obs.topRight, boundingBox: boundingBox, imageSize: imageSize)
                let bl = MCVisionCoordinateConverter.convertVisionNormalizedPointToImagePoint(point: obs.bottomLeft, boundingBox: boundingBox, imageSize: imageSize)
                let br = MCVisionCoordinateConverter.convertVisionNormalizedPointToImagePoint(point: obs.bottomRight, boundingBox: boundingBox, imageSize: imageSize)

                results.append(
                    MCVisionRectangleResult(
                        confidence: obs.confidence,
                        rect: rectInImage,
                        topLeft: tl,
                        topRight: tr,
                        bottomLeft: bl,
                        bottomRight: br
                    )
                )
            }

            DispatchQueue.main.async {
                let config = MCFastVision.shared.mcVisionDetectConfig.drawConfig
                if config.showConfidence {
                    DispatchQueue.main.async {
                        MCFastVision.drawVisionRecognitionRectangleResult(imageView: imageView, results: results)
                    }
                }
                successBlock?(results)
            }
        }
        
        let config = MCFastVision.shared.mcVisionDetectConfig.rectangleConfig
        // 配置（这些参数非常关键）
        request.minimumConfidence = config.minimumConfidence
        request.maximumObservations = config.maximumObservations
        request.minimumSize = config.minimumSize
        request.minimumAspectRatio = config.minimumAspectRatio
        request.maximumAspectRatio = config.maximumAspectRatio
        request.quadratureTolerance = config.quadratureTolerance

        let handler = VNImageRequestHandler(
            cgImage: cgImage,
            orientation: orientation,
            options: [:]
        )

        DispatchQueue.global().async {
            do {
                try handler.perform([request])
            } catch {
                failedBlock?("矩形检测失败：\(error.localizedDescription)")
            }
        }
    }
}

//MARK: 绘制关键点、置信度和目标方框
extension MCFastVision {
    /// 绘制脸部关键点
    /// - Parameters:
    ///   - imageView: 图片视图
    ///   - boxLineOverlayLayer: 图片视图绘制层
    ///   - image: 图片
    ///   - faces: 脸部特征对象识别结果
    class func drawFaceLandmarks(imageView: UIImageView, faces: [MCFaceFeatureModel], successBlock: (() -> Void)? = nil, failedBlock: ((_ err: String) -> Void)? = nil) {
        DispatchQueue.main.async(execute: {
            guard let image: UIImage = imageView.image else {
                failedBlock?("检测失败，检测内容有误")
                return
            }
            if faces.count <= 0 {
                successBlock?()
                return
            }
            
            let boxLineOverlayLayer: CALayer = newBoxLineOverlayLayer(imageView: imageView)
            //        全局绘制配置
            let config = MCFastVision.shared.mcVisionDetectConfig.drawConfig
            
            // 先清空旧的
            boxLineOverlayLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
            imageView.image = image
            let imageSize: CGSize = image.size
            let viewSize: CGSize = imageView.bounds.size
            for faceModel: MCFaceFeatureModel in faces {

                let boundingBox: CGRect = faceModel.faceObservation.boundingBox
                
                // 绘制人脸识别关键点
                for regionOpt: VNFaceLandmarkRegion2D? in faceModel.landmarkArr {

                    guard let region: VNFaceLandmarkRegion2D = regionOpt else { continue }

                    let path: UIBezierPath = UIBezierPath()

                    for i in 0..<region.pointCount {
                        let p: CGPoint = region.normalizedPoints[i] // (0~1) 相对人脸框

                        // 1) 转成图片坐标
                        let imagePoint: CGPoint = MCVisionCoordinateConverter.convertVisionNormalizedPointToImagePoint(
                            point: p,
                            boundingBox: boundingBox,
                            imageSize: imageSize
                        )

                        // 2) 再把图片坐标映射到 imageView 坐标
                        let viewPoint: CGPoint = MCVisionCoordinateConverter.convertImagePointToImageView(
                            imagePoint: imagePoint,
                            imageSize: imageSize,
                            imageViewSize: viewSize,
                            contentMode: imageView.contentMode
                        )
                        
                        if i == 0 {
                            //起始点
                            path.move(to: viewPoint)
                        } else {
                            path.addLine(to: viewPoint)
                        }
                        // "start viewPoint:(98.8943528393787, 156.6411467798796)"
                        // "addLine to viewPoint:(102.93694258821809, 156.73664090347808)"
                    }

                    // 封闭轮廓（眼睛、嘴唇等）
                    path.close()

                    let shapeLayer: CAShapeLayer = CAShapeLayer()
                    shapeLayer.path = path.cgPath
                    shapeLayer.strokeColor = config.landmarkStrokeColor.cgColor
                    shapeLayer.fillColor = config.landmarkFillColor.cgColor
                    shapeLayer.lineWidth = config.landmarkLineWidth

                    boxLineOverlayLayer.addSublayer(shapeLayer)
                }
                
                // 绘制人脸框
                // boundingBox 是 normalized，且坐标原点在左下角
                if config.showFaceBox {
                    drawFaceFeatureRect(imageView: imageView, boxLineOverlayLayer: boxLineOverlayLayer, faceModel: faceModel, on: image)
                }
            }
            successBlock?()
        })
    }
    
    /// 人脸特征框绘制：在指定 UIImageView 上绘制人脸检测框（底层通过 CALayer 实现，无侵入式绘制）
    /// 功能说明：根据人脸检测结果模型（MCFaceFeatureModel）计算适配 UIImageView 的人脸框坐标，
    ///          生成带样式的边框 Layer 并添加到指定的 overlayLayer 上，支持图片尺寸/方向自适应，
    ///          绘制完成后 Layer 会自动贴合 UIImageView 缩放/旋转，保证视觉对齐
    /// 设计细节：私有方法仅内部调用，避免外部误操作绘制逻辑；基于 CALayer 绘制而非直接修改图片，便于后续移除/更新框体
    /// - Parameters:
    ///   - imageView: 要绘制人脸框的目标 UIImageView（需与检测的图片关联，保证坐标适配）
    ///   - boxLineOverlayLayer: 承载人脸框的底层 CALayer（建议创建独立 Layer 用于绘制，避免与原有内容混淆）
    ///   - faceModel: 人脸特征模型（包含人脸矩形框、关键点等检测结果，用于计算绘制坐标）
    ///   - image: 原始检测图片（用于校准 UIImageView 缩放/裁剪后的坐标偏移，保证框体精准对齐）
    private class func drawFaceFeatureRect(imageView: UIImageView, boxLineOverlayLayer: CALayer, faceModel: MCFaceFeatureModel, on image: UIImage) {
        
        // 0) 画框 + 置信度
        let conf: CGFloat = CGFloat(faceModel.faceObservation.confidence)
        let boundingBox: CGRect = faceModel.faceObservation.boundingBox
        drawBoxAndConfInImageView(imageView: imageView, boxLineOverlayLayer: boxLineOverlayLayer, conf: conf, boundingBox: boundingBox)
    }
    
    /// 人脸关键点绘制：在指定 UIImageView 上可视化绘制人脸关键点（眼睛/鼻子/嘴巴等）
    /// 功能说明：基于人脸关键点检测结果数组（MCVisionFaceLandmarksResult），
    ///          自动计算适配 UIImageView 尺寸/方向的关键点坐标，通过 CALayer 绘制关键点标记（如圆点/连线），
    ///          绘制层与 UIImageView 内容分离，支持后续快速清除/更新，不破坏原始图片
    /// 设计细节：关键点绘制样式（颜色/大小/连线）内置优化，适配不同分辨率图片，保证视觉清晰
    /// - Parameters:
    ///   - imageView: 要绘制关键点的目标 UIImageView（需与检测图片关联，保证坐标精准对齐）
    ///   - results: 人脸关键点检测结果数组（每个元素对应一张人脸的完整关键点信息，包含坐标、类型等）
    class func drawVisionRecognitionFaceLandmarksResult(imageView: UIImageView, results: [MCVisionFaceLandmarksResult]) {
        let boxLineOverlayLayer: CALayer = newBoxLineOverlayLayer(imageView: imageView)
        for visionResult: MCVisionFaceLandmarksResult in results {
            // 0) 画框 + 置信度
            let conf: CGFloat = CGFloat(visionResult.confidence)
            let boundingBox: CGRect = visionResult.rect
            drawBoxAndConfInImageView(imageView: imageView, boxLineOverlayLayer: boxLineOverlayLayer, conf: conf, boundingBox: boundingBox)
        }
    }
    
    /// 条码/二维码识别结果绘制：在指定 UIImageView 上可视化绘制条码/二维码的识别框与核心信息
    /// 功能说明：基于条码识别结果数组（MCVisionBarcodeResult），自动计算适配 UIImageView 尺寸/方向的条码框坐标，
    ///          通过 CALayer 绘制条码边框（含码制标注），可选展示条码内容文本，绘制层独立于图片内容，
    ///          支持多条码同时绘制，边框样式（颜色/线宽/圆角）内置优化，保证不同码制识别框视觉区分度
    /// 设计细节：绘制逻辑适配 UIImageView 的 contentMode（如 AspectFit/AspectFill），避免因图片缩放导致框体偏移
    /// - Parameters:
    ///   - imageView: 要绘制条码框的目标 UIImageView（需与条码识别的原始图片关联，保证坐标精准对齐）
    ///   - results: 条码识别结果数组（每个元素对应一个识别到的条码，包含条码内容、码制、位置矩形等核心信息）
    class func drawVisionRecognitionBarcodeResult(imageView: UIImageView, results: [MCVisionBarcodeResult]) {
        let boxLineOverlayLayer: CALayer = newBoxLineOverlayLayer(imageView: imageView)
        for visionResult: MCVisionBarcodeResult in results {
            // 0) 画框 + 置信度
            let conf: CGFloat = CGFloat(visionResult.confidence)
            let boundingBox: CGRect = visionResult.rect
            drawBoxAndConfInImageView(imageView: imageView, boxLineOverlayLayer: boxLineOverlayLayer, conf: conf, boundingBox: boundingBox)
        }
    }
    
    /// 矩形检测结果绘制：在指定 UIImageView 上可视化绘制检测到的矩形区域（含四个顶点与边框）
    /// 功能说明：基于矩形检测结果数组（MCVisionRectangleResult），自动计算适配 UIImageView 尺寸/方向的矩形坐标，
    ///          通过 CALayer 绘制矩形边框（含顶点标记），支持多矩形同时绘制，边框样式（颜色/线宽/顶点大小）内置优化，
    ///          绘制层独立于 UIImageView 原始图片内容，便于后续清除/更新，不修改原图
    /// 设计细节：适配 UIImageView 的 contentMode（如 AspectFit/AspectFill）和图片旋转方向，保证矩形框与实际区域精准对齐，
    ///          过滤过小/无效矩形，避免冗余绘制影响视觉效果
    /// - Parameters:
    ///   - imageView: 要绘制矩形框的目标 UIImageView（需与矩形检测的原始图片关联，保证坐标适配）
    ///   - results: 矩形检测结果数组（每个元素对应一个检测到的矩形，包含四个顶点坐标、边界框等核心信息）
    class func drawVisionRecognitionRectangleResult(imageView: UIImageView, results: [MCVisionRectangleResult]) {
        let boxLineOverlayLayer: CALayer = newBoxLineOverlayLayer(imageView: imageView)
        for visionResult: MCVisionRectangleResult in results {
            // 0) 画框 + 置信度
            let conf: CGFloat = CGFloat(visionResult.confidence)
            let boundingBox: CGRect = visionResult.rect
            drawBoxAndConfInImageView(imageView: imageView, boxLineOverlayLayer: boxLineOverlayLayer, conf: conf, boundingBox: boundingBox)
        }
    }
    
    /// 文字识别结果绘制：在指定 UIImageView 上可视化绘制文字识别区域与识别内容
    /// 功能说明：基于文字识别结果数组（MCVisionTextResult），自动计算适配 UIImageView 尺寸/方向的文字框坐标，
    ///          通过 CALayer 绘制文字边界框，同时可选展示识别出的文字内容（标注在框体旁），
    ///          支持多行/多区域文字同时绘制，边框样式（颜色/线宽）与文字标注样式（字体/大小/颜色）内置优化，
    ///          绘制层独立于 UIImageView 原始图片，便于后续清除/更新，不修改原图
    /// 设计细节：适配 UIImageView 的 contentMode 与图片旋转方向，保证文字框与实际文字区域精准对齐；
    ///          自动过滤置信度低的文字结果，避免无效绘制，提升视觉清晰度
    /// - Parameters:
    ///   - imageView: 要绘制文字识别结果的目标 UIImageView（需与文字识别的原始图片关联，保证坐标适配）
    ///   - results: 文字识别结果数组（每个元素对应一个文字区域，包含文字内容、位置矩形、置信度等核心信息）
    class func drawVisionRecognitionTextResult(imageView: UIImageView, results: [MCVisionTextResult]) {
        let boxLineOverlayLayer: CALayer = newBoxLineOverlayLayer(imageView: imageView)
        for visionTextResult: MCVisionTextResult in results {
            // 0) 画框 + 置信度
            let conf: CGFloat = CGFloat(visionTextResult.confidence)
            let boundingBox: CGRect = visionTextResult.rect
            drawBoxAndConfInImageView(imageView: imageView, boxLineOverlayLayer: boxLineOverlayLayer, conf: conf, boundingBox: boundingBox)
        }
    }
    
    /// 人脸关键点绘制（带结果回调）：在指定 UIImageView 上可视化绘制人脸关键点，并通过回调返回绘制结果状态
    /// 功能说明：基于人脸关键点检测结果数组（MCVisionFaceLandmarksResult），自动计算适配 UIImageView 尺寸/方向的关键点坐标，
    ///          通过 CALayer 绘制关键点标记（眼睛/鼻子/嘴巴等）及连线，绘制层独立于原图，支持多个人脸同时绘制；
    ///          绘制完成/失败时通过回调通知外部，便于业务层执行后续逻辑（如绘制完成后隐藏加载动画）
    /// 设计细节：内置关键点绘制有效性校验（无有效结果/图片异常时触发失败回调），适配 UIImageView 的 contentMode，
    ///          保证关键点与人脸区域精准对齐，绘制样式（颜色/大小）内置优化
    /// - Parameters:
    ///   - imageView: 要绘制人脸关键点的目标 UIImageView（需与检测图片关联，否则触发失败回调）
    ///   - faceLandmarksResults: 人脸关键点检测结果数组（每个元素对应一张人脸的完整关键点信息）
    ///   - successBlock: 绘制成功回调（主线程触发，无返回值，仅通知绘制完成）
    ///   - failedBlock: 绘制失败回调（主线程触发，返回具体失败原因）
    ///     - err: 失败原因描述（如"无有效人脸关键点数据"、"UIImageView 无图片"、"坐标转换失败"等）
    class func drawFaceLandmarks(imageView: UIImageView, faceLandmarksResults: [MCVisionFaceLandmarksResult], successBlock: (() -> Void)? = nil, failedBlock: ((_ err: String) -> Void)? = nil) {
        DispatchQueue.main.async(execute: {
            guard let image: UIImage = imageView.image else {
                failedBlock?("检测失败，检测内容有误")
                return
            }
            if faceLandmarksResults.count <= 0 {
                successBlock?()
                return
            }
            
            let boxLineOverlayLayer: CALayer = newBoxLineOverlayLayer(imageView: imageView)
            //        全局绘制配置
            let config = MCFastVision.shared.mcVisionDetectConfig.drawConfig
            
            // 先清空旧的
            boxLineOverlayLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
            imageView.image = image
            let imageSize: CGSize = image.size
            let viewSize: CGSize = imageView.bounds.size
            for faceModel: MCVisionFaceLandmarksResult in faceLandmarksResults {
                
                let path: UIBezierPath = UIBezierPath()
                // 绘制人脸识别关键点
                for i: Int in 0..<faceModel.landmarkArr.count {
                    let imagePoints: [CGPoint] = faceModel.landmarkArr[i]
                    for i: Int in 0..<imagePoints.count {
                        let imagePoint: CGPoint = imagePoints[i]
                        // 2) 再把图片坐标映射到 imageView 坐标
                        let viewPoint: CGPoint = MCVisionCoordinateConverter.convertImagePointToImageView(
                            imagePoint: imagePoint,
                            imageSize: imageSize,
                            imageViewSize: viewSize,
                            contentMode: imageView.contentMode
                        )
                        
                        if i == 0 {
                            //起始点
                            path.move(to: viewPoint)
                        } else {
                            path.addLine(to: viewPoint)
                        }
                        // "start viewPoint:(98.8943528393787, 156.6411467798796)"
                        // "addLine to viewPoint:(102.93694258821809, 156.73664090347808)"
                        
                    }
                    
                    // 封闭轮廓（眼睛、嘴唇等）
                    path.close()
                    
                    let shapeLayer: CAShapeLayer = CAShapeLayer()
                    shapeLayer.path = path.cgPath
                    shapeLayer.strokeColor = config.landmarkStrokeColor.cgColor
                    shapeLayer.fillColor = config.landmarkFillColor.cgColor
                    shapeLayer.lineWidth = config.landmarkLineWidth
                    
                    boxLineOverlayLayer.addSublayer(shapeLayer)
                }
                
                // 绘制人脸框
                // boundingBox 是 normalized，且坐标原点在左下角
                if config.showFaceBox {
                    drawFaceFeatureRect(imageView: imageView, boxLineOverlayLayer: boxLineOverlayLayer, faceLandmarksResult: faceModel, on: image)
                }
            }
            successBlock?()
        })
    }
    
    /// 人脸特征框绘制（私有）：基于人脸关键点结果模型，在指定 Layer 上绘制人脸矩形框（适配图片/视图尺寸）
    /// 功能说明：从 MCVisionFaceLandmarksResult 中解析人脸边界框信息，结合原始图片尺寸与 UIImageView 显示参数，
    ///          完成 Vision 坐标系到 UI 坐标系的精准转换，生成带样式的人脸框 Layer 并添加到指定的 overlayLayer 上；
    ///          绘制逻辑适配图片旋转/缩放、UIImageView 的 contentMode，保证人脸框与人脸区域完全对齐
    /// 设计细节：私有方法仅内部调用，专注人脸框绘制核心逻辑，与关键点绘制解耦；基于独立 Layer 绘制，避免污染原图/视图原有内容
    /// - Parameters:
    ///   - imageView: 承载绘制结果的目标 UIImageView（用于校准框体显示尺寸与位置）
    ///   - boxLineOverlayLayer: 人脸框的承载 Layer（建议使用独立 Layer 管理绘制内容，便于后续清除/更新）
    ///   - faceLandmarksResult: 人脸关键点结果模型（包含人脸边界框、关键点等核心数据，用于提取人脸框坐标）
    ///   - image: 原始检测图片（用于计算坐标转换的基准，解决图片缩放/旋转导致的框体偏移问题）
    private class func drawFaceFeatureRect(imageView: UIImageView, boxLineOverlayLayer: CALayer, faceLandmarksResult: MCVisionFaceLandmarksResult, on image: UIImage) {
        
        // 0) 画框 + 置信度
        let conf: CGFloat = CGFloat(faceLandmarksResult.faceObservation.confidence)
        let boundingBox: CGRect = faceLandmarksResult.faceObservation.boundingBox
        drawBoxAndConfInImageView(imageView: imageView, boxLineOverlayLayer: boxLineOverlayLayer, conf: conf, boundingBox: boundingBox)
    }
    
    // MARK: - Draw box and confidence
    /// 创建人脸/条码/文字等检测框的承载 Layer：为 UIImageView 生成独立的绘制层（用于承载各类视觉检测结果的框体/标记）
    /// 功能说明：根据 UIImageView 的尺寸、contentMode 自动创建适配的 CALayer，
    ///          Layer 尺寸与 UIImageView 内容区域完全匹配，默认清空原有子 Layer，
    ///          保证绘制的检测框与图片精准对齐，且不影响 UIImageView 原有内容
    /// 设计细节：返回的 Layer 作为绘制容器，统一管理所有检测框绘制内容，便于后续批量清除/更新，
    ///          该 Layer 可直接添加到 UIImageView.layer 上，也可作为子 Layer 嵌套使用
    /// - Parameter imageView: 目标 UIImageView（用于适配 Layer 尺寸、位置，保证绘制对齐）
    /// - Returns: 适配 UIImageView 的空白绘制 Layer（可直接用于添加检测框、关键点等绘制内容）
    class func newBoxLineOverlayLayer(imageView: UIImageView) -> CALayer {
        // 移除旧的BoxLineOverlayLayer
        imageView.layer.sublayers?
            .filter { $0.name == boxLineOverlayLayerName }
            .forEach { $0.removeFromSuperlayer() }
        
        let boxLineOverlayLayer: CALayer = CALayer()
        boxLineOverlayLayer.frame = imageView.bounds
        boxLineOverlayLayer.name = boxLineOverlayLayerName
        imageView.layer.addSublayer(boxLineOverlayLayer)
        return boxLineOverlayLayer
    }
    
    /// 检测框+置信度绘制：在指定 UIImageView 的 Layer 上绘制带置信度标注的检测框
    /// 功能说明：根据传入的边界框（boundingBox）和置信度（conf），在指定的 overlayLayer 上绘制可视化检测框，
    ///          自动适配 UIImageView 尺寸/方向，置信度数值会以文本形式标注在框体旁（格式：0.00-1.00），
    ///          框体样式（颜色/线宽/圆角）与置信度文本样式（字体/大小/颜色）内置优化，支持不同置信度等级的样式区分
    /// 设计细节：绘制逻辑与 UIImageView 原有内容解耦，仅操作指定的 overlayLayer，便于后续单独清除/更新该检测框；
    ///          自动校验 boundingBox 有效性（空/越界框体不绘制），避免无效绘制操作
    /// - Parameters:
    ///   - imageView: 目标 UIImageView（用于校准检测框和置信度文本的显示位置，适配 contentMode）
    ///   - boxLineOverlayLayer: 承载检测框/置信度的 CALayer（需已添加到 imageView.layer 上）
    ///   - conf: 检测结果置信度（取值范围 0.0-1.0，会自动格式化显示）
    ///   - boundingBox: 检测框的边界矩形（UI 坐标系，需与 imageView 图片尺寸匹配）
    class func drawBoxAndConfInImageView(imageView: UIImageView, boxLineOverlayLayer: CALayer, conf: CGFloat, boundingBox: CGRect) {
        guard let imageSize: CGSize = imageView.image?.size else {
            return
        }
        let config = MCFastVision.shared.mcVisionDetectConfig.drawConfig
        let viewSize: CGSize = imageView.bounds.size
        
        let faceRectInView: CGRect = MCVisionCoordinateConverter.convertRectToImageViewRectAuto(
            boundingBox: boundingBox,
            imageSize: imageSize,
            imageViewSize: viewSize,
            contentMode: imageView.contentMode
        )
        
        // 绘制检测方框
        let boxLayer: CAShapeLayer = CAShapeLayer()
        boxLayer.path = UIBezierPath(rect: faceRectInView).cgPath
        boxLayer.strokeColor = config.faceBoxStrokeColor.cgColor
        boxLayer.fillColor = UIColor.clear.cgColor
        boxLayer.lineWidth = config.faceBoxLineWidth
        boxLineOverlayLayer.addSublayer(boxLayer)
        
        if config.showConfidence {
            let confStr: String = String(format: "%.2f", conf)
            
            // 先算文字尺寸（简单估算）
            let font: UIFont = UIFont.systemFont(ofSize: config.confidenceFontSize, weight: .medium)
            let textSize = (confStr as NSString).size(withAttributes: [.font: font])

            let w = textSize.width + config.confidencePadding.left + config.confidencePadding.right
            let h = textSize.height + config.confidencePadding.top + config.confidencePadding.bottom

            let bgLayer: CALayer = CALayer()
            bgLayer.backgroundColor = config.confidenceBackgroundColor.cgColor
            bgLayer.cornerRadius = 4
            bgLayer.frame = CGRect(
                x: faceRectInView.maxX - w,
                y: max(0, faceRectInView.minY - h),
                width: w,
                height: h
            )
            boxLineOverlayLayer.addSublayer(bgLayer)

            // 置信度文字（右上角）
            let textLayer: CATextLayer = CATextLayer()
            textLayer.string = String(format: "%.2f", conf)
            textLayer.fontSize = config.confidenceFontSize
            textLayer.alignmentMode = config.alignmentMode
            textLayer.foregroundColor = config.confidenceTextColor.cgColor
            textLayer.contentsScale = UIScreen.main.scale
            
            // 置信度文本视图宽度，最低不低于52，避免显示不全
            let textW: CGFloat = faceRectInView.width < 52 ? 52 : faceRectInView.width
            // 置信度文本视图高度，最高不高于方框高度faceRectInView.height，避免离方框太远
            var textH: CGFloat = config.confidenceFontSize + 8
            // 高于方框高度faceRectInView.height情况下设置为字体高度textLayer.fontSize
            textH = textH > faceRectInView.height ? textLayer.fontSize : textH
            textLayer.frame = CGRect(
                x: faceRectInView.maxX - textW,
                y: max(0, faceRectInView.minY - textH),
                width: textW,
                height: textH
            )

            boxLineOverlayLayer.addSublayer(textLayer)
        }
    }

}

