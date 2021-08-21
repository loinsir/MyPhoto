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
    
    var selectButton: UIBarButtonItem?
    var selectMode: Bool = false
    
    weak var collectionView: UICollectionView?
    let imageManager: PHCachingImageManager = PHCachingImageManager()
    
    var arrangeButton: UIBarButtonItem?
    lazy var cellImageWidth: CGFloat = self.view.frame.width * 0.325
    
    var selectedCellIndexPaths: [IndexPath] = []
    
    func requestCollections(ascending: Bool) {
        guard let fetchAlbum: PHAssetCollection = self.album else {
            return
        }
        
        let fetchOptions: PHFetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: ascending)]
        let fetchResult: PHFetchResult<PHAsset> = PHAsset.fetchAssets(in: fetchAlbum, options: fetchOptions)
        self.fetchResult = fetchResult
    }
    
    func layoutCollectionView() {
        
        let flowLayout: UICollectionViewFlowLayout = {
            let layout = UICollectionViewFlowLayout()
            layout.itemSize = CGSize(width: cellImageWidth, height: cellImageWidth)
            layout.scrollDirection = .vertical
            layout.minimumLineSpacing = 5
            layout.minimumInteritemSpacing = 2
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
    
    func layoutToolbar() {
        let arrangeButton: UIBarButtonItem = UIBarButtonItem(title: "최신순", style: .plain, target: self, action: #selector(touchArrangeButton(_:)))
        let spacer: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        self.toolbarItems = [spacer, arrangeButton, spacer]
        self.navigationController?.isToolbarHidden = false
        self.arrangeButton = arrangeButton
    }
    
    func layoutSelectButton() {
        let selectButton: UIBarButtonItem = UIBarButtonItem(title: "선택", style: .plain, target: self, action: #selector(touchSelectButton(_:)))
        self.navigationItem.setRightBarButtonItems([selectButton], animated: true)
        self.selectButton = selectButton
    }
    
    @objc func touchSelectButton(_ sender: UIBarButtonItem) {
        switch sender.title {
        case "선택":
            sender.title = "취소"
            self.selectMode = true
            self.title = "항목 선택"
            self.arrangeButton?.isEnabled = false
            self.collectionView?.allowsMultipleSelection = true

        case "취소":
            sender.title = "선택"
            self.selectMode = false
            self.title = self.album?.localizedTitle
            self.navigationController?.toolbar.isUserInteractionEnabled = true
            self.arrangeButton?.isEnabled = true
            self.collectionView?.allowsMultipleSelection = false
            self.selectedCellIndexPaths.forEach({self.collectionView?.deselectItem(at: $0, animated: true)})
        default:
            return
        }
    
    }
    
    @objc func touchArrangeButton(_ sender: UIBarButtonItem) {
        switch sender.title {
        case "최신순":
            requestCollections(ascending: false)
            self.arrangeButton?.title = "과거순"
        case "과거순":
            requestCollections(ascending: true)
            self.arrangeButton?.title = "최신순"
        case .none:
            return
        case .some(_):
            return
        }
        
        self.collectionView?.reloadSections(IndexSet(0...0))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .systemBackground
        requestCollections(ascending: true) //initial ascending = true
        layoutCollectionView()
        layoutToolbar()
        layoutSelectButton()
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch selectMode {
        case false:
            self.collectionView?.deselectItem(at: indexPath, animated: true)
            guard let asset = self.fetchResult?[indexPath.item] else {
                return
            }
            let detailPhotoViewController = DetailPhotoViewController()
            detailPhotoViewController.asset = asset
            self.navigationController?.pushViewController(detailPhotoViewController, animated: true)
        case true:
            self.selectedCellIndexPaths.append(indexPath)
        }
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

        let targetSize = CGSize(width: cellImageWidth, height: cellImageWidth)
        
        guard let currentFetchResult = self.fetchResult?[indexPath.item] else {
            return UICollectionViewCell()
        }
        
        imageManager.requestImage(for: currentFetchResult, targetSize: targetSize, contentMode: .aspectFill, options: requestOptions, resultHandler: {(image, _) in
                                    cell.imageView.image = image}
        )
        
        return cell
    }
}
