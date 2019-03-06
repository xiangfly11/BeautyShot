//
//  BSMainViewController.swift
//  BeautyShot
//
//  Created by Jiaxiang Li on 2019/2/14.
//  Copyright © 2019 XiaoFan Wang. All rights reserved.
//

import UIKit
import AVFoundation
import Photos


class BSMainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.configPicker()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.view.backgroundColor = UIColor.red
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
         self.configPicker()
    }
    
    private func configPicker() {
        
        var config = YPImagePickerConfiguration()
        config.library.mediaType = .photoAndVideo
        config.shouldSaveNewPicturesToAlbum = false
        config.video.compression = AVAssetExportPresetMediumQuality
        config.startOnScreen = .library
        config.screens = [.library, .photo, .video]
        config.video.libraryTimeLimit = 500.0
        config.showsCrop = .rectangle(ratio: (16/9))
        config.wordings.libraryTitle = "Gallery"
        config.hidesStatusBar = false
        config.hidesBottomBar = false
        config.library.maxNumberOfItems = 5
        let picker = YPImagePicker(configuration: config)
        picker.didFinishPicking { [unowned picker] items, cancelled in
            if cancelled {
                print("Picker was canceled")
                picker.dismiss(animated: true, completion: nil)
                return
            }
            _ = items.map { print("🧀 \($0)") }
        
//            self.selectedItems = items
//            if let firstItem = items.first {
//                switch firstItem {
//                case .photo(let photo):
//                    self.selectedImageV.image = photo.image
//                    picker.dismiss(animated: true, completion: nil)
//                case .video(let video):
//                    self.selectedImageV.image = video.thumbnail
//
//                    let assetURL = video.url
//                    let playerVC = AVPlayerViewController()
//                    let player = AVPlayer(playerItem: AVPlayerItem(url:assetURL))
//                    playerVC.player = player
//
//                    picker.dismiss(animated: true, completion: { [weak self] in
//                        self?.present(playerVC, animated: true, completion: nil)
//                        print("😀 \(String(describing: self?.resolutionForLocalVideo(url: assetURL)!))")
//                    })
//                }
//            }
            
        }
        

        self.navigationController?.pushViewController(picker, animated: true)
        let pickerVC = YPPickerVC()
        self.navigationController?.pushViewController(pickerVC, animated: true)
        present(picker, animated: true, completion: nil)
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

extension BSMainViewController {
    func resolutionForLocalVideo(url: URL) -> CGSize? {
        guard let track = AVURLAsset(url: url).tracks(withMediaType: AVMediaType.video).first else { return nil }
        let size = track.naturalSize.applying(track.preferredTransform)
        return CGSize(width: abs(size.width), height: abs(size.height))
    }
}
