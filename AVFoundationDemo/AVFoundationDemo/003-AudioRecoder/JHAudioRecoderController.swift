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

class AudioRecoderModel {
    var title = ""
    var path = ""
}

class JHAudioRecoderController: UIViewController, AVAudioRecorderDelegate {
    // 时间
    @IBOutlet weak var timeLabel: UILabel!
    // tableView
    @IBOutlet weak var tableView: UITableView!
    var dataList: [AudioRecoderModel] = Array()
    // 播放
    var audioPlayer: AVAudioPlayer?
    // 录音
    var audioRecorder: AVAudioRecorder?
    
    // 定时器
    var timer: Timer?
    deinit {
        self.audioRecorder = nil
        self.audioPlayer = nil
        self.timer = nil
        print("销毁：JHAudioRecoderController")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self]granted in
            if granted {
                print("已授权")
                self?.initAudioRecorder()
            } else {
                print("未授权")
            }
        }
 
        if let num: Int = UserDefaults.standard.object(forKey: recoder) as? Int {
            count = num
        }
  
        getData()
    }

    // 初始化录音设备
    func initAudioRecorder() {
        let tempDir = NSTemporaryDirectory()
        let filePath = tempDir + "AudioRecoder.caf"
        let setting = [AVFormatIDKey: kAudioFormatAppleIMA4,
                     AVSampleRateKey: 44100.0,
               AVNumberOfChannelsKey:1,
            AVEncoderBitDepthHintKey:16,
            AVEncoderAudioQualityKey:AVAudioQuality.medium.rawValue
        ] as [String : Any]
        do {
            audioRecorder = try AVAudioRecorder.init(url: URL(fileURLWithPath: filePath), settings: setting)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
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
        saveRecoder(name: "recoder")
        timer?.invalidate()
        timeLabel.text = "00:00:00"
        
        getData()
    }
    
    
    
    // 定时器
    func startTimer() {
        timer?.invalidate()
        timer = Timer(timeInterval: 0.5, target: self, selector: #selector(upDateCurrentTime), userInfo: nil, repeats: true)
        if let timer = self.timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
 
    func getData() {
        let docsDir = MyFileManager.share.getDocumentsPath()
        guard let subpaths = FileManager.default.subpaths(atPath: docsDir) else {
            return
        }
        for item in subpaths {
            let model = AudioRecoderModel()
            model.title = item
            model.path = docsDir + "/" + item
            dataList.append(model)
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }
    
}

extension JHAudioRecoderController {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print(#function)
    }

    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print(#function)
    }
    func audioRecorderBeginInterruption(_ recorder: AVAudioRecorder) {
        print(#function)
    }
    func audioRecorderEndInterruption(_ recorder: AVAudioRecorder, withOptions flags: Int) {
        print(#function)
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

extension JHAudioRecoderController: UITableViewDelegate, UITableViewDataSource {
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        
        let model = self.dataList[indexPath.row]
        cell?.textLabel?.text = model.title
        
        return cell!
    }
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = dataList[indexPath.row]
        audioPlayer = audioPlayerEvent(file: model.path)
        if audioPlayer?.isPlaying == true {
            audioPlayer?.stop()
        }
        audioPlayer?.play()
    }
}

// MARK: - 播放 -
extension JHAudioRecoderController {
    /// 创建一个音频播放器
    /// - Parameters:
    ///   - file: 文件名
    ///   - withExtension: 文件格式
    func audioPlayerEvent(file: String) -> AVAudioPlayer? {
        do {
            let audio = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: file))
            /// 准备播放，调用方法是可选的，当调用play的时会隐形激活，不过在创建时调用会降低延迟
            audio.prepareToPlay()
            return audio
        } catch {
            print("error:\(error)")
        }
        return nil
    }
      
}
