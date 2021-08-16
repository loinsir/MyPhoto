//
//  PhotoListViewController.swift
//  MyPhoto
//
//  Created by 김인환 on 2021/08/16.
//

import UIKit
import Photos

class PhotoListViewController: UIViewController {
    
    var album: PHAssetCollection?
    var fetchResult: PHFetchResult<PHAsset>?
    
    weak var collectionView: UICollectionView?
    let imageManager: PHCachingImageManager = PHCachingImageManager()
    
    func requestCollections() {
        guard let fetchAlbum: PHAssetCollection = self.album else {
            return
        }
        
        let fetchOptions: PHFetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        let fetchResult: PHFetchResult<PHAsset> = PHAsset.fetchAssets(in: fetchAlbum, options: fetchOptions)
        self.fetchResult = fetchResult
    }
    
    func layoutCollectionView() {
        
        let flowLayout: UICollectionViewFlowLayout = {
            let layout = UICollectionViewFlowLayout()
            let size: CGFloat = self.view.frame.width * 0.3
            layout.itemSize = CGSize(width: size, height: size)
            layout.scrollDirection = .vertical
            layout.minimumLineSpacing = 10.0
            layout.minimumInteritemSpacing = 10
            layout.minimumLineSpacing = 10
            return layout
        }()
        
        let collectionView: UICollectionView = {
            let collection: UICollectionView = UICollectionView(frame: self.view.safeAreaLayoutGuide.layoutFrame,
                                                                collectionViewLayout: flowLayout)
            collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "default")
            collection.dataSource = self
            collection.delegate = self
            collection.backgroundColor = .systemBackground
            return collection
        }()
        
        self.view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        let safeArea = self.view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor)
        ])
        
        self.collectionView = collectionView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .systemBackground
        requestCollections()
        layoutCollectionView()
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

extension PhotoListViewController: UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}

extension PhotoListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.fetchResult?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "default", for: indexPath)
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.resizeMode = .exact
        let size: CGFloat = self.view.frame.width * 0.3
        let targetSize = CGSize(width: size, height: size)
        
        guard let currentFetchResult = self.fetchResult?[indexPath.item] else {
            return UICollectionViewCell()
        }
        
        imageManager.requestImage(for: currentFetchResult, targetSize: targetSize, contentMode: .aspectFill, options: requestOptions, resultHandler: {(image, _) in
            let imageView = UIImageView(image: image)
            OperationQueue.main.addOperation {
                cell.contentView.addSubview(imageView)
            }
        })
        
        return cell
    }
}
