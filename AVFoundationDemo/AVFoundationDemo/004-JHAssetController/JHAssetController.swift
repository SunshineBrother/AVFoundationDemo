//
//  JHAssetController.swift
//  AVFoundationDemo
//
//  Created by sunshine on 2022/11/7.
//

import UIKit
import AVKit

typealias NSErrorPointer = AutoreleasingUnsafeMutablePointer<NSError?>
class JHAssetController: UIViewController {
    var asset: AVAsset? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let url = Bundle.main.url(forResource: "576bc2fc91ef22121", withExtension: ".mp4") else {
            assert(false, "没有获取到资源")
            return
        }
        let asset = AVAsset.init(url: url)
        self.asset = asset
//        let keys = ["duration"]
//        assert.loadValuesAsynchronously(forKeys: keys) {
//            var error: NSErrorPointer? = nil
//            let status = assert.statusOfValue(forKey: "duration", error: error)
//            switch status {
//            case .unknown:
//                print("unknown")
//            case .loading:
//                print("loading")
//            case .loaded:
//                let duration = CMTimeGetSeconds(assert.duration)
//                print("loaded->time:\(duration)")
//            case .failed:
//                print("failed")
//            case .cancelled:
//                print("cancelled")
//            default:
//                break
//            }
//            print(error)
//
//        }
        let formatsKey = "availableMetadataFormats"
        let commonMetadataKey = "commonMetadata"
        let durationKey = "duration"
        asset.loadValuesAsynchronously(forKeys: [formatsKey, commonMetadataKey, durationKey]) {
            // 查询所有元数据
            print("----查询所有元数据---")
            for item in asset.availableMetadataFormats {
                let metadata =  asset.metadata(forFormat: item)
                print("-查询所有元数据:", metadata)
            }
           
            // 时长
            let duration = CMTimeGetSeconds(asset.duration)
            print("loaded->time:\(duration)")
            
            // 获取Common key space 下的元数据
            print("-----获取Common key space 下的元数据----")
            let metadata = asset.commonMetadata
            print(metadata)
        
            let titleID: AVMetadataIdentifier = .commonIdentifierTitle
            let titleItems = AVMetadataItem.metadataItems(from: metadata, filteredByIdentifier: titleID)
            if let item = titleItems.first {
                print("获取Common key space 下的元数据:",item)
            }
            
        }
    
        print("-------------------")
        // 查询所有元数据
        let metadata = asset.metadata(forFormat: .iTunesMetadata)
        for item in metadata {
            print("key:\(item.keyString())--value:\(item.value)")
            
        }
        
        
    }

    
    
    
    @IBAction func ExportSessionEvent(_ sender: Any) {
  
        
    }
    
    
 
}
