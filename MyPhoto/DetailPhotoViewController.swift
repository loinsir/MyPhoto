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
    
    //toolbar
    lazy var activityViewButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(touchShareButton(_:)))
    lazy var favoriteButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(touchFavoriteButton(_:)))
    lazy var deleteButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(touchDeleteButton(_:)))
    
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
    
    func layoutToolbar() {
        let spacer: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        guard let asset: PHAsset = asset else { return }
        favoriteButton.tintColor = asset.isFavorite ? UIColor.systemRed : UIColor.systemBlue
        self.toolbarItems = [activityViewButton, spacer, favoriteButton, spacer, deleteButton]
        self.navigationController?.isToolbarHidden = false
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
    
    @objc func touchShareButton(_ sender: UIBarButtonItem) {
        guard let imageToshare: UIImage = imageView.image else { return }
        let activityViewController = UIActivityViewController(activityItems: [imageToshare], applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @objc func touchFavoriteButton(_ sender: UIBarButtonItem) {
        guard let targetAsset: PHAsset = self.asset else { return }
        PHPhotoLibrary.shared().performChanges({
            let request: PHAssetChangeRequest = PHAssetChangeRequest(for: targetAsset)
            request.isFavorite = !targetAsset.isFavorite
        }, completionHandler: { _,_ in
            OperationQueue.main.addOperation {
                if self.favoriteButton.tintColor == .systemRed {
                    self.favoriteButton.tintColor = .systemBlue
                } else {
                    self.favoriteButton.tintColor = .systemRed
                }
            }
        })
    }
    
    @objc func touchDeleteButton(_ sender: UIBarButtonItem) {
        guard let assetToDelete: PHAsset = asset else { return }
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets([assetToDelete] as NSArray)
        }, completionHandler: { _,_ in
            OperationQueue.main.addOperation {
                self.navigationController?.popViewController(animated: true)
            }
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .systemBackground
        requestImage()
        layoutScrollView()
        layoutImageView()
        layoutToolbar()
        PHPhotoLibrary.shared().register(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
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

extension DetailPhotoViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        OperationQueue.main.addOperation {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
