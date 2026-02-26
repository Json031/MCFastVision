# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.1] - 2026-02-26
### Changed
- Update README.md (minor refinements, possibly performance or summary tweaks)

## [1.2.0] - 2026-02-26
### Added
- 人像分割（Portrait Segmentation / Person Mask Generation）功能支持，使用 `VNGeneratePersonSegmentationRequest`
- 相应结果结构体 `MCVisionPersonSegmentationResult`
- 绘制方法 `drawPersonSegmentationMask`（支持蒙版叠加、颜色配置、padding 偏移等）
- 更新 README 简介，新增人像分割能力描述

### Changed
- README.md 大幅更新：优化项目描述、英文版简介、功能列表、示例截图等
- 完善文档结构，添加更多使用说明和视觉示例

## [1.0.3] - 2026-02-10
### Fixed
- CocoaPods subspec source file patterns and dependency issues

### Added
- README 中添加 MCFastVision 项目链接

## [1.0.2] - 2026-02-10 (或更早)
### Added
- 完整 Example 项目，用于演示如何集成和使用 MCFastVision
- 动物识别（猫与狗）功能及 README 相关章节
- README 增强：添加徽章、语言切换、返回顶部链接、安装指南、项目详情

### Changed
- 更新 README.md（多次迭代，包括示例图片、功能描述优化）
- 初始功能完善：OCR、条码/二维码、人脸检测 & 关键点、矩形检测等核心能力

## [1.0.0] / Initial Release - 2026-02-09 (approx.)
### Added
- 项目初始化
- 核心能力封装：文字识别（OCR）、条形码/二维码识别、人脸检测、人脸关键点检测、矩形检测
- 统一配置入口 `MCVisionDetectConfig` 和绘制能力
- 基础 Result 结构体（如 `MCVisionTextResult`、`MCVisionBarcodeResult` 等）
