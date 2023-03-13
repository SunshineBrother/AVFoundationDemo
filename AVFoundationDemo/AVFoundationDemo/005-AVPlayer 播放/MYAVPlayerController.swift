//
//  MYAVPlayerController.swift
//  AVFoundationDemo
//
//  Created by sunshine on 2023/3/13.
//

import UIKit

class MYAVPlayerController: UIViewController {
    
    @IBOutlet weak var generatorView: UIView!
    @IBOutlet weak var playerView: UIView!
    var asset: AVAsset? = nil
    var player: AVPlayer? = nil
    var playerItem: AVPlayerItem? = nil
    /// 缩略图
    var imagegenrator: AVAssetImageGenerator? = nil
    
    deinit {
        playerItem?.removeObserver(self, forKeyPath: "status", context: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let url = Bundle.main.url(forResource: "576bc2fc91ef22121", withExtension: ".mp4") else {
            assert(false, "没有获取到资源")
            return
        }
        let asset = AVAsset.init(url: url)
        self.asset = asset
        let playerItem = AVPlayerItem.init(asset: asset)
        self.playerItem = playerItem
        self.player = AVPlayer.init(playerItem: playerItem)
      
         
        let playerLayer = AVPlayerLayer.init(player: player)
        playerLayer.frame = playerView.bounds
        playerView.layer.addSublayer(playerLayer)
        // playerItem添加观察者 监听状态变化
        playerItem.addObserver(self, forKeyPath: "status", options: [.old, .new], context: nil)
        // 时间监听
        let cmTime = CMTime(value: 1, timescale: 1)
        player?.addPeriodicTimeObserver(forInterval: cmTime, queue: nil, using: { time in
            self.generateThumbnails(time: time)
        })
        // 定期监听
        let times: [NSValue] = [NSValue(time: CMTime(value: 5, timescale: 1)),
                                NSValue(time: CMTime(value: 10, timescale: 1)),
                                NSValue(time: CMTime(value: 15, timescale: 1))]
        player?.addBoundaryTimeObserver(forTimes: times, queue: nil, using: {
            print("边界监听")
        })
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status",
           let item: AVPlayerItem = object as? AVPlayerItem {
            if item.status == .readyToPlay {
                print("准备播放")
            }
        }
    }

    
    
    @IBAction func playEvent(_ sender: Any) {
        player?.play()
        // 字幕
        mediaSelectionOptions()
    }
    
    
    @IBAction func pauseEvent(_ sender: Any) {
        player?.pause()
    }
    
    
    
    /// 缩略图
    @objc dynamic func generateThumbnails(time: CMTime) {
        guard let _asset = asset else {
            return
        }
        imagegenrator = AVAssetImageGenerator.init(asset: _asset)
        imagegenrator?.maximumSize = CGSize(width: 70, height: 70)
        var actualTime = CMTimeMake(value: 0, timescale: 0)
        do {
            let imageRef: CGImage? = try imagegenrator?.copyCGImage(at: time, actualTime: &actualTime)
            self.generatorView.layer.contents = imageRef
        } catch{
            
        }
    }
    
    /// 字幕
    @objc dynamic func mediaSelectionOptions() {
        guard let mediaSelectionOptionsList = asset?.availableMediaCharacteristicsWithMediaSelectionOptions else {
            return
        }
        for item in mediaSelectionOptionsList {
            let group = asset?.mediaSelectionGroup(forMediaCharacteristic: item)
            print("forMediaCharacteristic:\(item)")
            guard let options: [AVMediaSelectionOption] = group?.options else {
                return
            }
            for option in options {
                print("option:\(option.displayName)")
            }
        }
        
        
    }
    
    
}
