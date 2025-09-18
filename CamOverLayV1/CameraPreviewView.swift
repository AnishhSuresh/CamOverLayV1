//
//  CameraPreviewView.swift
//  CamOverLayV1
//
//  Created by Assistant on 1/27/25.
//

import SwiftUI
import AVFoundation
import UIKit

struct CameraPreviewView: UIViewRepresentable {
    @Binding var isRunning: Bool
    @Binding var capturedImage: UIImage?
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = UIColor.black
        
        let captureSession = AVCaptureSession()
        
        // Configure session
        if captureSession.canSetSessionPreset(.high) {
            captureSession.sessionPreset = .high
        }
        
        // Get back camera
        guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Unable to access back camera")
            return view
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
        } catch {
            print("Error setting up camera input: \(error)")
            return view
        }
        
        // Add video output
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(context.coordinator, queue: DispatchQueue(label: "videoQueue"))
        
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        
        // Create preview layer
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        
        // Store references in coordinator
        context.coordinator.captureSession = captureSession
        context.coordinator.previewLayer = previewLayer
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        guard let coordinator = context.coordinator as? CameraCoordinator else { return }
        
        if isRunning && !coordinator.captureSession.isRunning {
            DispatchQueue.global(qos: .background).async {
                coordinator.captureSession.startRunning()
            }
        } else if !isRunning && coordinator.captureSession.isRunning {
            DispatchQueue.global(qos: .background).async {
                coordinator.captureSession.stopRunning()
            }
        }
    }
    
    func makeCoordinator() -> CameraCoordinator {
        CameraCoordinator(self)
    }
}

class CameraCoordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    let parent: CameraPreviewView
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    init(_ parent: CameraPreviewView) {
        self.parent = parent
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // This is where we would process the video frames for ML inference
        // For now, we'll just convert to UIImage for display purposes
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        
        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            let uiImage = UIImage(cgImage: cgImage)
            
            DispatchQueue.main.async {
                // Update the captured image for ML processing
                self.parent.capturedImage = uiImage
            }
        }
    }
}
