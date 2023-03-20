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
       
    }
     
     
    
}
