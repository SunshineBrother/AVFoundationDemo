# AVFoundationDemo
## AV Foundation 简介

1991 年苹果推出了 Quick Time 首次将数字音频和数字视频展现在用户面前，Quick Time 架构在之后 20 年间给数字多媒体这一领域带来了变革，对教育、游戏、娱乐产业的发展影响巨大。但是随着时间的推移，缺点也越来越多，于是苹果推出了一个新的框架，它就是 AV Foundation

### 1、AV Foundation 层级

AV Foundation 是用于处理基于时间的视听数据的高级框架。下图展示了 AV Foundation 在整个体系中所处的角色。



![20171109145520063](https://images-blogs.oss-cn-hangzhou.aliyuncs.com/image/20171109145520063.png)



#### Core Audio

Core Audio 是由多个框架整合在一起的总称，为音频和 MIDI 内容的录制、播放和处理提供相应接口。Core Audio 也提供高层级的接口，比如通过 Audio Queue Services 框架，处理基本的音频播放和录音功能。同时也提供相对低层级的接口，尤其是 Audio Units 接口，提供了针对音频信号进行完全控制的功能，并通过 Audio Units 构建一些复杂的音频处理模式。如果想详细了解这一框架，建议阅读由 Chirs Adamson 和 Kevin Avila 撰写的 Learning Core Audio 一书。

#### Core Video

Core Video 是针对数字视频所提供的管道模式，为其相对的 Core Media 提供图片缓存和缓存池支持，提供了一个能够对数字视频逐帧访问的接口。该框架通过像素格式之间的转换并管理视频同步事项，使得复杂的工作得到了有效简化。

#### Core Media

Core Media 是 AV Foundation 所用到的低层级媒体管道的一部分。它提供针对音频样本和视频帧处理所需的低层级数据类型和接口。Core Media 还提供了基于 CMTime 数据类型的时基模型。

#### Core Animation

Core Animation 是合成及动画相关框架，主要功能就是提供美观、流畅的动画效果。对于视频内容的播放和视频捕获，AV Foundation 提供了硬件加速机制来对整个流程进行优化。AV Foundation 还可以利用 Core Animation 让开发者能够在视频编辑和播放过程中添加动画标题和图片效果。
 

### 2、AV Foundation 框架

AV Foundation 框架包含 100 多个类，如果将其按照功能单元进行分解，就会变得比较容易理解：

#### 音频播放和记录

如上图所示 AV Foundation 方框右上角有一个小方格被单独标记为音频专用类，这是由 AV Foundation 提供的关于音频处理的一些早期功能。AVAudioPlayer 和 AVAudioRecorder 可以提供一种更简单的整合音频播放和记录的功能，但是并不是 AV Foundation 用于播放和记录音频的唯一方式，却是最容易学习、功能最强大的方法。

#### 媒体文件检查

AV Foundation 提供检查正在使用的媒体文件的功能，比如是否可以用于回放，或者是否可以被编辑和导出，还可以获取内容持续时间，创建日期，首选播放音量。此外，该框架还基于 AVMetadataItem 类提供强大的元数据支持，这就允许开发者读写关于媒体资源的描述信息，比如唱片簿和艺术家信息。

#### 视频播放

这是 AV Foundation 提供的最常用的功能，这一部分的核心类是 AVPlayer 和 AVPlayerItem，这两个类让你能够对资源的播放进行控制。

#### 媒体捕捉

AV Foundation 提供了丰富的 API 集可以对摄像头等设备进行精密控制。摄像头捕捉的核心类是 AVCaptureSession，其作为所有活动的汇集点来接收摄像头设备由各路流发过来的视频和图片。

#### 媒体编辑

AV Foundation 可以将多个音频和视频资源进行组合，允许修改和编辑独立的媒体片段、随时修改音频文件的参数以及添加动画标题和场景切换效果。

#### 媒体处理

使用 AVAssetReader 和 AVAssetWritere 类来执行更高级的媒体处理任务，这些类可以直接访问视频帧和音频样本。
 

### 3、数字媒体简介

虽然我们处在一个数字化的时代，但是我们还是更习惯模拟信息的世界。我们看到的和听到的都是通过模拟信号传递给我们，信号的频率和强度是在不断变化的。但是数字世界的信号是离散的，由 1 和 0 组成。将模拟信号转换成我们能够存储并传输的数字信号，要进过模数转换，我们将这个过程称为采样（Sampling）。

#### 1、 数字媒体采样

对媒体内容数字化主要有两种方式。第一种称为时间采样，这种方法捕捉一个信号周期内的变化。第二种称为空间采样，一般用在图片数字化和其他可视化媒体内容数字化的过程中。空间采样包含对一幅图片在一定分辨率之下捕捉其亮度和色度，进而创建由该图片的像素点数据所构成的数字化结果。

#### 2、 数字媒体压缩 - 色彩二次抽样

与我们熟知的 RGB 类似，YUV 也是一种颜色编码方法，主要用于电视系统和模拟视频领域。Y 表示亮度，也就是灰度值，UV 表示色度，用于指定像素的颜色。图片所有细节都保存在 Y 通道中，如果除去 Y 信息，剩下的就是一幅灰度图片；如果除去 UV 信息，则变成黑白影像。因为我们的眼睛对亮度的敏感度要高于颜色，所以我们可以大幅减少存储在每个像素中的颜色信息，不至于图片的质量严重受损，这个减少颜色数据的过程就称为色彩二次抽样。

YUV 主流的采样方式有三种：4:4:4、4:2:2、4:2:0，这些值就是设备所使用的色彩二次抽样的参数。一些专业相机以 4:4:4 的参数捕捉图像，但大部分情况下使用 4:2:2 的方式进行拍摄，iPhone 摄像头通常以 4:2:0 方式进行拍摄。

- **4:4:4**
  - 每一个 Y 对应一组 UV 分量
    表示 UV 没有减少采样，即 Y、U、V 各占一个字节，加上 alpha 通道一个字节，共 4 字节，这个格式其实就是 24bpp 的 RGB 格式了。

- **4:2:2**
  - 每两个 Y 共用一组 UV 分量
  - 表示 U、V 分量采样减半，比如第一个像素采样 YU，第二个像素采样 YV，以此类推。

- **4:2:0**
  - 每四个 Y 共用一组 UV 分量
  - 这里的 0 意思是 U、V 分量隔行采样一次，比如第一行采样 4:2:0，第二行采样 4:0:2，以此类推。

 



![20171109145543813](https://images-blogs.oss-cn-hangzhou.aliyuncs.com/image/20171109145543813.jpeg)

####  3、数字媒体压缩 - 视频编解码器

AV Foundation 提供有限的编解码器集合，主要归结为 H.264 和 Apple ProRes

H.264 / MPEG-4 第十部分，或称 AVC（Advanced Video Coding，高级视频编码），是由 ITU-T（国际电信联盟 - 电信标准化部门） 群组之一的 VCEG（视频编码专家组） 与 MPEG（动态图像专家组，也就是 ISO / IEC（国际标准化组织 / 国际电工委员会）联合工作组）联合组成的 JVT（联合视频组）开发。因 ITU-T H.264 标准和 ISO / IEC MPEG-4 AVC 标准有相同的技术内容，所以被共同管理。

H.264 和其他形式的 MPEG 压缩一样，通过空间（帧内压缩）和时间（帧间压缩）两个维度缩小视频文件的尺寸。

##### 帧内压缩：

通过消除视频帧内的色彩和结构中的冗余信息来进行压缩，在不降低图片质量的情况下尽可能缩小尺寸，同 JEPG 压缩原理类似，通过这一过程创建的帧称为 I-frames

##### 帧间压缩

很多帧组合在一起作为一组图片（简称 GOP），对于 GOP 所存在的时间维度的冗余可以被消除。比如行驶的汽车，背景环境通常是固定的，就代表一个时间维度上的冗余，可以通过压缩方式消除。通过这一过程可创建的帧称为 B-frames 和 P-frames

> I 帧，关键帧。包含创建完整图片需要的所有数据，每组都会有一个 I 帧。由于它是一个独立帧，其尺寸最大，但是解压最快；
> P 帧，差别帧。表示这一帧和之前的 I 帧（或 P 帧）的差别，解码时需要用之前缓存的画面叠加上本帧定义的差别，生成最终画面；
> B 帧，双向帧。记录本帧和前后帧的差别。不仅要取得之前的缓存画面，还有解码之后的画面，通过前后画面与本帧数据的叠加取得最终的画面。几乎不需要存储空间，但是解压比较耗时，因为它依赖于周围其他的帧。

**H.264 一共有三种压缩标准，从低到高分别为：**

- 1、Baseline：低效，只支持 I / P 帧，一般用于低阶或需要额外容错的应用，比如视频通话、手机视频等
- 2、Main：主要，提供 I / P / B 帧，一般用于主流消费类电子产品规格如 mp4、PSP、iPod 等
- 3、High：高端，在 Main 的基础上增加了 8x8 内部预测、自定义量化、无损视频编码和更多的YUV 格式（如 4:4:4），用于蓝光影片，高清电视



##### Apple ProRes

Apple ProRes 被认为是一个中间件或中间层编解码器，其独立于帧的，意味着只有 I 帧可以被使用，其更适用于内容编辑上。但是 ProRes 编解码器只在 MAC OS 上可用，iOS 只能使用 H.264

ProRes 是有损编解码器，但是它具有最高的编解码质量。Apple ProRes 422 使用 4:2:2 色彩二次抽样和 10 位的采样深度。Apple ProRes 4444 使用 4:4:4:4 色彩二次抽样，4 个表示支持无损 alpha 通道和高达 12 位的采样深度。
 

#### 4、数字媒体压缩 - 音频编解码器

AAC（高级音频编码）是 H.264 标准相应的音频处理方式，目前是最主流的编码方式。这种格式比 MP3 格式有着显著的提升，可以在低比特率的前提下提供更高质量的音频，是 Web 上发布和传播中最理想的音频格式。而且相对 MP3 来说，AAC 没有来自证书和许可方面的限制。

注意：AV Foundation 和 Core Audio 支持 MP3 数据解码，但是不支持编码。
 

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





