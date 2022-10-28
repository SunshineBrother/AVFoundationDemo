//
//  JHSpeechController.swift
//  AVFoundationDemo
//
//  Created by sunshine on 2022/10/28.
//

import UIKit
import AVFoundation
class JHAudioPlayerController: UIViewController {
    var audioPlayer: AVAudioPlayer!
    /// 是否正在播放
    var isPlaying = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
         
        audioPlayer = audioPlayer(file: "Wonderful Tonight", withExtension: "wav")
        // 获取音频文件的时长(秒)
        guard let fileUrl = Bundle.main.url(forResource: "Wonderful Tonight", withExtension: "wav") else { return }
        let time = durationWithVideo(fileUrl: fileUrl)
        print("获取音频文件的时长:\(time)")
    }
 

    @IBAction func startEvent(_ sender: Any) {
        audioPlayer.play()
    }
    
    @IBAction func pauseEvent(_ sender: Any) {
        audioPlayer.pause()
    }
    
    
    @IBAction func stopEvent(_ sender: Any) {
        audioPlayer.stop()
    }
    
}



extension JHAudioPlayerController {
    /// 创建一个音频播放器
    /// - Parameters:
    ///   - file: 文件名
    ///   - withExtension: 文件格式
    func audioPlayer(file: String, withExtension: String) -> AVAudioPlayer? {
        guard let fileUrl = Bundle.main.url(forResource: file, withExtension: withExtension) else { return nil }
        do {
            let audio = try AVAudioPlayer(contentsOf: fileUrl)
            /// 准备播放，调用方法是可选的，当调用play的时会隐形激活，不过在创建时调用会降低延迟
            audio.prepareToPlay()
            return audio
        } catch let error {
            print("error:\(error)")
        }
        return nil
    }
    
    /// 播放
    func play() {
        guard isPlaying == false else {
            return
        }
        isPlaying = true
        audioPlayer.play()
    }
    
    /// 暂停
    func pause() {
        guard isPlaying else {
            return
        }
        isPlaying = false
        audioPlayer.pause()
    }
    /// 停止播放
    func stop() {
        guard isPlaying else {
            return
        }
        isPlaying = false
        audioPlayer.stop()
    }
    
    /// 调整播放速度
    func adjustRate(_ rate: Float) {
        audioPlayer.rate = rate
    }
    
    /// 获取音频文件的时长(秒)
    func durationWithVideo(fileUrl: URL) -> Int {
        let audioAsset = AVURLAsset.init(url: fileUrl)
        let durationTime = audioAsset.duration
        let resultTime  = CMTimeGetSeconds(durationTime)
        return Int(resultTime)
    }
    
}
