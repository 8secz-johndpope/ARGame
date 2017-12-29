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
    
    /// Управление фильтрами камеры
    func setFire(_ value: Bool)
}

class CameraViewController: UIViewController, CameraViewControllerPresentation {
    
    /* imageView под imageView_2
     * imageView без фильтра
     * imageView_2 с фильтром
     */
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageView_2: UIImageView! {
        didSet {
            self.imageView_2.alpha = 0.75;
        }
    }
    
    var captureSession: AVCaptureSession?
    var fire: Atomic = Atomic(value: false)

    // MARK: - CameraViewControllerPresentation
    func open() {
        DispatchQueue.main.async {
            self.startCamera()
            self.checkCaptureSessionRequestAccess()
        }
    }
    
    func close() {
        DispatchQueue.main.async {
            self.stopCamera()
        }
    }
    
    func setFire(_ value: Bool) {
        fire.value = value
    }

    // MARK: - Camera methods
    func startCamera() {
        
        if captureSession == nil {
            configureCaptureSession()
        }

        captureSession?.startRunning()
    }
    
    func stopCamera() {
        captureSession?.stopRunning()
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

    /// Если нет доступа к камере покажем алерт, напомним пользователю
    func checkCaptureSessionRequestAccess() {
        
        AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { granted  in
            if !granted {
                DispatchQueue.main.async {
                    self.showCameraPermissionAlert()
                }
            }
        })
    }
    
    func showCameraPermissionAlert() {
        let alertController = UIAlertController(title: "Alert", message: "alert_camera".lcd, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func filter() -> CIFilter? {
        var filter: CIFilter?
        
        if fire.value == true {
            filter = CIFilter(name: "CISpotColor")
        } else {
            filter = CIFilter(name: "CIEdges")
        }
        
        return filter
    }
}

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        connection.videoOrientation = AVCaptureVideoOrientation.portrait;
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
            else { return }

        guard let filter = filter()
            else { return }
        
        let cameraImage = CIImage(cvPixelBuffer: pixelBuffer)
        filter.setValue(cameraImage, forKey: kCIInputImageKey)
        
        DispatchQueue.main.async {
            
            self.imageView.image = UIImage(ciImage: cameraImage)
            
            if let outputValue = filter.value(forKey: kCIOutputImageKey) as? CIImage {
                self.imageView_2.image = UIImage(ciImage: outputValue)
            }
        }
    }
}
