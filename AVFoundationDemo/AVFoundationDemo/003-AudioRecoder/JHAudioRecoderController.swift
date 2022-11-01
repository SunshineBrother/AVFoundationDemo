//
//  JHAudioRecoderController.swift
//  AVFoundationDemo
//
//  Created by sunshine on 2022/11/1.
//

import UIKit
import AVFoundation
var count = 0
let recoder = "JHAudioRecoderController"
class JHAudioRecoderController: UIViewController {
    // 时间
    @IBOutlet weak var timeLabel: UILabel!
    // tableView
    @IBOutlet weak var tableView: UITableView!
    // 播放
    var audioPlayer: AVAudioPlayer?
    // 录音
    var audioRecorder: AVAudioRecorder?
    
    // 定时器
    var timer: Timer?
    deinit {
        self.audioRecorder = nil
        print("销毁：JHAudioRecoderController")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            if granted {
                print("已授权")
            } else {
                print("未授权")
            }
        }

        initAudioRecorder()
        if let num: Int = UserDefaults.standard.object(forKey: recoder) as? Int {
            count = num
        }
    }

    // 初始化录音设备
    func initAudioRecorder() {
        let tempDir = NSTemporaryDirectory()
        let filePath = tempDir + "AudioRecoder.caf"
        let setting = [AVFormatIDKey: kAudioFormatAppleIMA4,
                     AVSampleRateKey: 44100.0,
               AVNumberOfChannelsKey:1,
            AVEncoderBitDepthHintKey:16,
            AVEncoderAudioQualityKey:AVAudioQuality.medium
        ] as [String : Any]
        do {
            audioRecorder = try AVAudioRecorder.init(url: URL(fileURLWithPath: filePath), settings: setting)
            audioRecorder?.prepareToRecord()
        } catch let error {
            print("error:\(error)")
        }
         
    }
     
    // 开始录音
    @IBAction func startEVent(_ sender: Any) {
        audioRecorder?.record()
        startTimer()
    }
    
    
    
    // 暂停
    @IBAction func pauseEvent(_ sender: Any) {
        audioRecorder?.pause()
    }
    
    // 结束
    @IBAction func endEvent(_ sender: Any) {
        audioRecorder?.stop()
        count += 1
        UserDefaults.standard.set(count, forKey: recoder)
        saveRecoder(name: "录音")
        timer?.invalidate()
        timeLabel.text = "00:00:00"
    }
    
    
    
    // 定时器
    func startTimer() {
        timer?.invalidate()
        timer = Timer(timeInterval: 0.5, target: self, selector: #selector(upDateCurrentTime), userInfo: nil, repeats: true)
        if let timer = self.timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
}
// MARK: - 录音 -
extension JHAudioRecoderController {
    // 记录时间
    @objc
    func upDateCurrentTime() {
        guard let audioRecorder = self.audioRecorder else {
            return
        }
        let time: Int = Int(audioRecorder.currentTime)
        let hours: Int = Int(time / 3600)
        let hoursText = hours > 9 ? "\(hours)" : "0\(hours)"
        let minutes: Int = Int(time / 60) % 60
        let minutesText = minutes > 9 ? "\(minutes)" : "0\(minutes)"
        let seconds: Int = Int(time % 60)
        let secondsText = seconds > 9 ? "\(seconds)" : "0\(seconds)"
        timeLabel.text = "\(hoursText):\(minutesText):\(secondsText)"
    }
    
    // 保存
    func saveRecoder(name withName: String) {
        guard let audioRecorder = self.audioRecorder else {
            return
        }
        let fileName = withName + "-\(count)" + ".caf"
        let docsDir = MyFileManager.share.getDocumentsPath()
        let destPath = docsDir + "/" + fileName
        let srcUrl = audioRecorder.url
        let destUrl = URL(fileURLWithPath: destPath)
        print("destUrl-->:\(destUrl)")
        do {
            try FileManager.default.copyItem(at: srcUrl, to: destUrl)
        } catch let error {
            print("error:\(error)")
        }
    }
    
 
}

// MARK: - 播放 -
extension JHAudioRecoderController {
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
}
