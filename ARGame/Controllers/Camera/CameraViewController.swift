//
//  CameraViewController.swift
//  ARGame
//
//  Created by Aleksandr on 19.12.2017.
//  Copyright © 2017 Aleksandr. All rights reserved.
//

import UIKit
import AVFoundation

protocol CameraViewControllerPresentation: class {
    func open()
    func close()
    
    // управление фильтром пункта назначения
    func setFire(_ value: Bool)
}

class CameraViewController: UIViewController, CameraViewControllerPresentation {
    
    /* imageView_2 над imageView
     * imageView без фильтра
     * imageView_2 с фильтром, изменяется alpha по таймеру
     */
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageView_2: UIImageView!
    
    var captureSession: AVCaptureSession?
    var timer: Timer?
    var fire: Atomic = Atomic(value: false) {
        didSet(fire) {
            if fire.value == true {
                self.stopTimer()
                self.imageView_2.alpha = 1.0;
            } else {
                self.startTimer()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Camera"
    }

    func open() {
        startCamera()
        checkCaptureSessionRequestAccess()
    }
    
    func close() {
        stopCamera()
    }
    
    func setFire(_ value: Bool) {
        fire.value = value
    }

    func startCamera() {
        
        if captureSession == nil {
            configureCaptureSession()
        }

        captureSession?.startRunning()
        
        if fire.value == false {
            startTimer()
        }
    }
    
    func stopCamera() {
        stopTimer()
        captureSession?.stopRunning()
    }
    
    func startTimer() {
        
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateImageViewAlpha), userInfo: nil, repeats: true)
            timer?.fire()
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func configureCaptureSession() {

        let session = AVCaptureSession()
        session.sessionPreset = AVCaptureSession.Preset.photo

        if let backCamera = AVCaptureDevice.default(for: AVMediaType.video) {

            if let input = try? AVCaptureDeviceInput(device: backCamera) {
                
                if session.canAddInput(input) {
                    session.addInput(input)
                } else {
                    return
                }
                
            } else {
                return
            }
            
        } else {
            return
        }

        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "com.my.captureSession"))
        
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        } else {
            return
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        view.layer.addSublayer(previewLayer)
        
        captureSession = session
    }
    
    @objc func updateImageViewAlpha() {

        DispatchQueue.main.async {
            let alpha = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
            self.imageView_2.alpha = alpha
        }
    }
    
    func checkCaptureSessionRequestAccess() {
        
        /*
         *  Если нет доступа к камере покажем алерт, напомним пользователю
         */
        
        AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { granted  in
            
            if !granted {
                DispatchQueue.main.async {
                    self.stopCamera()
                    self.showCameraPermissionAlert()
                }
            }
        })
    }
    
    func showCameraPermissionAlert() {
        let alertController = UIAlertController(title: "Alert", message: "permission_camera".lcd, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        connection.videoOrientation = AVCaptureVideoOrientation.portrait;
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
            else { return }

        let cameraImage = CIImage(cvPixelBuffer: pixelBuffer)

        var filter: CIFilter!
        
        if fire.value == true {
            filter = CIFilter(name: "CIComicEffect")!
        } else {
            filter = CIFilter(name: "CIEdges")!
        }
        
        filter.setValue(cameraImage, forKey: kCIInputImageKey)
        
        DispatchQueue.main.async {
            
            if let outputValue = filter.value(forKey: kCIOutputImageKey) as? CIImage {
                self.imageView.image = UIImage(ciImage: cameraImage)
                self.imageView_2.image = UIImage(ciImage: outputValue)
            }
        }
    }
}
