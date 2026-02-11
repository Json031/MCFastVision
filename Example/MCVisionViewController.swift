//
//  MCVisionViewController.swift
//  MCFastVision
//

import UIKit
import PhotosUI
import MCFastVision

class VisionViewController: UIViewController {
    private var imageView: UIImageView = UIImageView()
    private var tipTextView: UITextView = UITextView()
    private var activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView(style: .large)
    private var visionDetectType: MCFastVisionDetectType = .faceLandmarks// 视觉检测识别类型默认人脸识别
    
    private let types: [MCVisionDetectTypesItem] = [MCVisionDetectTypesItem(type: .text, typeName: "Text detect"), MCVisionDetectTypesItem(type: .code, typeName: "Code detect"), MCVisionDetectTypesItem(type: .rectangle, typeName: "Rectangle detect"), MCVisionDetectTypesItem(type: .faceRectangles, typeName: "Face rectangles detect"), MCVisionDetectTypesItem(type: .faceLandmarks, typeName: "Face landmarks detect"), MCVisionDetectTypesItem(type: .animals, typeName: "Animals detect")]
    private let typesItemCellID: String = "typesItemCellID"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        configSubView()
    }

    // MARK: - private method
    private func configSubView() {
        let screen_w: CGFloat = self.view.frame.size.width
        let screen_h: CGFloat = self.view.frame.size.height
        let bar_h: CGFloat = (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0) + 44.0
        let imageView_h: CGFloat = self.view.frame.size.width
        let imageView: UIImageView = UIImageView(frame: CGRect(x: 0, y: bar_h, width: imageView_h, height: imageView_h))
        imageView.contentMode = .scaleAspectFit
        self.view.addSubview(imageView)
        self.imageView = imageView
        
        let tipView_x: CGFloat = 16
        let tipView_h: CGFloat = 100
        let tipView_w: CGFloat = self.view.frame.size.width - tipView_x * 2

        let tipView: UIView = UIView(frame: CGRect(x: tipView_x, y: bar_h + imageView_h + tipView_x, width: tipView_w, height: tipView_h))
        tipView.layer.borderColor = UIColor.black.cgColor
        tipView.layer.cornerRadius = 8
        tipView.layer.borderWidth = 1
        self.view.addSubview(tipView)

        let tipLabel_x: CGFloat = 8
        let tipTextView: UITextView = UITextView(frame: CGRect(x: tipLabel_x, y: tipLabel_x, width: tipView_w - tipLabel_x * 2, height: tipView_h - tipLabel_x * 2))

        tipTextView.font = .systemFont(ofSize: 16, weight: .bold)
        tipTextView.textColor = .black
        tipTextView.backgroundColor = .clear          // 透明背景，与原 UILabel 一致
        tipTextView.isEditable = false                // 不可编辑
        tipTextView.isScrollEnabled = true            // 允许滚动（默认就是 true，但显式写出更清晰）
        tipTextView.textAlignment = .left             // 可选：根据需求调整对齐（原 UILabel 默认 left）
        tipTextView.textContainerInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)  // 可选：轻微内边距，更美观
        tipTextView.showsVerticalScrollIndicator = true  // 显示滚动条（可选，false 则隐藏）

        // 初始文本
        tipTextView.text = "请从下方菜单栏选择功能开始识别..."

        tipView.addSubview(tipTextView)
        self.tipTextView = tipTextView
        
        let itemWidth: CGFloat = (screen_w - 32) / 3
        let itemHeight: CGFloat = 80
        let layout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        let typesCollectionView_y: CGFloat = bar_h + imageView_h + tipView_x + tipView_h + tipView_x
        let typesCollectionView: UICollectionView = UICollectionView.init(frame: CGRect(x: 0, y: typesCollectionView_y, width: screen_w, height: screen_h - typesCollectionView_y), collectionViewLayout: layout)
        typesCollectionView.backgroundColor = .white
        typesCollectionView.showsVerticalScrollIndicator = false
        typesCollectionView.showsHorizontalScrollIndicator = false
        typesCollectionView.delegate = self
        typesCollectionView.dataSource = self
        typesCollectionView.backgroundColor = .clear
        typesCollectionView.register(MCVisionDetectTypesItemUICollectionViewCell.self, forCellWithReuseIdentifier: self.typesItemCellID)
        self.view.addSubview(typesCollectionView)
        
        //菊花加载指示器
        self.view.addSubview(self.activityIndicatorView)
        self.activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.activityIndicatorView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.activityIndicatorView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])

    }
    
    private func selectFromPhotoLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let photoPicker = UIImagePickerController()
            photoPicker.delegate = self
            photoPicker.sourceType = .photoLibrary
            photoPicker.modalPresentationStyle = .fullScreen
            self.present(photoPicker, animated: true, completion: nil)
        } else {
            self.tipTextView.text = "相册不可用"
        }
    }
    
    private func detectImage(image: UIImage) {
        DispatchQueue.main.async(execute: {
            self.imageView.image = image
            switch self.visionDetectType {
            case .text:
                self.detectText()
            case .code:
                self.detectBarcode()
            case .rectangle:
                self.detectRectangles()
            case .faceRectangles:
                self.detectFaceRectangles()
            case .faceLandmarks:
                self.detectFaceLandmarks()
            case .animals:
                self.detectAnimals()
            }
        })
    }
    
    private func detectFaceLandmarks() {
        DispatchQueue.main.async(execute: {
            self.activityIndicatorView.startAnimating()
            MCFastVision.visionDetectFaceLandmarks(imageView: self.imageView, successBlock: { results in
                DispatchQueue.main.async(execute: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        self.activityIndicatorView.stopAnimating()
                        if results.count <= 0 {
                            self.tipTextView.text = "无人脸检测结果"
                            return
                        }
                        self.tipTextView.text = "人脸识别成功，共\(results.count)个人脸"
                    })
                })
            }, failedBlock: { err in
                DispatchQueue.main.async(execute: {
                    self.activityIndicatorView.stopAnimating()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        self.tipTextView.text = err
                    })
                })
            })
        })
    }
    
    private func detectText() {
        DispatchQueue.main.async(execute: {
            self.activityIndicatorView.startAnimating()
            MCFastVision.visionRecognizeText(
                imageView: self.imageView,
                successBlock: { results in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        self.activityIndicatorView.stopAnimating()
                        if results.count <= 0 {
                            self.tipTextView.text = "无文本检测结果"
                            return
                        }
                        self.tipTextView.text = "文本识别成功，共\(results.count)处文本"
                    })
                },
                failedBlock: {err in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        self.activityIndicatorView.stopAnimating()
                        self.tipTextView.text = err
                    })
                }
            )
        })
    }
    
    private func detectBarcode() {
        DispatchQueue.main.async(execute: {
            self.activityIndicatorView.startAnimating()
            MCFastVision.visionRecognizeBarcode(
                imageView: self.imageView,
                successBlock: { results in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        self.activityIndicatorView.stopAnimating()
                        if results.count <= 0 {
                            self.tipTextView.text = "无条码检测结果"
                            return
                        }
                        self.tipTextView.text = "条码识别成功"
                        for result: MCVisionBarcodeResult in results {
                            PLog("\(result.type == .barcode1D ? "条形码" : "二维码")内容: \(result.payload)")
                        }
                    })
                },
                failedBlock: {err in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        self.activityIndicatorView.stopAnimating()
                        self.tipTextView.text = err
                    })
                }
            )
        })
    }

    private func detectFaceRectangles() {
        DispatchQueue.main.async(execute: {
            self.activityIndicatorView.startAnimating()
            MCFastVision.visionDetectFaceRectangles(imageView: self.imageView, successBlock: { results in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        
                            self.activityIndicatorView.stopAnimating()
                        if results.count <= 0 {
                            self.tipTextView.text = "无人脸检测结果"
                            return
                        }
                        self.tipTextView.text = "人脸识别成功，共\(results.count)个人脸"
                    })
                },
                failedBlock: {err in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        self.activityIndicatorView.stopAnimating()
                        self.tipTextView.text = err
                    })
                }
            )
        })
    }
    private func detectAnimals() {
        DispatchQueue.main.async(execute: {
            self.activityIndicatorView.startAnimating()
            MCFastVision.detectAnimals(
                imageView: self.imageView,
                successBlock: { results in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        self.activityIndicatorView.stopAnimating()
                        
                        if results.count <= 0 {
                            self.tipTextView.text = "无动物检测结果"
                            return
                        }
                        
                        // 统计猫和狗数量
                        let catCount = results.filter { $0.animalType == .cat }.count
                        let dogCount = results.filter { $0.animalType == .dog }.count
                        
                        var tipText = "动物检测成功，"
                        
                        if catCount > 0 && dogCount > 0 {
                            tipText += "共 \(catCount) 只猫，\(dogCount) 只狗"
                        } else if catCount > 0 {
                            tipText += "共 \(catCount) 只猫"
                        } else if dogCount > 0 {
                            tipText += "共 \(dogCount) 只狗"
                        } else {
                            tipText += "共 \(results.count) 只动物（未知类型）"
                        }
                        
                        tipText += "（总计 \(results.count) 只动物）"
                        
                        self.tipTextView.text = tipText
                    })
                },
                failedBlock: {err in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        self.activityIndicatorView.stopAnimating()
                        self.tipTextView.text = err
                    })
                }
            )
        })
    }
    private func detectRectangles() {
        DispatchQueue.main.async(execute: {
            self.activityIndicatorView.startAnimating()
            MCFastVision.visionDetectRectangles(
                imageView: self.imageView,
                successBlock: { results in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        
                        self.activityIndicatorView.stopAnimating()
                        if results.count <= 0 {
                            self.tipTextView.text = "无矩形检测结果"
                            return
                        }
                        self.tipTextView.text = "矩形识别成功，共检测到\(results.count)个矩形"
                    })
                },
                failedBlock: {err in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        self.activityIndicatorView.stopAnimating()
                        self.tipTextView.text = err
                    })
                }
            )
        })
    }
    
    // MARK: - button action
    @objc private func albumBtnAction() {
        if #available(iOS 14, *) {
            let phPickerVC: PHPickerViewController = PhotosUI.PHPickerViewController(configuration: PHPickerConfiguration())
            phPickerVC.delegate = self
            let nav: UINavigationController = UINavigationController(rootViewController: phPickerVC)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        }
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate
extension VisionViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate, PHPickerViewControllerDelegate {
    @available(iOS 14, *)
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.navigationController?.dismiss(animated: true, completion: nil)
        if results.count != 0 {
            let imageResult: PHPickerResult? = results.first
            let itemProvider: NSItemProvider? = imageResult?.itemProvider
            if itemProvider?.canLoadObject(ofClass: UIImage.self) ?? false {
                itemProvider?.loadObject(ofClass: UIImage.self, completionHandler: { (object, error) in
                    if object?.isKind(of: UIImage.self) ?? false {
                        self.detectImage(image: object as! UIImage)
                    } else {
                        self.tipTextView.text = "图片异常"
                    }
                })
            } else {
                picker.navigationController?.dismiss(animated: true, completion: nil)
                self.tipTextView.text = "未获取到图片"
            }
        }
    }
    
    //选择图片完成
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)
        //选择的类型是照片
        let type = info[UIImagePickerController.InfoKey.mediaType] as! String
        if type == "public.image" {
            //获取照片
            guard let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
                self.tipTextView.text = "未获取到图片"
                return
            }
            self.detectImage(image: pickedImage)
        }
    }
    
    //取消图片选择
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}

extension VisionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.types.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MCVisionDetectTypesItemUICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: self.typesItemCellID, for: indexPath) as! MCVisionDetectTypesItemUICollectionViewCell
        cell.title = self.types[indexPath.item].typeName
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let visionDetectTypesItem: MCVisionDetectTypesItem = self.types[indexPath.item]
        self.visionDetectType = visionDetectTypesItem.type
        albumBtnAction()
    }
}
