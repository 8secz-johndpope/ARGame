//
//  CameraViewController.swift
//  ARGame
//
//  Created by Aleksandr on 19.12.2017.
//  Copyright © 2017 Aleksandr. All rights reserved.
//

import UIKit
import AVFoundation

protocol CameraViewControllerPresentable: class {
    func on()
    func off()
    /// Управление фильтрами камеры
    func setFire(_ value: Bool)
}

class CameraViewController: UIViewController, CameraViewControllerPresentable {
    
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
    
    fileprivate var captureSession: AVCaptureSession?
    fileprivate var fire: Atomic = Atomic(value: false)
    fileprivate lazy var fireFilter: CIFilter? = {
        return CIFilter(name: "CISpotColor")
    }()
    fileprivate lazy var noFireFilter: CIFilter? = {
        return CIFilter(name: "CIEdges")
    }()

    // MARK: - CameraViewControllerPresentation
    public func on() {
        DispatchQueue.main.async {
            self.startCamera()
            self.checkCaptureSessionRequestAccess()
        }
    }
    
    public func off() {
        DispatchQueue.main.async {
            self.stopCamera()
        }
    }
    
    public func setFire(_ value: Bool) {
        fire.value = value
    }

    // MARK: - Camera methods
    fileprivate func startCamera() {
        if captureSession == nil {
            configureCaptureSession()
        }

        captureSession?.startRunning()
    }
    
    fileprivate func stopCamera() {
        captureSession?.stopRunning()
    }

    fileprivate func configureCaptureSession() {
        let session = AVCaptureSession()
        session.sessionPreset = AVCaptureSession.Preset.photo

        if let backCamera = AVCaptureDevice.default(for: AVMediaType.video),
            let input = try? AVCaptureDeviceInput(device: backCamera),
            session.canAddInput(input) {
            session.addInput(input)
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
    fileprivate func checkCaptureSessionRequestAccess() {
        AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { granted  in
            if !granted {
                DispatchQueue.main.async {
                    self.showCameraPermissionAlert()
                }
            }
        })
    }
    
    fileprivate func showCameraPermissionAlert() {
        let alertController = UIAlertController(title: "Alert", message: "alert_camera".lcd, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        connection.videoOrientation = AVCaptureVideoOrientation.portrait;
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
            let filter = (fire.value ? fireFilter : noFireFilter)
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
