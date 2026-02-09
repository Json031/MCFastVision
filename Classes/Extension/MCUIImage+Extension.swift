//
//  UIImage+Extension.swift
//  Pods
//
//  Created by Rate Rebriduo on 2026/2/9.
//

/// UIImage 扩展：新增图片裁剪能力，支持基于指定矩形区域精准裁剪图片
/// 核心用途：视觉检测场景下，可快速裁剪检测到的目标区域（如人脸框、条码框、文字框），
///          便于后续对目标区域做二次检测/识别，提升处理效率
extension UIImage {
    /// 图片裁剪方法：根据传入的矩形区域裁剪出子图片
    /// 功能说明：自动适配图片的 orientation（方向）和 scale（缩放因子），
    ///          保证裁剪区域与视觉检测的矩形框精准对应，返回的裁剪图保留原图的 scale 和方向属性
    /// 异常处理：裁剪区域超出图片范围时，自动调整为图片有效区域；无效裁剪区域（宽/高≤0）返回 nil
    /// - Parameter cropRect: 裁剪矩形区域（UI 坐标系，需与图片尺寸匹配，单位：像素）
    /// - Returns: 裁剪后的子图片（裁剪失败返回 nil）
    func cropWithRect(cropRect: CGRect) -> UIImage? {
        guard let sourceImageRef: CGImage = self.cgImage else {
            return nil
        }
        guard let newCGImage = sourceImageRef.cropping(to: cropRect) else {
            return nil
        }
        return UIImage(cgImage: newCGImage)
    }
}
