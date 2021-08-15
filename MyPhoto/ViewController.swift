//
//  ViewController.swift
//  MyPhoto
//
//  Created by 김인환 on 2021/08/13.
//

import UIKit
import Photos

class ViewController: UIViewController {
    
    weak var collectionView: UICollectionView!

    var fetchResult: PHFetchResult<PHAsset>!
    let imageManager: PHCachingImageManager = PHCachingImageManager()
    
    func requestCollection() {
        let cameraRoll: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
        
        guard let cameraRollCollection = cameraRoll.firstObject else {
            print("CameraRollCollection: 0")
            return
        }
        
        let fetchOptions: PHFetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [ NSSortDescriptor(key: "creationDate", ascending: false) ]
        self.fetchResult = PHAsset.fetchAssets(in: cameraRollCollection, options: fetchOptions)
        print(self.fetchResult.count)
    }
    
    func layoutCollectionView() {
        let flowLayout: UICollectionViewFlowLayout = {
            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.minimumInteritemSpacing = 10
            layout.headerReferenceSize = CGSize(width: self.view.frame.width, height: 100)
            let size = (self.view.frame.width - 80) / 2
            layout.itemSize = CGSize(width: size, height: size )
            let safeArea = self.view.safeAreaInsets
            layout.sectionInset = UIEdgeInsets(top: safeArea.top, left: safeArea.left + 20, bottom: safeArea.bottom, right: safeArea.right + 20)
            return layout
        }()
        
        let collectionView: UICollectionView = {
            let collection:UICollectionView = UICollectionView(frame: self.view.safeAreaLayoutGuide.layoutFrame, collectionViewLayout: flowLayout)
            collection.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)
            collection.register(TitleHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TitleHeaderView.identifier)
            collection.dataSource = self
            collection.delegate = self
            collection.backgroundColor = .white
            return collection
        }()
        
        self.view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        self.collectionView = collectionView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "앨범"
        layoutCollectionView()
        
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            print("Authorized.")
            self.requestCollection()
            self.collectionView.reloadData()
        case .denied:
            print("Denied.")
        case .limited:
            print("Limited.")
        case .notDetermined:
            print("Not Determined.")
            PHPhotoLibrary.requestAuthorization({(status) in
                                                    switch status {
                                                    case .authorized:
                                                        print("Authorized.")
                                                        self.requestCollection()
                                                        OperationQueue.main.addOperation {
                                                            self.collectionView.reloadData()
                                                        }
                                                    case .denied:
                                                        print("Denied.")
                                                    case .limited:
                                                        print("Limited.")
                                                    case .restricted:
                                                        print("Restricted.")
                                                    default:
                                                        break
                                                    }})
        case .restricted:
            print("Restricted.")
        @unknown default:
            break
        }
//        PHPhotoLibrary.shared().register(self)
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.fetchResult?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell: PhotoCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier, for: indexPath) as? PhotoCollectionViewCell else {
            return UICollectionViewCell()
        }
        imageManager.requestImage(for: self.fetchResult[indexPath.item], targetSize: CGSize(width: 150.0, height: 150.0), contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
            cell.imageView.image = image
        })
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let headerSectionView: TitleHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TitleHeaderView.identifier, for: indexPath) as? TitleHeaderView else {
                return UICollectionReusableView()
            }
            return headerSectionView
        default:
            assert(false)
        }
    }
}

extension ViewController: UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}
