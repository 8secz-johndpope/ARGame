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

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Camera"
    }

    func open() {
        captureRequestAccess()
    }
    
    func close() {
        stopCamera()
    }
    
    func startCamera() {
        captureSession?.startRunning()
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateAlpha), userInfo: nil, repeats: true)
        timer?.fire()
    }
    
    func stopCamera() {
        timer?.invalidate()
        captureSession?.stopRunning()
    }
    
    func captureRequestAccess() {

        /*
         *  Проверим доступ, запустим камеру. Если доступа нет - алерт
         */
        
        AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { [weak self] granted  in

            DispatchQueue.main.async {
                
                if granted {
                    
                    if (self?.captureSession) != nil {
                        self?.startCamera()
                    } else {
                        self?.configureCaptureSession()
                        self?.startCamera()
                    }
                    
                } else {
                    self?.stopCamera()
                    self?.showCameraPermissionAlert()
                }
            }
        })
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
    
    @objc func updateAlpha() {

        DispatchQueue.main.async { [weak self] in
            let alpha = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
            self?.imageView_2.alpha = alpha
        }
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

        let filter = CIFilter(name: "CIEdges")!
        filter.setValue(cameraImage, forKey: kCIInputImageKey)
        
        DispatchQueue.main.async { [weak self] in
            
            if let outputValue = filter.value(forKey: kCIOutputImageKey) as? CIImage {
                self?.imageView.image = UIImage(ciImage: cameraImage)
                self?.imageView_2.image = UIImage(ciImage: outputValue)
            }
        }
    }
}
