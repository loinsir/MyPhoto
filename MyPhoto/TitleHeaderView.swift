//
//  TitleHeaderView.swift
//  MyPhoto
//
//  Created by 김인환 on 2021/08/15.
//

import UIKit

class TitleHeaderView: UICollectionReusableView {
    
    let albumTitle: UILabel = UILabel()
    
    static let identifier: String = "headerView"
    
    func layoutTitleHeader() {
        albumTitle.text = "앨범"
        albumTitle.font = UIFont.boldSystemFont(ofSize: 33)
        albumTitle.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(albumTitle)
        
        NSLayoutConstraint.activate([
            albumTitle.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10.0),
            albumTitle.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10.0)
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
