//
//  PhotoCollectionViewCell.swift
//  MyPhoto
//
//  Created by 김인환 on 2021/08/15.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    static let identifier: String = "PhotoCell"
    
    let imageView: UIImageView = UIImageView()
    
    func layoutImageView() {
        self.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: self.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        imageView.backgroundColor = .yellow
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutImageView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
