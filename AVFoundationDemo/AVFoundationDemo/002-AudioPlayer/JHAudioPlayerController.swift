//
//  JHSpeechController.swift
//  AVFoundationDemo
//
//  Created by sunshine on 2022/10/28.
//

import AVFoundation
import UIKit
class JHAudioPlayerController: UIViewController {
    var audioPlayer: AVAudioPlayer!
    /// 是否正在播放
    var isPlaying = false
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
         
        audioPlayer = audioPlayer(file: "Wonderful Tonight", withExtension: "wav")
        // 中断通知
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption(notification:)),
            name: AVAudioSession.routeChangeNotification,
            object: AVAudioSession.sharedInstance)
        
        // 对线路改变处理
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRouteChange(notification:)),
            name: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance)
        
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

// MARK: - - 基础 --
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
        } catch {
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
        let audioAsset = AVURLAsset(url: fileUrl)
        let durationTime = audioAsset.duration
        let resultTime = CMTimeGetSeconds(durationTime)
        return Int(resultTime)
    }
}

// MARK: - - 中断通知 --
extension JHAudioPlayerController {
    // 中断通知
    @objc func handleInterruption(notification: NSNotification) {
        guard let userInfo = notification.userInfo, let reasonValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt else { return }
        switch reasonValue {
        case AVAudioSession.InterruptionType.began.rawValue: // Began
            if #available(iOS 10.3, *) {
                if #available(iOS 14.5, *) {
                    // iOS 14.5之后使用InterruptionReasonKey
                    let reasonKey = userInfo[AVAudioSessionInterruptionReasonKey] as! UInt
                    switch reasonKey {
                    case AVAudioSession.InterruptionReason.default.rawValue:
                        // 因为另一个会话被激活,音频中断
                        
                        break
                    case AVAudioSession.InterruptionReason.appWasSuspended.rawValue:
                        // 由于APP被系统挂起，音频中断。
                        break
                    case AVAudioSession.InterruptionReason.builtInMicMuted.rawValue:
                        // 音频因内置麦克风静音而中断(例如iPad智能关闭套iPad's Smart Folio关闭)
                        break
                    default: break
                    }
                    print(reasonKey)
                } else {
                    // iOS 10.3-14.5，InterruptionWasSuspendedKey为true表示中断是由于系统挂起，false是被另一音频打断
                    let suspendedNumber: NSNumber = userInfo[AVAudioSessionInterruptionWasSuspendedKey] as! NSNumber
                    print(suspendedNumber)
                }
            }
            
        case AVAudioSession.InterruptionType.ended.rawValue: // End
            let optionKey = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt
            if optionKey == AVAudioSession.InterruptionOptions.shouldResume.rawValue {
                // 指示另一个音频会话的中断已结束，本应用程序可以恢复音频。
            }
        default: break
        }
    }
    
    /// 线路改变通知
    @objc func handleRouteChange(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else { return }
        switch reason {
        case .newDeviceAvailable:
            // 插入耳机时关闭扬声器播放
            print("插入耳机时关闭扬声器播放")
        case .oldDeviceUnavailable:
            // 播出耳机时，开启扬声器播放
            print("播出耳机时，开启扬声器播放")
        default:
            break
        }
    }
    
    /// 是否插入耳机
    func hasHeadset() -> Bool {
        let audioSession = AVAudioSession.sharedInstance()
        let currentRoute = audioSession.currentRoute
     
        for output in currentRoute.outputs {
            if output.portType == AVAudioSession.Port.headphones {
                return true
            }
        }
        return false
    }
}
