//
//  PhotoCollectionViewCell.swift
//  MyPhoto
//
//  Created by 김인환 on 2021/08/17.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    static let identifier: String = "PhotoCollectionViewCell"
    
    let imageView: UIImageView = UIImageView()
    let opacity: UIView = UIView()
    
    func layoutImageView() {
        self.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: self.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.imageView.layer.borderWidth = 4.0
                self.imageView.alpha = 0.75
            } else {
                self.imageView.layer.borderWidth = 0.0
                self.imageView.alpha = 1.0
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutImageView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
