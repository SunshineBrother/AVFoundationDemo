# AVFoundationDemo
音视频研究

## 001-AVFoundation初识：语音阅读器

语音阅读我们可以基于`AVSpeechSynthesizer`这个类实现

```
        // 语音内容实例
        let utterance = AVSpeechUtterance(string: text)
        // 语种
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        // 播放
        synthesizer.speak(utterance)
```



## 002-AVFoundation音频播放器 

### 音频会话分类

![image-20221102101810851](https://images-blogs.oss-cn-hangzhou.aliyuncs.com/image/image-20221102101810851.png)

当我们选择音频会话的时候，我们需要考虑一些核心行为问题

- 1、音频播放是核心功能还是次要功能
- 2、音频是否可以和背景声音混合
- 3、是否需要捕捉音频输入进行录制或者网络发送音频



在使用之前，我们必须先要配置音频会话

```
    // 配置音频会话
    func configAudioPlayer() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord)
        } catch let error {
            print("Category Error: \(error)")
        }
        do {
            try session.setActive(true)
        } catch let error {
            print("Activation Error: \(error)")
        }
        
    }
```

### 使用AVAudioPlayer播放音频

**初始化**

```
let audio = try AVAudioPlayer(contentsOf: fileUrl)
/// 准备播放，调用方法是可选的，当调用play的时会隐形激活，不过在创建时调用会降低延迟
audio.prepareToPlay()
```

**播放**

```
audioPlayer.play()
```

**暂停**

```
audioPlayer.pause()
```

**停止**

```
audioPlayer.stop()
```

**`pause`和`stop`区别**

`stop`方法会撤销调用`prepareToPlay`时所做的设置，但是`pause`不会



### 处理中断事件

- 1、设备运行另一个播放程序时
- 2、音频处于播放状态，收到电话

这些情况会造成音频播放中断，但是我们可以通过通知来监听中断

```
        // 中断通知
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption(notification:)),
            name: AVAudioSession.routeChangeNotification,
            object: AVAudioSession.sharedInstance)
       
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
```



### 线路改变影响

当我们插拔耳机的时候，也会影响音频播放。默认情况下，在拔出耳机的时候音频处于静音状态

```
        // 对线路改变处理
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRouteChange(notification:)),
            name: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance)
            
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
```

 

## 003-AVAudioRecorder录音

AVAudioRecorder创建实例时需要为其提供数据的一些信息

- 1、用于表示音频流写入文件的本地URL
- 2、用于配置录音回话的键值对

```
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
```



### 1、音频格式

AVFormatIDKey定义了内容的音频格式

- 1、kAudioFormatLinearPCM：未压缩的写入文件
- 2、kAudioFormatMPEG4AAC：压缩，但是音频质量比较高
- 3、kAudioFormatAppleIMA4：压缩，但是音频质量比较高
- 4、kAudioFormatAppleLossless
- 5、kAudioFormatiLBC
- 6、kAudioFormatULaw

指定的音频格式一定要跟URL参数定义的文件兼容，不然会写入失败



### 2、采样率

AVSampleRateKey用于定义录音器的采样率，采样率定义输入音频每一秒内的采样数量

- 8 KHZ 粗颗粒，AM广播类相关的录制效果，文件较小
- 44.1 KHZ 会得到非常高质量的内容
- 16 KHZ
- 22050 HZ



### 3、通道数

AVNumberOfChannelsKey用于定义通道数

- 1：单通道
- 2：立体录音效果

除非使用外部硬件进行录制，否则都是单通道



### 4、录音质量

AVEncoderAudioQualityKey

```
public enum AVAudioQuality : Int, @unchecked Sendable {
    case min = 0
    case low = 32
    case medium = 64
    case high = 96
    case max = 127
}

```



### 5、录音时间

我们可以通过`audioRecorder.currentTime`获取录音时间，但是如果我们要实时显示录音时间，我们需要写一个定时器

```
        // 定时器
    func startTimer() {
        timer?.invalidate()
        timer = Timer(timeInterval: 0.5, target: self, selector: #selector(upDateCurrentTime), userInfo: nil, repeats: true)
        if let timer = self.timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
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
    }
```



### 6、Audio Metering

Audio Metering可以记录录音分贝





