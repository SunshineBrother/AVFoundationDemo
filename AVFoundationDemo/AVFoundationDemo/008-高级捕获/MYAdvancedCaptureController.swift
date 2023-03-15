//
//  MYAdvancedCaptureController.swift
//  AVFoundationDemo
//
//  Created by sunshine on 2023/3/15.
//

import AVFoundation
import AVKit
import Photos
import UIKit

class MYAdvancedCaptureController: UIViewController {
    
    @IBOutlet weak var bgView: UIView!
    let previewView = PreviewView()
    var captureSession: AVCaptureSession?
    /// 照片输出流
    var imageOutPut: AVCapturePhotoOutput?
    override func viewDidLoad() {
        super.viewDidLoad()

        let metadaoutput = AVCaptureMetadataOutput()
        metadaoutput.metadataObjectTypes = [.face]
        
        
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
            
            cameraDevice.videoZoomFactor = 1.5
            
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
           
           
            session.commitConfiguration()
              
            // 7、添加到视图
            previewView.videoPreviewLayer.session = session
            
        } catch {
            
        }
        
    }
 
    
    @IBAction func startSession(_ sender: Any) {
        DispatchQueue(label: "startSession").async {[weak self] in
            self?.captureSession?.startRunning()
             
        }
    }
    
    
    @IBAction func stopSession(_ sender: Any) {
        DispatchQueue(label: "stopRunning").async {[weak self] in
            self?.captureSession?.stopRunning()
           
        }
    }
    
}
