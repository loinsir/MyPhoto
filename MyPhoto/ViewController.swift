//
//  ViewController.swift
//  MyPhoto
//
//  Created by 김인환 on 2021/08/13.
//

import UIKit
import Photos

class Album {
    var title: String
    var count: Int
    var collection: PHAssetCollection
    
    init(title: String, count: Int, collection: PHAssetCollection) {
        self.title = title
        self.count = count
        self.collection = collection
    }
}

class ViewController: UIViewController {
    
    weak var collectionView: UICollectionView!
    
    let imageManager: PHCachingImageManager = PHCachingImageManager()
    var albums: [Album] = []
    var albumCoverAssets: [PHAsset] = []
    
    func requestCollection() {
        let smartAlbum: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
        let favoriteAlbums: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumFavorites, options: nil)
        let albumRegular: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
        
        [smartAlbum, favoriteAlbums, albumRegular].forEach({
            $0.enumerateObjects({(collection, index, _) in
                guard let title = collection.localizedTitle else {
                    return
                }
                
                let options = PHFetchOptions()
                options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                let assets: PHFetchResult<PHAsset> = PHAsset.fetchAssets(in: collection, options: options)
                self.albums.append(Album(title: title, count: assets.count, collection: collection))
                
                guard let albumCoverAsset: PHAsset = assets.firstObject else {
                    return
                }
                self.albumCoverAssets.append(albumCoverAsset)
            })
        })
        
    }
    
    func layoutCollectionView() {
        let flowLayout: UICollectionViewFlowLayout = {
            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.minimumInteritemSpacing = 10
            layout.headerReferenceSize = CGSize(width: self.view.frame.width, height: 100)
            let size = (self.view.frame.width - 50) / 2
            layout.itemSize = CGSize(width: size, height: size * 1.3)
            let safeArea = self.view.safeAreaInsets
            layout.sectionInset = UIEdgeInsets(top: safeArea.top, left: safeArea.left + 20, bottom: safeArea.bottom, right: safeArea.right + 20)
            return layout
        }()
        
        let collectionView: UICollectionView = {
            let collection: UICollectionView = UICollectionView(frame: self.view.safeAreaLayoutGuide.layoutFrame, collectionViewLayout: flowLayout)
            collection.register(AlbumCollectionViewCell.self, forCellWithReuseIdentifier: AlbumCollectionViewCell.identifier)
            collection.register(TitleHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TitleHeaderView.identifier)
            collection.dataSource = self
            collection.delegate = self
            collection.backgroundColor = .systemBackground
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
        self.view.backgroundColor = .systemBackground
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
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.albumCoverAssets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell: AlbumCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: AlbumCollectionViewCell.identifier, for: indexPath) as? AlbumCollectionViewCell else {
            return UICollectionViewCell()
        }
        let size = (self.view.frame.width - 20) / 2
        let targetSize: CGSize = CGSize(width: size, height: size)
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.resizeMode = .exact
        imageManager.requestImage(for: self.albumCoverAssets[indexPath.item], targetSize: targetSize, contentMode: .aspectFill, options: requestOptions, resultHandler: { image, _ in
            cell.imageView.image = image
        })
        cell.albumTitle.text = self.albums[indexPath.item].title
        cell.photoCount.text = String.init(self.albums[indexPath.item].count)
        
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoListViewController: PhotoListViewController = {
            let viewController: PhotoListViewController = PhotoListViewController()
            let currentAlbum = self.albums[indexPath.item]
            viewController.album = currentAlbum.collection
            viewController.title = currentAlbum.title
            return viewController
        }()
        self.navigationController?.pushViewController(photoListViewController, animated: true)
    }
}

extension ViewController: UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}
