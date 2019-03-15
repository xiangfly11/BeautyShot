//
//  YPCameraView.swift
//  YPImgePicker
//
//  Created by Sacha Durand Saint Omer on 2015/11/14.
//  Copyright © 2015 Yummypets. All rights reserved.
//

import UIKit
import Stevia

enum YPCameraViewType {
    case cameraType
    case videoType
}

class YPCameraView: UIView, UIGestureRecognizerDelegate {
    
    let focusView = UIView(frame: CGRect(x: 0, y: 0, width: 90, height: 90))
    let previewViewContainer = UIView()
    let buttonsContainer = UIView()
    let flipButton = UIButton()
    let shotButton = UIButton()
    let flashButton = UIButton()
    let timeElapsedLabel = UILabel()
    let progressBar = UIProgressView()

    convenience init(overlayView: UIView? = nil, type: YPCameraViewType) {
        self.init(frame: .zero)
       /***
        if let overlayView = overlayView {
            // View Hierarchy
            sv(
                previewViewContainer,
                overlayView,
                progressBar,
                timeElapsedLabel,
                flashButton,
                flipButton,
                buttonsContainer.sv(
                    shotButton
                )
            )
        } else {
            // View Hierarchy
            sv(
                previewViewContainer,
                progressBar,
                timeElapsedLabel,
                flashButton,
                flipButton,
                buttonsContainer.sv(
                    shotButton
                )
            )
        }
        
        // Layout
        let isIphone4 = UIScreen.main.bounds.height == 480
        let sideMargin: CGFloat = isIphone4 ? 20 : 0
        layout(
            0,
            |-sideMargin-previewViewContainer-sideMargin-|,
            -2,
            |progressBar|,
            0,
            |buttonsContainer|,
            0
        )
        previewViewContainer.heightEqualsWidth()

        overlayView?.followEdges(previewViewContainer)

        |-(15+sideMargin)-flashButton.size(42)
        flashButton.Bottom == previewViewContainer.Bottom - 15

        flipButton.size(42)-(15+sideMargin)-|
        flipButton.Bottom == previewViewContainer.Bottom - 15
        
        timeElapsedLabel-(15+sideMargin)-|
        timeElapsedLabel.Top == previewViewContainer.Top + 15
        
        shotButton.centerVertically()
        shotButton.size(84).centerHorizontally()

        // Style
        backgroundColor = YPConfig.colors.photoVideoScreenBackground
        previewViewContainer.backgroundColor = .black
        timeElapsedLabel.style { l in
            l.textColor = .white
            l.text = "00:00"
            l.isHidden = true
            l.font = .monospacedDigitSystemFont(ofSize: 13, weight: UIFont.Weight.medium)
        }
        progressBar.style { p in
            p.trackTintColor = .clear
            p.tintColor = .red
        }
        flashButton.setImage(YPConfig.icons.flashOffIcon, for: .normal)
        flipButton.setImage(YPConfig.icons.loopIcon, for: .normal)
        shotButton.setImage(YPConfig.icons.capturePhotoImage, for: .normal)
        ***/
        
       
        self.previewViewContainer.backgroundColor = UIColor.clear
        self.flashButton.setImage(YPConfig.icons.flashOffIcon, for: .normal)
        self.flipButton.setImage(YPConfig.icons.loopIcon, for: .normal)
        self.shotButton.setImage(YPConfig.icons.capturePhotoImage, for: .normal)
        self.addSubview(self.previewViewContainer)
        self.addSubview(self.progressBar)
        self.addSubview(self.flipButton)
        self.addSubview(self.buttonsContainer)
        self.addSubview(self.timeElapsedLabel)
        self.buttonsContainer.addSubview(self.shotButton)
        self.buttonsContainer.addSubview(self.flashButton)
        self.buttonsContainer.addSubview(self.flipButton)
        
        self.timeElapsedLabel.textColor = UIColor.white
        self.timeElapsedLabel.text = "00:00"
        self.timeElapsedLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        self.timeElapsedLabel.textAlignment = .right

        self.timeElapsedLabel.snp.makeConstraints { (maker) in
            maker.top.equalTo(self.previewViewContainer).offset(10)
            maker.trailing.equalTo(self.previewViewContainer).offset(-10)
            maker.leading.equalTo(self.previewViewContainer).offset(10)
            maker.height.equalTo(20)
        }
        
        if let resultOverlayView = overlayView {
            self.addSubview(resultOverlayView)
        }
        
        if type == .cameraType {
            self.previewViewContainer.snp.makeConstraints { (maker) in
                maker.leading.trailing.equalTo(self)
                maker.top.equalTo(self)
                maker.height.equalTo(UIScreen.main.bounds.width)
            }
            self.timeElapsedLabel.isHidden = true
            self.buttonsContainer.backgroundColor = UIColor.white
            self.shotButton.setImage(YPConfig.icons.capturePhotoImage, for: .normal)
            
            self.buttonsContainer.snp.makeConstraints { (maker) in
                maker.leading.trailing.equalTo(self)
                maker.bottom.equalTo(self)
                maker.top.equalTo(self.previewViewContainer.snp.bottom)
            }
        }else if type == .videoType{
            self.previewViewContainer.snp.makeConstraints { (maker) in
                maker.edges.equalTo(self)
            }
            
            self.buttonsContainer.backgroundColor = UIColor.clear
            self.timeElapsedLabel.isHidden = false
            self.shotButton.setImage(YPConfig.icons.captureVideoImage, for: .normal)
            
            self.buttonsContainer.snp.makeConstraints { (maker) in
                maker.leading.trailing.equalTo(self)
                maker.bottom.equalTo(self)
                maker.height.equalTo(convertDesignHeightToCurrentHeight(height: 200))
            }
        }
        
        
        self.shotButton.snp.makeConstraints { (maker) in            maker.centerX.equalTo(self.buttonsContainer)
            maker.centerY.equalTo(self.buttonsContainer)
            maker.height.width.equalTo(convertDesignHeightToCurrentHeight(height: 65))
            
        }
        
        self.flipButton.snp.makeConstraints { (maker) in
            maker.leading.equalTo(self.buttonsContainer).offset(15)
            maker.top.equalTo(self.buttonsContainer).offset(25)
            maker.width.height.equalTo(convertDesignHeightToCurrentHeight(height: 35))
        }
        
        self.flashButton.snp.makeConstraints { (maker) in
            maker.trailing.equalTo(self.buttonsContainer).offset(-15)
            maker.top.equalTo(self.buttonsContainer).offset(25)
            maker.width.height.equalTo(convertDesignHeightToCurrentHeight(height: 35))
        }
 
    }
}
