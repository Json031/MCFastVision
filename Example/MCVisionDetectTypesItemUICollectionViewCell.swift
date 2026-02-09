//
//  MCVisionDetectTypesItemUICollectionViewCell.swift
//  MCFastVision
//
//  Created by MorganChen on 2026/2/6.
//  Copyright © 2026 MorganChen. All rights reserved.
//

import UIKit

class MCVisionDetectTypesItemUICollectionViewCell: UICollectionViewCell {
    public var titleLab: UILabel = UILabel()
    
    var title: String? {
        didSet {
            self.titleLab.text = self.title
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configView() {
        let titleLab: UILabel = UILabel()
        titleLab.textColor = UIColor.black
        titleLab.textAlignment = .center
        titleLab.numberOfLines = 0
        titleLab.font = .systemFont(ofSize: 13, weight: .bold)
        titleLab.layer.borderWidth = 1
        titleLab.layer.borderColor = UIColor.blue.cgColor
        titleLab.layer.cornerRadius = 8
        self.addSubview(titleLab)
        titleLab.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLab.topAnchor.constraint(equalTo: self.topAnchor, constant: 3),
            titleLab.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 3),
            titleLab.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -3),
            titleLab.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -3)
        ])

        self.titleLab = titleLab
    }
}

