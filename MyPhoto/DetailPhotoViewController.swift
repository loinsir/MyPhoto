//
//  DetailPhotoViewController.swift
//  MyPhoto
//
//  Created by 김인환 on 2021/08/18.
//

import UIKit
import Photos

class DetailPhotoViewController: UIViewController {
    
    var asset: PHAsset?
    var scrollView: UIScrollView?
    let imageView: UIImageView = UIImageView()
    let imageManager: PHImageManager = PHImageManager()
    
    func layoutScrollView() {
        let scrollView: UIScrollView = UIScrollView(frame: self.view.frame)
        scrollView.maximumZoomScale = 3.0
        scrollView.contentMode = .scaleAspectFit
        scrollView.delegate = self
        
        self.view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ])
        
        self.scrollView = scrollView
    }
    
    func layoutImageView() {
        
        self.scrollView?.addSubview(self.imageView)
        self.imageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            self.imageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.imageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
        ])
    }
    
    func requestImage() {
        guard let requestAsset: PHAsset = asset else {
            return
        }
        
        let targetSize: CGSize = CGSize(width: self.view.frame.width, height: self.view.frame.height)
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.resizeMode = .exact
        
        imageManager.requestImage(for: requestAsset, targetSize: targetSize, contentMode: .aspectFit, options: requestOptions, resultHandler: { image, _ in
            self.imageView.image = image
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .systemBackground
        requestImage()
        layoutScrollView()
        layoutImageView()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension DetailPhotoViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}
