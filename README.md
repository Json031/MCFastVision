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

## 🌍 Language / 语言选择
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

### Installation (CocoaPods)

Add to your `Podfile`:

```ruby
pod 'MCFastVision'
```

Then run:

```bash
pod install
```

---

### 许可证

本项目基于 [MIT License](https://github.com/Json031/MCFastVision/blob/main/LICENSE) 开源协议。

---

**[⬆ Back to Top / 返回顶部](#top)**
