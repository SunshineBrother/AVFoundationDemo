//
//  kViewController.swift
//  AVFoundationDemo
//
//  Created by sunshine on 2023/3/14.
//

import AVFoundation
import AVKit
import Photos
import UIKit

let WIDTH: CGFloat = UIScreen.main.bounds.width
let HEIGHT: CGFloat = UIScreen.main.bounds.height
let TopSpaceHigh = 100
let bottomSafeHeight: CGFloat = 100
class kViewController: UIViewController, AVCapturePhotoCaptureDelegate, AVCaptureFileOutputRecordingDelegate {
    var device: AVCaptureDevice! // 获取设备:如摄像头
    
    var input: AVCaptureDeviceInput! // 输入流
    
    var photoOutput: AVCapturePhotoOutput! // 照片输出流,（ios10之前用的AVCaptureStillImageOutput，现在已经弃用）
    var movieoutput: AVCaptureMovieFileOutput! // 录像输出流
    
    var session: AVCaptureSession! // 会话,协调着intput到output的数据传输,input和output的桥梁
    
    var previewLayer: AVCaptureVideoPreviewLayer! // 图像预览层，实时显示捕获的图像
    
    var setting: AVCapturePhotoSettings? // 图像设置，
    var photoButton: UIButton? // 拍照按钮
    var imageView: UIImageView? // 拍照后的成像
    var image: UIImage? // 拍照后的成像
    var isJurisdiction: Bool? // 是否获取了拍照标示
    var flashBtn: UIButton? // 闪光灯按钮
    
    var videoConnection: AVCaptureConnection? // 捕获链接
    
    var isflash: Bool = false // 控制闪光灯开关
    
    // 保存所有的录像片段数组
    var videoAssets = [AVAsset]()
    // 保存所有的录像片段url数组
    var assetURLs = [String]()
    // 单独录像片段的index索引
    var appendix: Int32 = 1
    
    // 最大允许的录制时间（秒）
    let totalSeconds: Float64 = 15.00
    // 每秒帧数
    var framesPerSecond: Int32 = 30
    // 剩余时间
    var remainingTime: TimeInterval = 15.0
    
    // 表示是否停止录像
    var stopRecording: Bool = false
    // 剩余时间计时器
    var timer: Timer?
    // 进度条计时器
    var progressBarTimer: Timer?
    // 进度条计时器时间间隔
    var incInterval: TimeInterval = 0.05
    // 进度条
    var progressBar: UIView = .init()
    // 当前进度条终点位置
    var oldX: CGFloat = 0
    // 录制、保存按钮
    var recordButton, saveButton: UIButton!
    // 视频片段合并后的url
    var outputURL: NSURL?
    
    override func viewDidLoad() {
        customCamera() // 自定义相机
        customUI() // 自定义相机按钮
    }
    
    //    // MARK: - 检查相机权限
    
    //    func canUserCamear() -> Bool {
    
    //        //获取相册权限
    //        PHPhotoLibrary.requestAuthorization({ (status) in
    //            switch status {
    
    //            case .notDetermined:
    //
    //                break
    
    //            case .restricted://此应用程序没有被授权访问的照片数据
    
    //                break
    //            case .denied://用户已经明确否认了这一照片数据的应用程序访问
    //                break
    //            case .authorized://已经有权限
    //                break
    //            default:
    //                break
    //            }
    //           return true
    //    }
    
    // MARK: 初始化自定义相机
    
    func customCamera() {
        // 创建摄像头
        guard let devices = AVCaptureDevice.devices(for: AVMediaType.video) as? [AVCaptureDevice] else { return } // 初始化摄像头设备
        guard let devic = devices.filter({ $0.position == .back }).first else { return }
        device = devic
        // 照片输出设置x
        setting = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        // 用输入设备初始化输入
        input = try? AVCaptureDeviceInput(device: device)
        // 照片输出流初始化
        photoOutput = AVCapturePhotoOutput()
        
        // 录像输出流初始化
        movieoutput = AVCaptureMovieFileOutput()
        // 生成会话
        session = AVCaptureSession()
        
        // 输出画面质量
        if session.canSetSessionPreset(AVCaptureSession.Preset(rawValue: "AVCaptureSessionPreset1280x720")) {
            session.sessionPreset = AVCaptureSession.Preset(rawValue: "AVCaptureSessionPreset1280x720")
        }
        
        // 添加摄像头输入到会话中
        if session.canAddInput(input) {
            session.addInput(input)
        }
        // 添加一个音频输入设备
        let audioCaptureDevice = AVCaptureDevice.devices(for: AVMediaType.audio).first
        let audioInput = try? AVCaptureDeviceInput(device: audioCaptureDevice!)
        if session.canAddInput(audioInput!) {
            session.canAddInput(audioInput!)
        }
 
        // 添加照片输出流到会话中
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }
        
        // 添加视频输出流到会话中
        if session.canAddOutput(movieoutput) {
            session.addOutput(movieoutput)
        }
       
        // 使用self.session，初始化预览层，self.session负责驱动input进行信息的采集，layer负责把图像渲染显示
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = CGRect(x: 0, y: 0, width: WIDTH, height: HEIGHT)
        previewLayer.videoGravity = AVLayerVideoGravity(rawValue: "AVLayerVideoGravityResizeAspectFill")
        view.layer.addSublayer(previewLayer)
        
        // //自动白平衡
        //  if device.isWhiteBalanceModeSupported(.autoWhiteBalance) {
        //  device.whiteBalanceMode = .autoWhiteBalance
        //   }
        // device.unlockForConfiguration()//解锁
        //    }
        
        setupButton()
        // 启动
        DispatchQueue(label: "startRunning").async { [weak self] in
            self?.session.startRunning()
        }
        
        // 添加进度条
        progressBar.frame = CGRect(x: 0, y: 0, width: view.bounds.width,
                                   height: view.bounds.height * 0.1)
        progressBar.backgroundColor = UIColor(red: 4, green: 3, blue: 3, alpha: 0.5)
        view.addSubview(progressBar)
    }
    
    // MARK: 添加自定义按钮等UI
    func customUI() {
        // 前后摄像头切换
        let changeBtn = UIButton()
        changeBtn.frame = CGRect(x: Int(WIDTH - 50), y: TopSpaceHigh, width: 40, height: 40)
        changeBtn.setImage(UIImage(named: "btn_list_takephotos"), for: UIControl.State.normal)
        changeBtn.addTarget(self, action: #selector(changeCamera), for: .touchUpInside)
        view.addSubview(changeBtn)
        // 拍照按钮
        photoButton = UIButton(type: .custom)
        photoButton?.frame = CGRect(x: WIDTH * 1/2.0 - 30, y: HEIGHT - 100, width: 60, height: 60)
        photoButton?.setImage(UIImage(named: "icon_shot_sel"), for: .normal)
        photoButton?.addTarget(self, action: #selector(shutterCamera), for: .touchUpInside)
        view.addSubview(photoButton!)
        
        // 闪光灯按钮
        flashBtn = UIButton()
        flashBtn?.frame = CGRect(x: 10, y: TopSpaceHigh, width: 40, height: 40)
        flashBtn?.addTarget(self, action: #selector(flashAction), for: .touchUpInside)
        flashBtn?.setImage(UIImage(named: "icon_flash on_sel"), for: UIControl.State.normal)
        view.addSubview(flashBtn!)
        
        // 取消
        let cancelBtn = UIButton()
        cancelBtn.frame = CGRect(x: 10, y: HEIGHT - 100, width: 60, height: 60)
        cancelBtn.setTitle("取消", for: .normal)
        cancelBtn.addTarget(self, action: #selector(cancelActin), for: .touchUpInside)
        view.addSubview(cancelBtn)
    }
    
    // MARK: 前后摄像头更改事件

    @objc func changeCamera() {
        // 1.获取摄像头，并且改变原有的摄像头
        guard var position = input?.device.position else { return }
        
        // 获取当前应该显示的镜头
        position = position == .front ? .back : .front
        // 2.重新创建输入设备对象
        // 创建新的device
        let devices = AVCaptureDevice.devices(for: AVMediaType.video) as [AVCaptureDevice]
        for devic in devices {
            if devic.position == position {
                device = devic
            }
        }
        
        // input
        guard let videoInput = try? AVCaptureDeviceInput(device: device!) else { return }
        // 3. 改变会话的配置前一定要先开启配置，配置完成后提交配置改变
        session.beginConfiguration()
        // 移除原有设备输入对象
        session.removeInput(input)
        // 添加新的输入对象
        // 添加输入到会话中
        if session.canAddInput(videoInput) {
            session.addInput(videoInput)
        }
        // 提交会话配置
        session.commitConfiguration()
        // 切换
        input = videoInput
    }
    
    // MARK: 拍照按钮点击事件

    @objc func shutterCamera() {
        // 拍照
        videoConnection = photoOutput.connection(with: AVMediaType.video)
        if videoConnection == nil {
            print("take photo failed!")
            return
        }
 
        photoOutput.capturePhoto(with: setting!, delegate: self)
    }
    
    // MARK: 闪光灯开关

    @objc func flashAction() {
        isflash = !isflash // 改变闪光灯
        try? device.lockForConfiguration()
        if isflash { // 开启
            // 开启闪光灯方法一     level取值0-1
            //    guard ((try? device.setTorchModeOn(level: 0.5)) != nil) else {
            //        print("闪光灯开启出错")
            //        return
            //    }
            device.torchMode = .on // 开启闪光灯方法二
            
        } else { // 关闭
            if device.hasTorch {
                device.torchMode = .off // 关闭闪光灯
            }
        }
        device.unlockForConfiguration()
    }
    
    // MARK: 取消按钮

    @objc func cancelActin() {
        imageView?.removeFromSuperview()
        if !session.isRunning {
            session.startRunning()
        }
    }
   
    //    //拍照完成输出--ios10新的
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        session.stopRunning() // 停止
        let data = photo.fileDataRepresentation()
        let image = UIImage(data: data!)
        print("\(photo.metadata)")
    }
    
    // 创建按钮
    func setupButton() {
        // 创建录制按钮
       
        recordButton = UIButton(frame: CGRect(x: 0, y: 0, width: 120, height: 50))
        recordButton.backgroundColor = UIColor.red
        recordButton.layer.masksToBounds = true
        recordButton.setTitle("按住录像", for: UIControl.State.normal)
        recordButton.layer.cornerRadius = 20.0
        recordButton.layer.position = CGPoint(x: Int(view.bounds.width/2),
                                              y: Int(view.bounds.height) - Int(bottomSafeHeight) - 150)
        recordButton.addTarget(self, action: #selector(onTouchDownRecordButton),
                               for: .touchDown)
        recordButton.addTarget(self, action: #selector(onTouchUpRecordButton),
                               for: .touchUpInside)
        
        // 创建保存按钮
        saveButton = UIButton(frame: CGRect(x: 0, y: 0, width: 70, height: 50))
      
        saveButton.backgroundColor = UIColor.gray
        saveButton.layer.masksToBounds = true
        saveButton.setTitle("保存", for: UIControl.State.normal)
        saveButton.layer.cornerRadius = 20.0
        
        saveButton.layer.position = CGPoint(x: Int(view.bounds.width) - 60,
                                            y: Int(view.bounds.height) - Int(bottomSafeHeight) - 150)
        saveButton.addTarget(self, action: #selector(onClickStopButton),
                             for: .touchUpInside)
        
        // 回看按钮
        let backlookBtn = UIButton(frame: CGRect(x: 100, y: 200, width: 100, height: 50))
        backlookBtn.setTitle("回看按钮", for: UIControl.State.normal)
        backlookBtn.addTarget(self, action: #selector(reviewRecord), for: .touchUpInside)
        view.addSubview(backlookBtn)
        // 添加按钮到视图上
        view.addSubview(recordButton)
        view.addSubview(saveButton)
    }
    
    // 按下录制按钮，开始录制片段
    @objc func onTouchDownRecordButton(sender: UIButton) {
        if !stopRecording {
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                            .userDomainMask, true)
            let documentsDirectory = paths[0] as String
            let outputFilePath = "\(documentsDirectory)/output-\(appendix).mov"
            appendix += 1
            let outputURL = NSURL(fileURLWithPath: outputFilePath)
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: outputFilePath) {
                do {
                    try fileManager.removeItem(atPath: outputFilePath)
                } catch _ {}
            }
            print("开始录制：\(outputFilePath) ")
            movieoutput.startRecording(to: outputURL as URL, recordingDelegate: self as AVCaptureFileOutputRecordingDelegate)
        }
    }
    
    // 松开录制按钮，停止录制片段
    @objc func onTouchUpRecordButton(sender: UIButton) {
        if !stopRecording {
            timer?.invalidate()
            progressBarTimer?.invalidate()
            movieoutput.stopRecording()
        }
    }
    
    // 录像开始的代理方法
    func captureOutput(captureOutput: AVCaptureFileOutput!,
                       didStartRecordingToOutputFileAtURL fileURL: NSURL!,
                       fromConnections connections: [AnyObject]!)
    {
        startProgressBarTimer()
        startTimer()
    }
    
    // 录像结束的代理方法
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
//        //直接保存单个视频片段
//        saveVideoDerectlyToAblum(outputFileURL: outputFileURL)
        
        // ******下面是合成处理多个视频片段
        let asset = AVURLAsset(url: outputFileURL as URL, options: nil)
        var duration: TimeInterval = 0.0
        duration = CMTimeGetSeconds(asset.duration)
        print("生成视频片段002：\(asset)---\(outputFileURL)")
        videoAssets.append(asset) // 所有录像片段数组
        assetURLs.append(outputFileURL.path) /// 录像的片段url存到数组
        remainingTime = remainingTime - duration
 
        // 到达允许最大录制时间，自动合并视频
        if remainingTime <= 0 {
            mergeVideos() // 合并视频
        }
    }
    
    // 剩余时间计时器
    func startTimer() {
        timer = Timer(timeInterval: remainingTime, target: self,
                      selector: #selector(timeout), userInfo: nil,
                      repeats: true)
        RunLoop.current.add(timer!, forMode: RunLoop.Mode.default)
    }
    
    // 录制时间达到最大时间
    @objc func timeout() {
        stopRecording = true
        print("时间到。")
        movieoutput.stopRecording()
        timer?.invalidate()
        progressBarTimer?.invalidate()
    }
    
    // 进度条计时器
    func startProgressBarTimer() {
        progressBarTimer = Timer(timeInterval: incInterval, target: self,
                                 selector: #selector(progress),
                                 userInfo: nil, repeats: true)
        RunLoop.current.add(progressBarTimer!,
                            forMode: RunLoop.Mode.default)
    }
    
    // 修改进度条进度
    @objc func progress() {
        let progressProportion = CGFloat(incInterval/totalSeconds)
        let progressInc = UIView()
        progressInc.backgroundColor = UIColor(red: 55/255, green: 186/255, blue: 89/255,
                                              alpha: 1)
        let newWidth = progressBar.frame.width * progressProportion
        progressInc.frame = CGRect(x: oldX, y: 0, width: newWidth,
                                   height: progressBar.frame.height)
        oldX = oldX + newWidth
        progressBar.addSubview(progressInc)
    }
    
    // 保存按钮点击
    @objc func onClickStopButton(sender: UIButton) {
        mergeVideos()
    }
    
    // 合并视频片段
    func mergeVideos() {
        let duration = totalSeconds
        let composition = AVMutableComposition()
        // 合并视频、音频轨道
        let firstTrack = composition.addMutableTrack(
            withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid) // 获取工程文件中的视频轨道
        let audioTrack = composition.addMutableTrack(
            withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid) // 获取工程文件中的音频轨道
        var insertTime = CMTime.zero
        for asset in videoAssets {
            print("合并视频片段001：\(asset)")
            let videoArr = asset.tracks(withMediaType: AVMediaType.video) // 从素材中获取视频轨道
            do {
                try firstTrack!.insertTimeRange(
                    CMTimeRangeMake(start: CMTime.zero, duration: asset.duration),
                    of: videoArr[0],
                    at: insertTime)
            } catch _ {}
            
            let audioArr = asset.tracks(withMediaType: AVMediaType.audio) // 从素材中获取音频轨道
            print("\(audioArr.count)-----\(videoArr.count)")
    
            insertTime = CMTimeAdd(insertTime, asset.duration)
        }
        // 旋转视频图像，防止90度颠倒
        firstTrack!.preferredTransform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2))
        
        // 定义最终生成的视频尺寸（矩形的）
        print("视频原始尺寸：", firstTrack!.naturalSize)
        let renderSize = CGSize(width: firstTrack!.naturalSize.height, height: firstTrack!.naturalSize.height)
        print("最终渲染尺寸：", renderSize)
        
        // 通过AVMutableVideoComposition实现视频的裁剪(矩形，截取正中心区域视频)
        let videoComposition = AVMutableVideoComposition()
        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: framesPerSecond)
        videoComposition.renderSize = renderSize
        
        // 视频组合指令
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(
            start: CMTime.zero, duration: CMTimeMakeWithSeconds(Float64(duration), preferredTimescale: framesPerSecond))
 
        let transformer =
            AVMutableVideoCompositionLayerInstruction(assetTrack: firstTrack!)
 
        instruction.layerInstructions = [transformer] // 视频涂层指令集合
        videoComposition.instructions = [instruction]
        
        // 获取合并后的视频路径
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                                .userDomainMask, true)[0]
        let destinationPath = documentsPath + "/mergeVideo-\(arc4random() % 1000).mov"
        print("合并后的视频002：\(destinationPath)")
        let videoPath = NSURL(fileURLWithPath: destinationPath as String)
        let exporter = AVAssetExportSession(asset: composition,
                                            presetName: AVAssetExportPresetHighestQuality)!
        exporter.outputURL = videoPath as URL
        exporter.outputFileType = AVFileType.mov
        exporter.videoComposition = videoComposition // 设置videoComposition
        exporter.shouldOptimizeForNetworkUse = true
        exporter.timeRange = CMTimeRangeMake(
            start: CMTime.zero, duration: CMTimeMakeWithSeconds(Float64(duration), preferredTimescale: framesPerSecond))
        exporter.exportAsynchronously(completionHandler: {
            print("导出状态\(exporter.status)")
            // 将合并后的视频保存到相册
            self.exportDidFinish(session: exporter)
        })
    }
    
    // 将合并后的视频保存到相册
    func exportDidFinish(session: AVAssetExportSession) {
        print("视频合并成功！")
        weak var weakSelf = self
        outputURL = session.outputURL! as NSURL
        // 将录制好的录像保存到照片库中
    
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: weakSelf!.outputURL! as URL) // 保存录像到系统相册
        }, completionHandler: { (_: Bool, _: Error?) in
            DispatchQueue.main.async {
                // 重置参数，吧碎片视频全部删除
                self.reset()
                
                // 弹出提示框
                let alertController = UIAlertController(title: "视频保存成功",
                                                        message: "是否需要回看录像？", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "确定", style: .default, handler: {
                    _ in
                    // 录像回看
                    weakSelf?.reviewRecord()
                })
                let cancelAction = UIAlertAction(title: "取消", style: .cancel,
                                                 handler: nil)
                alertController.addAction(okAction)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true,
                             completion: nil)
            }
        })
    }
    
    // 视频保存成功，重置各个参数，准备新视频录制
    func reset() {
        // 删除视频片段
        for assetURL in assetURLs {
            if FileManager.default.fileExists(atPath: assetURL) {
                do {
                    try FileManager.default.removeItem(atPath: assetURL)
                } catch _ {}
                print("删除视频片段: \(assetURL)")
            }
        }
        
        // 进度条还原
        let subviews = progressBar.subviews
        for subview in subviews {
            subview.removeFromSuperview()
        }
        
        // 各个参数还原
        videoAssets.removeAll(keepingCapacity: false)
        assetURLs.removeAll(keepingCapacity: false)
        appendix = 1
        oldX = 0
        stopRecording = false
        remainingTime = totalSeconds
    }
    
    // 录像回看
    @objc func reviewRecord() {
        print("录像回放---\(String(describing: outputURL))")
        // 视频播放现在两种方式：AVPlayer:自定义UI，目前大多数的第三方播放软件都是基于这个进行封装
//        AVPlayerViewController: 封装好的AVPlayer，可以直接作为视图控制器弹出播放，也可以使用添加view方式使用，不可以自定义UI。
        
        // ********通过AVPlayer播放视屏
        // 定义一个视频播放器方式一，这个是直接创建，不能设置资源的相关配置
//        let player = AVPlayer(url: outputURL as URL)
//        //创建媒体资源管理对象
//        let palyerItem:AVPlayerItem = AVPlayerItem(url: outputURL! as URL)
//        //创建AVplayer：负责视频播放，方式二，可以设置资源的相关配置，更灵活
//        let player:AVPlayer = AVPlayer.init(playerItem: palyerItem)
//        player.rate = 1.0//播放速度 播放前设置
//        //创建显示视频的图层
//        let playerLayer = AVPlayerLayer.init(player: player)
//        playerLayer.videoGravity = .resizeAspect
//        playerLayer.frame = CGRect.init(x: 100, y: 100, width: 200, height: 200)
//        playerLayer.backgroundColor=UIColor.blue.cgColor
//        self.view.layer.addSublayer(playerLayer)
//        //播放
//        player.play()
        // 定义一个视频播放器，通过本地文件路径初始化
        let player = AVPlayer(url: outputURL! as URL)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
   
    // 直接保存录像到照片库，未经过合成
    func saveVideoDerectlyToAblum(outputFileURL: URL) {
        weak var weakSelf = self
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL as URL) // 保存录像到系统相册
        }, completionHandler: { (_: Bool, _: Error?) in
            DispatchQueue.main.async {
                // 重置参数，吧碎片视频全部删除
                weakSelf!.reset()
                
                // 弹出提示框
                let alertController = UIAlertController(title: "视频保存成功",
                                                        message: "是否需要回看录像？", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "确定", style: .default, handler: {
                    _ in
               
                })
                let cancelAction = UIAlertAction(title: "取消", style: .cancel,
                                                 handler: nil)
                alertController.addAction(okAction)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true,
                             completion: nil)
            }
        })
    }
}
