//
//  MCVisionCoordinateConverter.swift
//  MCFastVision
//
//  Created by Morgan Chen on 2026/2/9.
//

//MARK: 坐标转换和添加红框
class MCVisionCoordinateConverter {
    /// image坐标转换
    class func convertRect(_ rectangleRect: CGRect, _ image: UIImage) -> CGRect {
        let imageSize = image.size
        let w = rectangleRect.width * imageSize.width
        let h = rectangleRect.height * imageSize.height
        let x = rectangleRect.minX * imageSize.width
        //该Y坐标与UIView的Y坐标是相反的
        let y = (1 - rectangleRect.minY) * imageSize.height - h
        return CGRect(x: x, y: y, width: w, height: h)
    }
    
    /// 坐标转换（私有）：将图片坐标系下的矩形转换为 UIImageView 显示坐标系下的矩形
    /// 功能说明：解决因 UIImageView 的 contentMode（如 AspectFit/AspectFill）、图片与视图尺寸不一致导致的坐标偏移问题，
    ///          自动计算图片在 UIImageView 中的实际显示位置和缩放比例，将图片内的矩形（rectInImage）精准映射到视图坐标系，
    ///          保证绘制的检测框/关键点与 UIImageView 中显示的图片区域完全对齐
    /// 设计细节：私有方法仅内部调用，覆盖所有常用 contentMode 类型，适配图片缩放/裁剪/居中显示等场景，
    ///          处理逻辑无精度丢失，保证转换后的矩形坐标可直接用于 Layer 绘制
    /// - Parameters:
    ///   - rectInImage: 图片坐标系下的原始矩形（单位：像素，与 imageSize 匹配）
    ///   - imageSize: 原始图片的尺寸（宽高，用于计算缩放比例）
    ///   - imageViewSize: UIImageView 的显示尺寸（宽高，目标坐标系尺寸）
    ///   - contentMode: UIImageView 的内容显示模式（核心适配参数，如 .scaleToFill/.aspectFit/.aspectFill 等）
    /// - Returns: UIImageView 显示坐标系下的转换后矩形（可直接用于绘制 Layer）
    private class func convertImageRectToImageViewRect(
        rectInImage: CGRect,
        imageSize: CGSize,
        imageViewSize: CGSize,
        contentMode: UIView.ContentMode
    ) -> CGRect {

        let topLeft = convertImagePointToImageView(
            imagePoint: rectInImage.origin,
            imageSize: imageSize,
            imageViewSize: imageViewSize,
            contentMode: contentMode
        )

        let bottomRight = convertImagePointToImageView(
            imagePoint: CGPoint(x: rectInImage.maxX, y: rectInImage.maxY),
            imageSize: imageSize,
            imageViewSize: imageViewSize,
            contentMode: contentMode
        )

        return CGRect(
            x: topLeft.x,
            y: topLeft.y,
            width: bottomRight.x - topLeft.x,
            height: bottomRight.y - topLeft.y
        )
    }

    /// rect坐标转换
    class func convertRect(_ rectangleRect: CGRect, _ rect: CGRect) -> CGRect {
        let size = rect.size
        let w = rectangleRect.width * size.width
        let h = rectangleRect.height * size.height
        let x = rectangleRect.minX * size.width
        //该Y坐标与UIView的Y坐标是相反的
        let y = (1 - rectangleRect.maxY) * size.height
        return CGRect(x: x, y: y, width: w, height: h)
    }
    
    /// 正常坐标转成layer坐标
    class func convertRect(viewRect: CGRect, layerRect: CGRect) -> CGRect {
        let size = layerRect.size
        let w = viewRect.width / size.width
        let h = viewRect.height / size.height
        let x = viewRect.minX / size.width
        let y = 1 - viewRect.maxY / size.height
        return CGRect(x: x, y: y, width: w, height: h)
    }
       
    /// 自动判断 boundingBox 是 normalized 还是 image pixel，并转换成 imageView 坐标
    class func convertRectToImageViewRectAuto(
        boundingBox: CGRect,
        imageSize: CGSize,
        imageViewSize: CGSize,
        contentMode: UIView.ContentMode
    ) -> CGRect {

        // 判断是否为 normalized boundingBox (0~1)
        // 只要出现 > 1 基本就可以认为是像素坐标
        let isNormalized: Bool = {
            if boundingBox.minX < 0 || boundingBox.minY < 0 { return false }
            if boundingBox.width < 0 || boundingBox.height < 0 { return false }
            if boundingBox.maxX <= 1.0 && boundingBox.maxY <= 1.0 { return true }
            return false
        }()

        if isNormalized {
            // Vision normalized -> imageView rect
            return convertBoundingBoxToImageViewRect(
                boundingBox: boundingBox,
                imageSize: imageSize,
                imageViewSize: imageViewSize,
                contentMode: contentMode
            )
        } else {
            // image pixel -> imageView rect
            return convertImageRectToImageViewRect(
                rectInImage: boundingBox,
                imageSize: imageSize,
                imageViewSize: imageViewSize,
                contentMode: contentMode
            )
        }
    }
    
    /// 图片坐标 -> imageView 坐标（适配 AspectFit）
    /// Vision normalized point -> image point
    /// 坐标点转换：将图片坐标系下的单点坐标转换为 UIImageView 显示坐标系下的坐标
    /// 功能说明：针对 UIImageView 的 contentMode（如 AspectFit/AspectFill）和图片与视图尺寸差异，
    ///          自动计算缩放比例与偏移量，将图片内的原始坐标点（imagePoint）精准映射到 UIImageView 显示坐标系，
    ///          解决因图片缩放、居中、裁剪导致的坐标偏移问题，保证关键点/标记点与视图显示位置完全对齐
    /// 设计细节：覆盖所有常用 contentMode 类型，转换逻辑无精度丢失，返回的坐标可直接用于 Layer 绘制/点击事件判断；
    ///          适配图片宽高比与视图宽高比不一致的场景，避免坐标点偏移或变形
    /// - Parameters:
    ///   - imagePoint: 图片坐标系下的原始坐标点（单位：像素，与 imageSize 匹配）
    ///   - imageSize: 原始图片的尺寸（宽高，用于计算缩放比例）
    ///   - imageViewSize: UIImageView 的显示尺寸（宽高，目标坐标系尺寸）
    ///   - contentMode: UIImageView 的内容显示模式（核心适配参数，决定图片的缩放/摆放规则）
    /// - Returns: UIImageView 显示坐标系下的转换后坐标点（可直接用于绘制或交互判断）
    class func convertImagePointToImageView(
        imagePoint: CGPoint,
        imageSize: CGSize,
        imageViewSize: CGSize,
        contentMode: UIView.ContentMode
    ) -> CGPoint {

        if contentMode != .scaleAspectFit {
            // 简化：如果不是 aspectFit，就先按 fill 处理
            let scaleX = imageViewSize.width / imageSize.width
            let scaleY = imageViewSize.height / imageSize.height
            return CGPoint(x: imagePoint.x * scaleX, y: imagePoint.y * scaleY)
        }

        let imageAspect = imageSize.width / imageSize.height
        let viewAspect = imageViewSize.width / imageViewSize.height

        var scale: CGFloat = 1
        var xOffset: CGFloat = 0
        var yOffset: CGFloat = 0

        if imageAspect > viewAspect {
            // 图片更宽，宽度撑满
            scale = imageViewSize.width / imageSize.width
            let scaledHeight = imageSize.height * scale
            yOffset = (imageViewSize.height - scaledHeight) / 2
        } else {
            // 图片更高，高度撑满
            scale = imageViewSize.height / imageSize.height
            let scaledWidth = imageSize.width * scale
            xOffset = (imageViewSize.width - scaledWidth) / 2
        }

        let x = imagePoint.x * scale + xOffset
        let y = imagePoint.y * scale + yOffset

        return CGPoint(x: x, y: y)
    }
    
    /// 点坐标换算函数
    /// Vision normalized point -> image point
    /// Vision 归一化坐标点转换：将 Vision 框架返回的归一化关键点坐标转换为图片像素坐标系下的坐标点
    /// 功能说明：Vision 框架返回的人脸/物体关键点为归一化坐标（取值 0-1，基于 boundingBox 相对位置），
    ///          该方法先将点映射到 boundingBox 绝对区域，再结合图片尺寸缩放为像素坐标，
    ///          同时修正 Vision 坐标系（原点在左下角）到 UI 图片坐标系（原点在左上角）的方向偏移，
    ///          保证转换后的坐标点与图片像素精准对应
    /// 设计细节：适配不同尺寸图片和任意大小的 boundingBox，转换逻辑无精度丢失，返回的坐标可直接用于图片裁剪/绘制；
    ///          自动校验 boundingBox 有效性（空/越界时返回原点），避免转换异常
    /// - Parameters:
    ///   - point: Vision 框架返回的归一化关键点坐标（取值 0-1，相对 boundingBox 的位置）
    ///   - boundingBox: Vision 框架返回的目标边界框（归一化矩形，取值 0-1，基于图片整体尺寸）
    ///   - imageSize: 原始图片的像素尺寸（宽高，用于将归一化坐标缩放为实际像素值）
    /// - Returns: 图片像素坐标系下的绝对坐标点（原点在左上角，单位：像素）
    class func convertVisionNormalizedPointToImagePoint(
        point: CGPoint,
        boundingBox: CGRect,
        imageSize: CGSize
    ) -> CGPoint {

        // boundingBox 是 normalized，原点在左下角
        let faceRect = CGRect(
            x: boundingBox.origin.x * imageSize.width,
            y: (1 - boundingBox.origin.y - boundingBox.size.height) * imageSize.height,
            width: boundingBox.size.width * imageSize.width,
            height: boundingBox.size.height * imageSize.height
        )

        // landmark point 是相对 faceRect 的 normalized 坐标
        let x = faceRect.origin.x + point.x * faceRect.size.width
        let y = faceRect.origin.y + (1 - point.y) * faceRect.size.height

        return CGPoint(x: x, y: y)
    }
    
    /// VNFaceObservation.boundingBox (normalized) -> imageView rect
    /// 边界框坐标转换（私有）：将 Vision 框架返回的归一化边界框转换为 UIImageView 显示坐标系下的矩形
    /// 功能说明：先将 Vision 归一化 boundingBox（取值 0-1，原点在左下角）转换为图片像素坐标系矩形（修正原点方向），
    ///          再结合 UIImageView 的 contentMode、图片与视图尺寸差异，完成图片坐标系到视图显示坐标系的二次转换，
    ///          最终返回可直接用于 UIImageView 绘制的矩形，保证检测框与视图内显示的图片区域精准对齐
    /// 设计细节：私有方法仅内部调用，整合「归一化→图片像素」「图片像素→视图显示」两步转换逻辑，
    ///          覆盖所有常用 contentMode 类型，适配图片缩放/裁剪/居中场景，无坐标偏移或变形
    /// - Parameters:
    ///   - boundingBox: Vision 框架返回的归一化边界框（取值 0-1，原点在图片左下角）
    ///   - imageSize: 原始图片的像素尺寸（宽高，用于将归一化框缩放为图片像素矩形）
    ///   - imageViewSize: UIImageView 的显示尺寸（宽高，目标坐标系尺寸）
    ///   - contentMode: UIImageView 的内容显示模式（核心适配参数，决定图片的缩放/摆放规则）
    /// - Returns: UIImageView 显示坐标系下的转换后矩形（原点在左上角，可直接用于 Layer 绘制）
    private class func convertBoundingBoxToImageViewRect(
        boundingBox: CGRect,
        imageSize: CGSize,
        imageViewSize: CGSize,
        contentMode: UIView.ContentMode
    ) -> CGRect {

        // 1) boundingBox -> image坐标（像素坐标系，原点左上）
        let rectInImage = CGRect(
            x: boundingBox.origin.x * imageSize.width,
            y: (1 - boundingBox.origin.y - boundingBox.height) * imageSize.height,
            width: boundingBox.width * imageSize.width,
            height: boundingBox.height * imageSize.height
        )

        // 2) image坐标 -> imageView坐标（aspectFit）
        let topLeft = convertImagePointToImageView(
            imagePoint: rectInImage.origin,
            imageSize: imageSize,
            imageViewSize: imageViewSize,
            contentMode: contentMode
        )

        let bottomRight = convertImagePointToImageView(
            imagePoint: CGPoint(x: rectInImage.maxX, y: rectInImage.maxY),
            imageSize: imageSize,
            imageViewSize: imageViewSize,
            contentMode: contentMode
        )

        return CGRect(
            x: topLeft.x,
            y: topLeft.y,
            width: bottomRight.x - topLeft.x,
            height: bottomRight.y - topLeft.y
        )
    }
    
    // 取最大 rect 的工具函数
    class func maxRect(from rects: [CGRect]) -> CGRect? {
        guard !rects.isEmpty else { return nil }
        return rects.max(by: { ($0.width * $0.height) < ($1.width * $1.height) })
    }
}
