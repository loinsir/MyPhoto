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
    
    lazy var imageSize: CGFloat = self.view.frame.width * 0.325
    
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
            layout.itemSize = CGSize(width: imageSize, height: imageSize)
            layout.scrollDirection = .vertical
            layout.minimumLineSpacing = 4
            layout.minimumInteritemSpacing = 4
            return layout
        }()
        
        let collectionView: UICollectionView = {
            let collection: UICollectionView = UICollectionView(frame: self.view.safeAreaLayoutGuide.layoutFrame,
                                                                collectionViewLayout: flowLayout)
            collection.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)
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
        guard let cell: PhotoCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier, for: indexPath) as? PhotoCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.resizeMode = .exact

        let targetSize = CGSize(width: imageSize, height: imageSize)
        
        guard let currentFetchResult = self.fetchResult?[indexPath.item] else {
            return UICollectionViewCell()
        }
        
        imageManager.requestImage(for: currentFetchResult, targetSize: targetSize, contentMode: .aspectFill, options: requestOptions, resultHandler: {(image, _) in
            cell.imageView.image = image
        })
        
        return cell
    }
}
