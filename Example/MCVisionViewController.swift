//
//  MCVisionViewController.swift
//  MCFastVision
//

import UIKit
import PhotosUI
import MCFastVision

class VisionViewController: UIViewController {
    private var imageView: UIImageView = UIImageView()
    private var tipLabel: UILabel = UILabel()
    private var activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView(style: .large)
    private var visionDetectType: MCFastVisionDetectType = .faceLandmarks// 视觉检测识别类型默认人脸识别
    
    private let types: [MCVisionDetectTypesItem] = [MCVisionDetectTypesItem(type: .text, typeName: "Text detect"), MCVisionDetectTypesItem(type: .code, typeName: "Code detect"), MCVisionDetectTypesItem(type: .rectangle, typeName: "Rectangle detect"), MCVisionDetectTypesItem(type: .faceRectangles, typeName: "Face rectangles detect"), MCVisionDetectTypesItem(type: .faceLandmarks, typeName: "Face landmarks detect")]
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
        
        let tipLabel_x: CGFloat = 16
        let tipLabel_h: CGFloat = 88
        let tipLabel: UILabel = UILabel(frame: CGRect(x: tipLabel_x, y: bar_h + imageView_h + tipLabel_x, width: self.view.frame.size.width - tipLabel_x * 2, height: tipLabel_h))
        tipLabel.font = .systemFont(ofSize: 24, weight: .bold)
        tipLabel.textColor = .black
        tipLabel.numberOfLines = 2
        self.view.addSubview(tipLabel)
        self.tipLabel = tipLabel
        
        let itemWidth: CGFloat = (screen_w - 32) / 3
        let itemHeight: CGFloat = 80
        let layout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        let typesCollectionView_y: CGFloat = bar_h + imageView_h + tipLabel_x + tipLabel_h + tipLabel_x
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
            self.tipLabel.text = "相册不可用"
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
                            self.tipLabel.text = "无人脸检测结果"
                            return
                        }
                        self.tipLabel.text = "人脸识别成功，共\(results.count)个人脸"
                    })
                })
            }, failedBlock: { err in
                DispatchQueue.main.async(execute: {
                    self.activityIndicatorView.stopAnimating()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        self.tipLabel.text = err
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
                            self.tipLabel.text = "无文本检测结果"
                            return
                        }
                        self.tipLabel.text = "文本识别成功，共\(results.count)处文本"
                    })
                },
                failedBlock: {err in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        self.activityIndicatorView.stopAnimating()
                        self.tipLabel.text = err
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
                            self.tipLabel.text = "无条码检测结果"
                            return
                        }
                        self.tipLabel.text = "条码识别成功"
                        for result: MCVisionBarcodeResult in results {
                            PLog("\(result.type == .barcode1D ? "条形码" : "二维码")内容: \(result.payload)")
                        }
                    })
                },
                failedBlock: {err in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        self.activityIndicatorView.stopAnimating()
                        self.tipLabel.text = err
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
                            self.tipLabel.text = "无人脸检测结果"
                            return
                        }
                        self.tipLabel.text = "人脸识别成功，共\(results.count)个人脸"
                    })
                },
                failedBlock: {err in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        self.activityIndicatorView.stopAnimating()
                        self.tipLabel.text = err
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
                            self.tipLabel.text = "无矩形检测结果"
                            return
                        }
                        self.tipLabel.text = "矩形识别成功，共检测到\(results.count)个矩形"
                    })
                },
                failedBlock: {err in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        self.activityIndicatorView.stopAnimating()
                        self.tipLabel.text = err
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
                        self.tipLabel.text = "图片异常"
                    }
                })
            } else {
                picker.navigationController?.dismiss(animated: true, completion: nil)
                self.tipLabel.text = "未获取到图片"
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
                self.tipLabel.text = "未获取到图片"
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
