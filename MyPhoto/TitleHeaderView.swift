//
//  TitleHeaderView.swift
//  MyPhoto
//
//  Created by 김인환 on 2021/08/15.
//

import UIKit

class TitleHeaderView: UICollectionReusableView {
    
    let albumTitle: UILabel = UILabel()
    let separator: UIView = UIView()
    
    static let identifier: String = "headerView"
    
    func layoutTitleHeader() {
        albumTitle.text = "앨범"
        albumTitle.font = UIFont.boldSystemFont(ofSize: 33)
        albumTitle.translatesAutoresizingMaskIntoConstraints = false
        
        separator.backgroundColor = .systemGray5
        separator.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(albumTitle)
        self.addSubview(separator)
        
        NSLayoutConstraint.activate([
            albumTitle.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20.0),
            albumTitle.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -12.0),
            separator.widthAnchor.constraint(equalTo: self.widthAnchor, constant: 0.5),
            separator.heightAnchor.constraint(equalToConstant: 2.0),
            separator.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -9.0)
        ])
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutTitleHeader()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
