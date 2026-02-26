<div align="center">
  <a href="https://github.com/Json031/MCFastVision" target="_blank">
  <img width="660" height="255" alt="screenshot-1"
       src="https://github.com/user-attachments/assets/c25bd23a-d4a0-433d-978a-08232d5ea7f2"
       style="border: 2px solid blue;" />
    </a>
</div>

# MCFastVision
<a name="top"></a>

[![CocoaPods](https://img.shields.io/cocoapods/v/MCFastVision.svg)](https://cocoapods.org/pods/MCFastVision)
![Swift 5](https://img.shields.io/badge/Swift-5.0-orange.svg)
[![License](https://img.shields.io/badge/license-MIT-brightgreen.svg)](https://github.com/Json031/MCFastVision/blob/main/LICENSE)

---

# 🌍 Language / 语言选择
<!-- 语言切换（点击会滚动到对应语言区） -->
[中文](#chinese) | [English](#english)

# 中文
<a name="chinese"></a>

[MCFastVision](https://github.com/Json031/MCFastVision) 是一个基于 iOS Vision 框架的轻量级通用视觉识别工具库，封装了文字识别（OCR）、条形码/二维码识别、人脸检测、人脸关键点检测、矩形检测、动物识别（猫与狗）、人像分割（人物蒙版生成）等能力，并提供统一的配置入口与识别结果绘制能力（支持框选、关键点、蒙版叠加等可视化），支持快速集成到业务项目中，用于扫描、识别、检测、背景虚化、抠图与可视化标注等场景。

## 项目Example示例
### 人脸及关键点识别
<img width="220" height="440" alt="screenshot-1" src="https://github.com/user-attachments/assets/03a06605-5da4-4d10-8156-283110a4f821" style="border: 2px solid blue;" />

### 动物检测
<img width="220" height="440" alt="screenshot-1" src="https://github.com/user-attachments/assets/f1035020-62d6-43d4-b209-c417c9a0b00d" style="border: 2px solid blue;" />
<img width="220" height="440" alt="screenshot-1" src="https://github.com/user-attachments/assets/8628bf59-cd4d-4961-aa0c-a7c3b6dec8ea" style="border: 2px solid blue;" />
<img width="220" height="440" alt="screenshot-1" src="https://github.com/user-attachments/assets/2844abae-3bce-49bc-83b8-28ecd0bd6a8a" style="border: 2px solid blue;" />

### 二维码识别 / 条形码识别
<img width="220" height="440" alt="screenshot-1" src="https://github.com/user-attachments/assets/3ccf13ba-e638-4cd2-93a8-556472c58eba" style="border: 2px solid blue;" />
<img width="220" height="440" alt="screenshot-1" src="https://github.com/user-attachments/assets/765722f4-9624-46a9-a593-404b01bf3e95" style="border: 2px solid blue;" />

### 矩形检测
<img width="220" height="440" alt="screenshot-1" src="https://github.com/user-attachments/assets/47d850fe-8260-4ca6-8f30-719d29356351" style="border: 2px solid blue;" />
<img width="220" height="440" alt="screenshot-1" src="https://github.com/user-attachments/assets/bb11264c-7179-4360-9d3b-10a12e5f4249" style="border: 2px solid blue;" />

### 文本识别
<img width="220" height="440" alt="screenshot-1" src="https://github.com/user-attachments/assets/58fa173e-dd94-4db1-a41e-4daefa61a61a" style="border: 2px solid blue;" />

### 人脸框快速检测
<img width="220" height="440" alt="screenshot-1" src="https://github.com/user-attachments/assets/81579d8f-d6c9-4696-9628-2a1dc9fc8202" style="border: 2px solid blue;" />

### 人像分割
<img width="220" height="440" alt="screenshot-1" src="https://github.com/user-attachments/assets/a661ef35-b92b-48bb-b800-f92c1f609314" style="border: 2px solid blue;" />

## 环境要求

- **iOS Version**:
  - iOS 15.0+（完整支持所有功能，包括人像分割）
  - iOS 13.0+（支持 OCR、条码、人脸、矩形、动物识别等核心功能）

- **Device Compatibility**:
  - 支持所有 iPhone/iPad（A12 Bionic 及以上芯片性能最佳，尤其是实时视频流 + 人像分割）

- **Dependencies**: 无任何第三方库依赖  
  纯 Apple 原生框架，无需额外安装包。
  
## 安装（CocoaPods）

通过 CocoaPods 安装该库：

```ruby
# 在 Podfile 中添加
pod 'MCFastVision'
```

然后在项目目录运行：

```bash
pod install
```


---

# English
<a name="english"></a>

MCFastVision is a lightweight, general-purpose visual recognition toolkit built on the iOS Vision framework. It encapsulates capabilities such as text recognition (OCR), barcode/QR code recognition, face detection, facial keypoint detection, rectangle detection, animal recognition (cats and dogs), and portrait segmentation (person mask generation). It provides a unified configuration interface and the ability to visualize recognition results (supporting visualizations like box selection, keypoint overlay, and mask overlay). It supports rapid integration into business projects for scenarios such as scanning, recognition, detection, background blurring, image clipping, and visual annotation.

## Project Example
### Face landmarks recognition
<img width="220" height="440" alt="screenshot-1" src="https://github.com/user-attachments/assets/03a06605-5da4-4d10-8156-283110a4f821" style="border: 2px solid blue;" />

### Animal recognition
<img width="220" height="440" alt="screenshot-1" src="https://github.com/user-attachments/assets/f1035020-62d6-43d4-b209-c417c9a0b00d" style="border: 2px solid blue;" />
<img width="220" height="440" alt="screenshot-1" src="https://github.com/user-attachments/assets/8628bf59-cd4d-4961-aa0c-a7c3b6dec8ea" style="border: 2px solid blue;" />
<img width="220" height="440" alt="screenshot-1" src="https://github.com/user-attachments/assets/2844abae-3bce-49bc-83b8-28ecd0bd6a8a" style="border: 2px solid blue;" />

### QR code recognition / Barcode recognition
<img width="220" height="440" alt="screenshot-1" src="https://github.com/user-attachments/assets/3ccf13ba-e638-4cd2-93a8-556472c58eba" style="border: 2px solid blue;" />
<img width="220" height="440" alt="screenshot-1" src="https://github.com/user-attachments/assets/765722f4-9624-46a9-a593-404b01bf3e95" style="border: 2px solid blue;" />

### Rectangle detection
<img width="220" height="440" alt="screenshot-1" src="https://github.com/user-attachments/assets/47d850fe-8260-4ca6-8f30-719d29356351" style="border: 2px solid blue;" />
<img width="220" height="440" alt="screenshot-1" src="https://github.com/user-attachments/assets/bb11264c-7179-4360-9d3b-10a12e5f4249" style="border: 2px solid blue;" />

### Text recognition
<img width="220" height="440" alt="screenshot-1" src="https://github.com/user-attachments/assets/58fa173e-dd94-4db1-a41e-4daefa61a61a" style="border: 2px solid blue;" />

### Fast detection of face rectangles
<img width="220" height="440" alt="screenshot-1" src="https://github.com/user-attachments/assets/81579d8f-d6c9-4696-9628-2a1dc9fc8202" style="border: 2px solid blue;" />

### Portrait Segmentation
<img width="220" height="440" alt="screenshot-1" src="https://github.com/user-attachments/assets/a661ef35-b92b-48bb-b800-f92c1f609314" style="border: 2px solid blue;" />

## Environmental requirements
- **iOS Version**: 
    - iOS 15.0+ (full support for all features, including portrait segmentation) 
    - iOS 13.0+ (support for core features such as OCR, barcode, face, rectangle, animal recognition, etc.)
- **Device Compatibility**: Supports all iPhone/iPad devices (A12 Bionic and above perform best, especially for real-time video streaming + portrait segmentation)
- **Dependencies**: No third-party library dependencies. Pure Apple native framework, no additional installation packages required.

## Installation (CocoaPods)

Add to your `Podfile`:

```ruby
pod 'MCFastVision'
```

Then run:

```bash
pod install
```

---

# TODO / Future Plans

以下是项目未来的优化方向（欢迎 PR 或 Issue 讨论）：

- **实时视频流支持**  
  添加针对 CVPixelBuffer 的检测变体（如 `detect(in pixelBuffer: CVPixelBuffer, completion: ...)`），结合 `VNSequenceRequestHandler` 实现相机预览或视频流的连续识别。目标：支持实时人脸/动物/分割等功能，适用于 AR、直播滤镜、监控等场景。

- **自定义 Core ML 支持**  
  引入 `VNCoreMLRequest` 入口，允许用户传入自定义 .mlmodel 文件（e.g. YOLO、MobileNet、自定义物体检测模型）。这将大幅提升扩展性，支持更多类别（如汽车、水杯、食物、植物等）的物体识别。

其他潜在方向：
- 支持人体姿态 / 手势检测（VNDetectHumanBodyPoseRequest / VNDetectHumanHandPoseRequest）
- 视频处理支持（批量帧处理或导出带标注的视频）
- Swift Package Manager (SPM) 集成

欢迎贡献代码、测试用例或想法！

# 许可证

本项目基于 [MIT License](https://github.com/Json031/MCFastVision/blob/main/LICENSE) 开源协议。

---

**[⬆ Back to Top / 返回顶部](#top)**
