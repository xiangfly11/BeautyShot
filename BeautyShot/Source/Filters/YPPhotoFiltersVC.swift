//
//  YPPhotoFiltersVC.swift
//  photoTaking
//
//  Created by Sacha Durand Saint Omer on 21/10/16.
//  Copyright © 2016 octopepper. All rights reserved.
//

import UIKit
import SnapKit

protocol IsMediaFilterVC: class {
    var didSave: ((YPMediaItem) -> Void)? { get set }
    var didCancel: (() -> Void)? { get set }
}

open class YPPhotoFiltersVC: UIViewController, IsMediaFilterVC, UIGestureRecognizerDelegate {
    
    required public init(inputPhoto: YPMediaPhoto, isFromSelectionVC: Bool) {
        super.init(nibName: nil, bundle: nil)
        
        self.inputPhoto = inputPhoto
        self.isFromSelectionVC = isFromSelectionVC
    }
    
    public var inputPhoto: YPMediaPhoto!
    public var isFromSelectionVC = false

    public var didSave: ((YPMediaItem) -> Void)?
    public var didCancel: (() -> Void)?


    fileprivate let filters: [YPFilter] = YPConfig.filters

    fileprivate var selectedFilter: YPFilter?
    
    fileprivate var filteredThumbnailImagesArray: [UIImage] = []
    fileprivate var thumbnailImageForFiltering: CIImage? // Small image for creating filters thumbnails
    fileprivate var currentlySelectedImageThumbnail: UIImage? // Used for comparing with original image when tapped

    fileprivate var v = YPFiltersView()

    private lazy var waterMarkCanvasView: BSWaterMarkCanvasView = {
        let waterMarkView = BSWaterMarkCanvasView.init()
        
        return waterMarkView
    }()
    
    private var emotionWatermarkItems: [BSWaterMarkItem] = [BSWaterMarkItem]()
    
    private var wordsWatermarkitems: [BSWaterMarkItem] = [BSWaterMarkItem]()
    
    override open var prefersStatusBarHidden: Bool { return YPConfig.hidesStatusBar }
    override open func loadView() { view = v }
    required public init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Life Cycle ♻️

    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.configData()
        
        // Setup of main image an thumbnail images
        v.imageView.image = inputPhoto.image
        thumbnailImageForFiltering = thumbFromImage(inputPhoto.image)
        DispatchQueue.global().async {
            self.filteredThumbnailImagesArray = self.filters.map { filter -> UIImage in
                if let applier = filter.applier,
                    let thumbnailImage = self.thumbnailImageForFiltering,
                    let outputImage = applier(thumbnailImage) {
                    return outputImage.toUIImage()
                } else {
                    return self.inputPhoto.originalImage
                }
            }
            DispatchQueue.main.async {
                self.v.filterItemsView.reloadData()
                self.v.filterItemsView.selectItem(at: IndexPath(row: 0, section: 0),
                                            animated: false,
                                            scrollPosition: UICollectionView.ScrollPosition.bottom)
                self.v.filtersLoader.stopAnimating()
            }
        }
        
        // Setup of Collection View
        v.filterItemsView.register(YPFilterCollectionViewCell.self, forCellWithReuseIdentifier: "FilterCell")
        v.filterItemsView.dataSource = self
        v.filterItemsView.delegate = self
        v.filterItemsView.tag = 1000
        
        self.v.waterMarkItemsView.reloadData()
        self.v.waterMarkItemsView.register(YPFilterCollectionViewCell.self, forCellWithReuseIdentifier: "WaterMarkCell")
        self.v.waterMarkItemsView.dataSource = self
        self.v.waterMarkItemsView.delegate = self
        self.v.waterMarkItemsView.tag = 1001
        
        self.view.addSubview(self.waterMarkCanvasView)
        
        self.waterMarkCanvasView.snp.makeConstraints { (maker) in
            maker.edges.equalTo(self.v.imageView)
        }
        
        
        // Setup of Navigation Bar
        title = YPConfig.wordings.filter
        if isFromSelectionVC {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: YPConfig.wordings.cancel,
                                                               style: .plain,
                                                               target: self,
                                                               action: #selector(cancel))
        }
        setupRightBarButton()
        
        YPHelper.changeBackButtonIcon(self)
        YPHelper.changeBackButtonTitle(self)
        
        // Touch preview to see original image.
        let touchDownGR = UILongPressGestureRecognizer(target: self,
                                                       action: #selector(handleTouchDown))
        touchDownGR.minimumPressDuration = 0
        touchDownGR.delegate = self
        v.imageView.addGestureRecognizer(touchDownGR)
        v.imageView.isUserInteractionEnabled = true
    }
    
    // MARK: Setup - ⚙️
    
    private func configData() {
        self.selectedFilter = YPConfig.filters[0]
        
        let emotionPrefixStr = "Emotion_Watermark_"
        let wordsPrefixStr = "Words_Watermark_"
        
        for i in 1 ... 8 {
            let imageName = emotionPrefixStr + "\(i)"
            if let image = UIImage.init(named: imageName) {
                let waterMarkItem = BSWaterMarkItem.init()
                waterMarkItem.waterMarkImg = image
                waterMarkItem.wmId = imageName
                waterMarkItem.identifierStr = imageName
                self.emotionWatermarkItems.append(waterMarkItem)
            }
        }
        
        for i in 1 ... 9 {
            let imageName = wordsPrefixStr + "\(i)"
            if let image = UIImage.init(named: imageName) {
                let waterMarkItem = BSWaterMarkItem.init()
                waterMarkItem.waterMarkImg = image
                waterMarkItem.wmId = imageName
                waterMarkItem.identifierStr = imageName
                self.wordsWatermarkitems.append(waterMarkItem)
            }
        }
    }
    
    fileprivate func setupRightBarButton() {
        let rightBarButtonTitle = isFromSelectionVC ? YPConfig.wordings.done : YPConfig.wordings.next
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: rightBarButtonTitle,
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(save))
        navigationItem.rightBarButtonItem?.tintColor = YPConfig.colors.tintColor
    }
    
    // MARK: - Methods 🏓

    @objc
    fileprivate func handleTouchDown(sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            v.imageView.image = inputPhoto.originalImage
        case .ended:
            v.imageView.image = currentlySelectedImageThumbnail ?? inputPhoto.originalImage
        default: ()
        }
    }
    
    fileprivate func thumbFromImage(_ img: UIImage) -> CIImage {
        let k = img.size.width / img.size.height
        let scale = UIScreen.main.scale
        let thumbnailHeight: CGFloat = 300 * scale
        let thumbnailWidth = thumbnailHeight * k
        let thumbnailSize = CGSize(width: thumbnailWidth, height: thumbnailHeight)
        UIGraphicsBeginImageContext(thumbnailSize)
        img.draw(in: CGRect(x: 0, y: 0, width: thumbnailSize.width, height: thumbnailSize.height))
        let smallImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return smallImage!.toCIImage()!
    }
    
    // MARK: - Actions 🥂

    @objc
    func cancel() {
        didCancel?()
    }
    
    @objc
    func save() {
        guard let didSave = didSave else { return print("Don't have saveCallback") }
        self.navigationItem.rightBarButtonItem = YPLoaders.defaultLoader

        DispatchQueue.global().async {
            if let f = self.selectedFilter,
                let applier = f.applier,
                let ciImage = self.inputPhoto.originalImage.toCIImage(),
                let modifiedFullSizeImage = applier(ciImage) {
                self.inputPhoto.modifiedImage = modifiedFullSizeImage.toUIImage()
                DispatchQueue.main.async {
                    self.addWatermarkImg(photo: self.inputPhoto.modifiedImage, completion: {
                       
                            didSave(YPMediaItem.photo(p: self.inputPhoto))
                            self.setupRightBarButton()
                        
                    })
                }
                
            } else {
                self.inputPhoto.modifiedImage = nil
            }
            
        }
    }
    
    
    private func addWatermarkImg(photo: UIImage?,completion: @escaping () -> ()) {
        guard let currentPhoto = photo else {
            return
        }
        
        
        let imgFrame = self.waterMarkCanvasView.frame
        self.waterMarkCanvasView.enumerateWaterMarkSource { (identifier, waterMarkView, stop) in
            if let currentWaterMarkView = waterMarkView  {
                let waterMarkImg = currentWaterMarkView.waterMark.waterMarkImg
                let ratioX = currentPhoto.size.width / imgFrame.size.width
                let ratioY = currentPhoto.size.height / imgFrame.size.height
                
                let tmpRect = CGRect(x: 0, y: 0, width: currentWaterMarkView.mWaterMarkSize.width, height: currentWaterMarkView.mWaterMarkSize.height)
                var overlaySize = tmpRect.applying(currentWaterMarkView.transform).size
                let overlayCenter = CGPoint(x: currentWaterMarkView.center.x * ratioX, y: currentWaterMarkView.center.y * ratioY)
                
                if let currentWaterMarkImg = waterMarkImg {
                    overlaySize = CGSize(width: overlaySize.width * ratioX, height: overlaySize.height * ratioY)
                    var tempImg = BSImageUtils.transformImage(with: currentWaterMarkImg, transform: currentWaterMarkView.transform)
                    let ratio = overlaySize.width / currentWaterMarkImg.size.width
                    tempImg = BSImageUtils.transformImage(with: tempImg, transform: CGAffineTransform(scaleX: ratio, y: ratio))
                    self.inputPhoto.modifiedImage = BSImageUtils.addTheImage(withOutScale: self.inputPhoto.modifiedImage, overlay: tempImg, inCenter: overlayCenter)
                   
                    if stop == true {
                        completion()
                    }
                }
            }
           
            
        }
    }
}

extension YPPhotoFiltersVC: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView.tag == 1000 {
            return filteredThumbnailImagesArray.count > 0 ? 1 : 0
        }
        
        if collectionView.tag == 1001 {
            var count = 0
            if self.emotionWatermarkItems.count > 0 {
                count = count + 1
            }
            
            if self.wordsWatermarkitems.count > 0{
                count = count + 1
            }
            
            return count
        }
        
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 1000 {
            return filteredThumbnailImagesArray.count
        }
        
        if collectionView.tag == 1001 {
            if section == 0 {
                return self.emotionWatermarkItems.count
            }
            
            if section == 1 {
                return self.wordsWatermarkitems.count
            }
        }
        
        return 0
    }
    
    
    public func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 1000 {
            let filter = filters[indexPath.row]
            let image = filteredThumbnailImagesArray[indexPath.row]
            if let cell = collectionView
                .dequeueReusableCell(withReuseIdentifier: "FilterCell",
                                     for: indexPath) as? YPFilterCollectionViewCell {
                cell.name.text = filter.name
                cell.imageView.image = image
                return cell
            }
        }
        
        if collectionView.tag == 1001 {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WaterMarkCell", for: indexPath) as? YPFilterCollectionViewCell {
                var waterMarkItem = BSWaterMarkItem()
                if indexPath.section == 0 {
                    waterMarkItem = self.emotionWatermarkItems[indexPath.row]
                }
                
                if indexPath.section == 1 {
                    waterMarkItem = self.wordsWatermarkitems[indexPath.row]
                }
                
                cell.imageView.image = waterMarkItem.waterMarkImg
                
                return cell
            }
            
        }
        
        return UICollectionViewCell()
    }
}

extension YPPhotoFiltersVC: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == 1000 {
            selectedFilter = filters[indexPath.row]
            currentlySelectedImageThumbnail = filteredThumbnailImagesArray[indexPath.row]
            self.v.imageView.image = currentlySelectedImageThumbnail
        }
        
        
        if collectionView.tag == 1001 {
            var waterMarkItem = BSWaterMarkItem()
            if indexPath.section == 0 {
                waterMarkItem = self.emotionWatermarkItems[indexPath.row]
            }else if indexPath.section == 1 {
                waterMarkItem = self.wordsWatermarkitems[indexPath.row]
            }
            
            self.waterMarkCanvasView.addWaterMark(withMarkImage: waterMarkItem)
        }
    }
}
