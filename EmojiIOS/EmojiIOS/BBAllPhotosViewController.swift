//
//  BBAllPhotosViewController.swift
//  EmojiIOS
//
//  Created by 陈悦莹 on 12/07/2017.
//  Copyright © 2017 陈悦莹. All rights reserved.
//

import UIKit
import Photos

class BBAllPhotosViewController: UIViewController, PHPhotoLibraryChangeObserver, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    private var KSCREEN_HEIGHT = UIScreen.main.bounds.size.height
    private var KSCREEN_WIDTH = UIScreen.main.bounds.size.width
    
    private var headerView = UIView()
    
    private var defaultHeight: CGFloat = 50
    
    private let completedButton = UIButton()
    
    private let countLable = UILabel()
    
    private var myCollectionView: UICollectionView!
    private let flowLayout = UICollectionViewFlowLayout()
    private let cellIdentifier = "myCell"
    private var photosArray = PHFetchResult<PHAsset>()
    private var selectedPhotosArray = [PHAsset]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        addHeadViewAndBottomView()
        
        createCollectionView()
        
        getAllPhotos()
    }
    
    private func addHeadViewAndBottomView(){
    
        headerView.frame = CGRect(x:0, y:0, width:KSCREEN_WIDTH, height:defaultHeight)
        headerView.backgroundColor = UIColor.red
        view.addSubview(headerView)
        
        let backButton = UIButton()
        backButton.frame = CGRect(x:0,y:0, width:60, height:30)
        backButton.setTitle("cancel", for: .normal)
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.center = CGPoint(x: KSCREEN_WIDTH - 40,y:defaultHeight/1.5)
        backButton.addTarget(self, action: #selector(BBAllPhotosViewController.dismissAction), for: .touchUpInside)
        headerView.addSubview(backButton)
        
        let titleLable = UILabel()
        titleLable.frame = CGRect(x:0, y:0, width: KSCREEN_WIDTH/2, height: defaultHeight)
        titleLable.text = "All photos"
        titleLable.textColor = UIColor.white
        titleLable.center = CGPoint(x: KSCREEN_WIDTH/2, y: defaultHeight/1.5)
        headerView.addSubview(titleLable)
        
        completedButton.frame = CGRect(x:0, y: KSCREEN_HEIGHT, width: KSCREEN_WIDTH, height:44)
        completedButton.backgroundColor = UIColor.blue
        view.addSubview(completedButton)
        
        let overLabel = UILabel()
        overLabel.frame = CGRect(x: KSCREEN_WIDTH/2 + 10, y:0, width: 40, height: 44)
        overLabel.text = "Finish"
        overLabel.textColor = UIColor.green
        completedButton.addSubview(overLabel)
        
        countLable.frame = CGRect(x: KSCREEN_WIDTH/2-25, y:10, width:24, height:24)
        countLable.backgroundColor = UIColor.green
        countLable.textColor = UIColor.white
        countLable.layer.masksToBounds = true
        countLable.layer.cornerRadius = countLable.bounds.size.height/2
        countLable.textAlignment = .center
        completedButton.addSubview(countLable)
    }
    
    func dismissAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func getAllPhotos(){
        PHPhotoLibrary.shared().register(self)
        
        let allOptions = PHFetchOptions()
        
        allOptions.sortDescriptors = [NSSortDescriptor.init(key: "creationDate", ascending: true)]
        
        let allResults = PHAsset.fetchAssets(with: allOptions)
        print(allResults.count)
        photosArray = allResults
        print(allResults[0].location)
        
    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        getAllPhotos()
    }
    
   
    private func createCollectionView(){
        let shape: CGFloat = 5
        let cellWidth: CGFloat = (KSCREEN_WIDTH - 5 * shape)/4
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: shape, bottom:0, right:shape)
        flowLayout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        flowLayout.minimumLineSpacing = shape
        flowLayout.minimumInteritemSpacing = shape
        
        myCollectionView = UICollectionView.init(frame: CGRect(x:0, y:defaultHeight, width:KSCREEN_WIDTH, height: KSCREEN_HEIGHT - defaultHeight), collectionViewLayout:flowLayout)
        myCollectionView.backgroundColor = UIColor.white
        
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        
        myCollectionView.register(MyCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        view.addSubview(myCollectionView)
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photosArray.count
    }
   
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! MyCollectionViewCell
        let manager = PHImageManager.default();
        let option = PHImageRequestOptions()
        option.isSynchronous = true
        manager.requestImage(for: photosArray[indexPath.row], targetSize: CGSize.zero, contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void  in
            cell.imageView.image = result ?? UIImage.init(named: "defaultPhoto")
         
        })
        
        manager.requestImageData(for: photosArray[indexPath.row], options: nil) { (data, _, _, info) in
            let title = (info!["PHImageFileURLKey"] as! NSURL).lastPathComponent
            print(title)
            
        }
        

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currentCell = collectionView.cellForItem(at: indexPath) as! MyCollectionViewCell
        currentCell.isChoose = !currentCell.isChoose
        selectedPhotosArray.append(photosArray[indexPath.row] )

    }
    
    
}

class MyCollectionViewCell: UICollectionViewCell {
    let selectButton = UIButton()
    let imageView = UIImageView()
    var isChoose = false {
        didSet {
            selectButton.isSelected = isChoose
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.frame = contentView.bounds
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        imageView.backgroundColor = UIColor.cyan
        
        selectButton.frame = CGRect(x: contentView.bounds.size.width*3/4-2,y:2, width: contentView.bounds.size.width/4, height:contentView.bounds.size.width/4)
        selectButton.setBackgroundImage(UIImage.init(named: "defaultPhoto"), for: .normal)
        selectButton.setBackgroundImage(UIImage.init(named: "iw_selected"), for: .selected)
        imageView.addSubview(selectButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemened")
    }
}
