//
//  MYAssetExportController.swift
//  AVFoundationDemo
//
//  Created by sunshine on 2023/3/15.
//

import UIKit
import AVFoundation

class MYAssetExportController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

 
    @IBAction func exportEvent1(_ sender: Any) {
        guard let url = Bundle.main.url(forResource: "sample-mp4-file", withExtension: ".mp4") else {
            return
        }
        let dateTime = Date().getCurrentTimeMillion()
        let filePath = MyFileManager.share.getFile("\(dateTime).mp4")
        let asset = AVAsset(url: url)
        exportAsset(asset: asset, filePath: filePath)
    }
    
    
    @IBAction func exportEvent2(_ sender: Any) {
    }
    
    /// 视频导出
    func exportAsset(asset: AVAsset, filePath: String) {
        // 需要一个50s的音频资源
        let assetTime = asset.duration
        let duration = CMTimeGetSeconds(assetTime)
        guard duration > 50 else {
            assertionFailure("时间小于50s")
            return
        }
        
        // 获取第一个音轨
        let tracks = asset.tracks(withMediaType: .video)
        guard let track: AVAssetTrack = tracks.first else {
            assertionFailure("获取第一个音轨失败")
            return
        }
         
        // 创建导出会话
        guard let exportSession: AVAssetExportSession = AVAssetExportSession.init(asset: asset, presetName: AVAssetExportPresetMediumQuality) else {
            assertionFailure("导出会话失败")
            return
        }
        guard exportSession.supportedFileTypes.contains(AVFileType.mp4) else {
            assertionFailure("不支持该格式")
            return
        }
        // 创建一个裁剪范围 从30s开始的一个20s时长
        let startTime = CMTime(value: 30, timescale: 1)
        let stopTime = CMTime(value: 50, timescale: 1)
        let exportTimeRange = CMTimeRangeFromTimeToTime(start: startTime, end: stopTime)
        
        
        // 创建一个单出时间范围
        let startFadeInTime = startTime
        let endFadeInTime = CMTime(value: 40, timescale: 1)
        let fadeTimeRange = CMTimeRangeFromTimeToTime(start: startFadeInTime, end: endFadeInTime)

        // 创建音频混响
        let exportAudioMin = AVMutableAudioMix()
        let exportAudioMinInputParams = AVMutableAudioMixInputParameters.init(track: track)
        exportAudioMinInputParams.setVolumeRamp(fromStartVolume: 0.0, toEndVolume: 1.0, timeRange: fadeTimeRange)
        exportAudioMin.inputParameters = [exportAudioMinInputParams]
        
        // 配置导出会话
        guard let outputURL: URL = URL(string: filePath)  else {
            assertionFailure("输出url失败")
            return
        }
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileType.mp4
        exportSession.timeRange = exportTimeRange
        exportSession.audioMix = exportAudioMin
        
        
        // 执行导出
        exportSession.exportAsynchronously(completionHandler: {
            if exportSession.status == .completed {
                print("completed")
            } else if exportSession.status == .failed {
                print("failed")
            }
        })
        
    }

}
