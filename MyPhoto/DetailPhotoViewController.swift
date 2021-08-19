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
            scrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
        ])
        
        self.scrollView = scrollView
    }
    
    func layoutImageView() {
        
        self.scrollView?.addSubview(self.imageView)
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.contentMode = .scaleAspectFit
        
        guard let scrollView: UIScrollView = self.scrollView else {
            return
        }

        NSLayoutConstraint.activate([
            self.imageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            self.imageView.heightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.heightAnchor)
        ])
    }
    
    func requestImage() {
        guard let requestAsset: PHAsset = asset else {
            return
        }
        
        let targetSize: CGSize = CGSize(width: requestAsset.pixelWidth, height: requestAsset.pixelHeight)
        
        imageManager.requestImage(for: requestAsset, targetSize: targetSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
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
