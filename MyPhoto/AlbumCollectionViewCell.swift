//
//  PhotoCollectionViewCell.swift
//  MyPhoto
//
//  Created by 김인환 on 2021/08/15.
//

import UIKit
import Photos

class AlbumCollectionViewCell: UICollectionViewCell {
    
    static let identifier: String = "PhotoCell"
    
    let imageView: UIImageView = UIImageView()
    let albumTitle: UILabel = {
        let label: UILabel = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        return label
    }()
    let photoCount: UILabel = {
        let label: UILabel = UILabel()
        label.font = UIFont.monospacedSystemFont(ofSize: 13, weight: .thin)
        return label
    }()
    
    func layoutImageView() {
        self.imageView.layer.cornerRadius = 15.0
        self.imageView.layer.masksToBounds = true
        
        self.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: self.topAnchor),
            imageView.heightAnchor.constraint(equalTo: self.widthAnchor),
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        imageView.backgroundColor = .systemBackground
    }
    
    func layoutLabelStack() {
        let labelStack: UIStackView = {
            let stack: UIStackView = UIStackView(arrangedSubviews: [albumTitle, photoCount])
            stack.axis = .vertical
            stack.alignment = .leading
            stack.distribution = .fillEqually
            return stack
        }()
        
        self.addSubview(labelStack)
        labelStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            labelStack.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            labelStack.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            labelStack.topAnchor.constraint(equalTo: self.imageView.bottomAnchor),
            labelStack.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutImageView()
        layoutLabelStack()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
