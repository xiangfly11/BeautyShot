//
//  YPFiltersView.swift
//  photoTaking
//
//  Created by Sacha Durand Saint Omer on 21/10/16.
//  Copyright © 2016 octopepper. All rights reserved.
//

import Stevia


class YPFiltersView: UIView {
    
    let imageView = UIImageView()
    var filterItemsView: UICollectionView!
    var waterMarkItemsView: UICollectionView!
    var filtersLoader: UIActivityIndicatorView!
    fileprivate let collectionViewContainer: UIView = UIView()
    
    convenience init() {
        self.init(frame: CGRect.zero)
        filterItemsView = UICollectionView(frame: CGRect.zero, collectionViewLayout: horizentalLayout())
        filtersLoader = UIActivityIndicatorView(style: .gray)
        filtersLoader.hidesWhenStopped = true
        filtersLoader.startAnimating()
        filtersLoader.color = YPConfig.colors.tintColor
        
        waterMarkItemsView = UICollectionView(frame: .zero, collectionViewLayout: verticalFlowLayout())
       
        /***
        sv(
            imageView,
            collectionViewContainer.sv(
                filtersLoader,
                filterItemsView,
                waterMarkItemsView
            )
        )
        
        let isIphone4 = UIScreen.main.bounds.height == 480
        let sideMargin: CGFloat = isIphone4 ? 20 : 0
        
        |-sideMargin-imageView.top(0)-sideMargin-|
        |-sideMargin-collectionViewContainer-sideMargin-|
        collectionViewContainer.bottom(0)
        imageView.Bottom == collectionViewContainer.Top
        filterItemsView.Top == collectionViewContainer.Top
        |filterItemsView.height(160)|
        waterMarkItemsView.Top == filterItemsView.Bottom
        waterMarkItemsView.Bottom == collectionViewContainer.Bottom
//        waterMarkItemsView.width(collectionViewContainer.Width)
        waterMarkItemsView.width(collectionViewContainer.Width)
        filtersLoader.centerInContainer()
        imageView.heightEqualsWidth()
        ***/
        self.addSubview(self.imageView)
        self.addSubview(self.collectionViewContainer)
        self.collectionViewContainer.addSubview(self.filtersLoader)
        self.collectionViewContainer.addSubview(self.filterItemsView)
        self.collectionViewContainer.addSubview(self.waterMarkItemsView)
        
        let screenWidth = UIScreen.main.bounds.size.width
        self.imageView.snp.makeConstraints { (maker) in
            maker.top.equalTo(self)
            maker.leading.trailing.equalTo(self)
            maker.height.equalTo(screenWidth)
        }
        
        self.collectionViewContainer.snp.makeConstraints { (maker) in
            maker.top.equalTo(self.imageView.snp.bottom)
            maker.leading.trailing.equalTo(self)
            maker.bottom.equalTo(self)
        }
        
        self.filterItemsView.snp.makeConstraints { (maker) in
            maker.top.equalTo(self.collectionViewContainer.snp.top).offset(10)
            maker.leading.trailing.equalTo(self.collectionViewContainer)
            maker.height.equalTo(160)
        }
        
        self.filtersLoader.snp.makeConstraints { (maker) in
            maker.center.equalTo(self.collectionViewContainer)
            maker.width.height.equalTo(40)
        }
        
        self.waterMarkItemsView.snp.makeConstraints { (maker) in
            maker.top.equalTo(self.filterItemsView.snp.bottom).offset(10)
            maker.leading.trailing.equalTo(self.collectionViewContainer)
            maker.bottom.equalTo(self.collectionViewContainer)
        }
        
        
        
        backgroundColor = UIColor(r: 247, g: 247, b: 247)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        filterItemsView.backgroundColor = .clear
        filterItemsView.showsHorizontalScrollIndicator = false
        
        waterMarkItemsView.backgroundColor = .clear
        waterMarkItemsView.showsVerticalScrollIndicator = false
    }
    
    func horizentalLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 4
        layout.sectionInset = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
        layout.itemSize = CGSize(width: 100, height: 120)
        return layout
    }
    
    func verticalFlowLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 4
        layout.sectionInset = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
        layout.itemSize = CGSize(width: 60, height: 80)
        return layout
    }
}
