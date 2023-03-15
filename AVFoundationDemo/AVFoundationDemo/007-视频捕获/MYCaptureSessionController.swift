//
//  MYCaptureSessionController.swift
//  AVFoundationDemo
//
//  Created by sunshine on 2023/3/14.
// https://blog.csdn.net/u011146511/article/details/79447313

import AVFoundation
import AVKit
import Photos
import UIKit

class PreviewView: UIView {
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
    
}
class MYCaptureSessionController: UIViewController {
    var appendix = 100
    var captureSession: AVCaptureSession?
    /// 照片输出流
    var imageOutPut: AVCapturePhotoOutput?
    /// 录像输出流
    var movieoutput: AVCaptureMovieFileOutput?
    // 视频片段合并后的url
    var outputURL: NSURL?
    
    // 表示是否停止录像
    var startRecording: Bool = true
    // 保存所有的录像片段数组
    var videoAssets = [AVAsset]()
    // 保存所有的录像片段url数组
    var assetURLs = [String]()
    // 最大允许的录制时间（秒）
    let totalSeconds: Float64 = 15.00
    // 每秒帧数
    var framesPerSecond: Int32 = 30
    // 剩余时间
    var remainingTime: TimeInterval = 15.0
    
    @IBOutlet weak var bgView: UIView!
    let previewView = PreviewView()
    override func viewDidLoad() {
        super.viewDidLoad()
        bgView.addSubview(previewView)
        previewView.frame = bgView.bounds
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                self.setupCaptureSession()
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    if granted {
                        self.setupCaptureSession()
                    }
                }
            case .denied:
                return
            case .restricted:
                return
         default:
            break
        }
        
    }
    
    
    func setupCaptureSession() {
        // 1、创建捕捉会话
        let session = AVCaptureSession()
        self.captureSession = session
        session.beginConfiguration()
        // 2、捕捉设备
        guard let cameraDevice = AVCaptureDevice.default(for: .video) else { return }
        do {
            // 3、捕捉设备输入
            let cameraInput = try AVCaptureDeviceInput.init(device: cameraDevice)
            // 4、添加设备输入
            if session.canAddInput(cameraInput) {
                session.addInput(cameraInput)
            }
            // 5、照片输出流
            let imageOutPut = AVCapturePhotoOutput()
            self.imageOutPut = imageOutPut
            // 6、添加到session
            if session.canAddOutput(imageOutPut) {
                session.addOutput(imageOutPut)
            }
            // 5、视频输出流
            let movieoutput = AVCaptureMovieFileOutput()
            // 间隔多长时间片段保存
            movieoutput.movieFragmentInterval = CMTime(value: 5, timescale: 1)
            self.movieoutput = movieoutput
            // 6、添加到session
            if session.canAddOutput(movieoutput) {
                session.addOutput(movieoutput)
            }
     
            session.commitConfiguration()
             
                  
            // 7、添加到视图
            previewView.videoPreviewLayer.session = session
            
        } catch {
            
        }
        
    }
 
    
    @IBAction func startSession(_ sender: Any) {
        startRunning()
    }
    
    
    
    @IBAction func stopSession(_ sender: Any) {
        stopRunning()
    }
    
    @IBAction func movieOutput(_ sender: Any) {
        guard startRecording else {
            return
        }
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                        .userDomainMask, true)
        let documentsDirectory = paths[0] as String
        let outputFilePath = "\(documentsDirectory)/output-\(appendix).mov"
        appendix += 1
        let outputURL = URL(fileURLWithPath: outputFilePath)
        let fileManager = FileManager.default
        if(fileManager.fileExists(atPath: outputFilePath)) {
            
            do {
                try fileManager.removeItem(atPath: outputFilePath)
            } catch _ {
            }
        }
        print("开始录制：\(outputFilePath) ")
        movieoutput?.startRecording(to: outputURL, recordingDelegate: self)
    }
    
    @IBAction func captureStillImage(_ sender: Any) {
        // 照片输出设置
        let setting = AVCapturePhotoSettings.init(format: [AVVideoCodecKey:AVVideoCodecType.jpeg])
        imageOutPut?.capturePhoto(with: setting, delegate: self)
    
    }
   
}

//MARK: -- 事件 --
extension MYCaptureSessionController {
    // 启动
    func startRunning() {
        DispatchQueue(label: "startRunning").async {[weak self] in
            self?.captureSession?.startRunning()
        }
    }
    // 停止
    func stopRunning() {
        DispatchQueue(label: "stopRunning").async {[weak self] in
            self?.captureSession?.stopRunning()
            self?.movieoutput?.stopRecording()
        }
    }
}

//MARK: -- 拍照代理 --
extension MYCaptureSessionController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        stopRunning()
        let data = photo.fileDataRepresentation()
        let image = UIImage(data: data!)
        print("\(photo.metadata)")
    }

}

//MARK: -- 视频 --
extension MYCaptureSessionController: AVCaptureFileOutputRecordingDelegate {
    // 录像开始的代理方法
    func captureOutput(captureOutput: AVCaptureFileOutput!,
                       didStartRecordingToOutputFileAtURL fileURL: NSURL!,
                       fromConnections connections: [AnyObject]!) {
        print("录像开始的代理方法")
    }
    // 录像结束的代理方法
    // 我们既可以直接保存视频，
    // 也可以根据CMTime切割，分段合并保存
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        // 直接保存单个视频片段
        // saveVideoDerectlyToAblum(outputFileURL: outputFileURL)
                
        // ******下面是合成处理多个视频片段
        let asset = AVURLAsset(url: outputFileURL as URL, options: nil)
        print("生成视频片段002：\(asset)---\(outputFileURL)")
        videoAssets.append(asset) // 所有录像片段数组
        assetURLs.append(outputFileURL.path) /// 录像的片段url存到数组
      
        mergeVideos() // 合并视频
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
    
        // 各个参数还原
        videoAssets.removeAll(keepingCapacity: false)
        assetURLs.removeAll(keepingCapacity: false)
      
    }
    
    // 录像回看
    @objc func reviewRecord() {
        guard let url: URL = outputURL as? URL else {
            return
        }
        print("录像回放---\(String(describing: outputURL))")
 
        // 定义一个视频播放器，通过本地文件路径初始化
        let player = AVPlayer(url: url)
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
