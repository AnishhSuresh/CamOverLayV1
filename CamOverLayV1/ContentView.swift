//
//  ContentView.swift
//  CamOverLayV1
//
//  Created by Anishh Suresh on 9/14/25.
//

import SwiftUI
import PhotosUI
import AVFoundation

struct ContentView: View {
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var selectedItem: PhotosPickerItem?
    @State private var isCameraRunning = false
    @State private var capturedImage: UIImage?
    @StateObject private var mlModel = MLModelWrapper()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack {
                    Image(systemName: "globe")
                        .imageScale(.large)
                        .foregroundStyle(.tint)
                    Text("Camera Overlay App")
                    Text("OpenCV Version: \(OpenCVWrapper.openCVVersionString())")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Gallery picker button
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    HStack {
                        Image(systemName: "photo.on.rectangle")
                        Text("Choose from Gallery")
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .onChange(of: selectedItem) { newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                            selectedImage = UIImage(data: data)
                        }
                    }
                }
                
                // Display selected image from gallery
                if let selectedImage = selectedImage {
                    VStack(alignment: .leading) {
                        Text("Selected Image from Gallery:")
                            .font(.headline)
                        Image(uiImage: selectedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 200)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                } else {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 150)
                        .overlay(
                            Text("No image selected from gallery")
                                .foregroundColor(.gray)
                        )
                }
                
                // Camera controls
                VStack(spacing: 10) {
                    HStack {
                        Button(action: {
                            isCameraRunning.toggle()
                        }) {
                            HStack {
                                Image(systemName: isCameraRunning ? "stop.circle.fill" : "play.circle.fill")
                                Text(isCameraRunning ? "Stop Camera" : "Start Camera")
                            }
                            .padding()
                            .background(isCameraRunning ? Color.red : Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        
                        if isCameraRunning {
                            Button(action: {
                                // Capture current frame
                                if let image = capturedImage {
                                    selectedImage = image
                                }
                            }) {
                                HStack {
                                    Image(systemName: "camera.circle.fill")
                                    Text("Capture")
                                }
                                .padding()
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                        }
                    }
                    
                    // ML Prediction Display
                    if isCameraRunning {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("ML Prediction:")
                                .font(.headline)
                            Text(mlModel.predictionText)
                                .font(.body)
                                .foregroundColor(.primary)
                            Text("Confidence: \(String(format: "%.2f", mlModel.confidence * 100))%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
                
                // Live camera preview
                if isCameraRunning {
                    VStack(alignment: .leading) {
                        Text("Live Camera Feed:")
                            .font(.headline)
                        CameraPreviewView(isRunning: $isCameraRunning, capturedImage: $capturedImage)
                            .frame(height: 300)
                            .cornerRadius(10)
                            .clipped()
                            .onChange(of: capturedImage) { newImage in
                                if let image = newImage {
                                    mlModel.processImage(image)
                                }
                            }
                    }
                } else {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.black.opacity(0.8))
                        .frame(height: 300)
                        .overlay(
                            VStack {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white)
                                Text("Camera Preview")
                                    .foregroundColor(.white)
                                Text("Tap 'Start Camera' to begin")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        )
                }
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
