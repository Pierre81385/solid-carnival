//
//  CameraView.swift
//  swift-solid-carnival
//
//  Created by m1_air on 11/3/24.
//

import Foundation
import SwiftUI
import PhotosUI

struct CameraView: View {
    @State private var showCamera = false
    @State private var selectedImage: UIImage?
    @State var rekognitionViewModel = RekognitionViewModel()
    
    var body: some View {
        VStack {
            if let selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .onAppear {
                        rekognitionViewModel.analyzeImageWithAWSRekognition(image: selectedImage)
                    }
            } else {
                Text("No Image Selected")
                    .font(.headline)
            }
            
            Button("Open camera") {
                self.showCamera.toggle()
            }
            .fullScreenCover(isPresented: $showCamera) {
                accessCameraView(selectedImage: $selectedImage)
                    .background(.black)
            }
            ScrollView(content: {
                if let faces = rekognitionViewModel.faceDetails {
                    ForEach(faces) { face in
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Age Range: \(face.ageRange.low) - \(face.ageRange.high)")
                            Text("Beard: \(face.beard.value ? "Yes" : "No") with confidence \(String(format: "%.2f", face.beard.confidence))")
                            Text("Bounding Box: Height: \(String(format: "%.2f", face.boundingBox.height)), Width: \(String(format: "%.2f", face.boundingBox.width)), Top: \(String(format: "%.2f", face.boundingBox.top)), Left: \(String(format: "%.2f", face.boundingBox.left))")
                            Text("Confidence: \(String(format: "%.2f", face.confidence))")

                            Text("Emotions:")
                            ForEach(face.emotions) { emotion in
                                Text("\(emotion.type): \(String(format: "%.2f", emotion.confidence))%")
                            }

                            Text("Eye Direction - Pitch: \(String(format: "%.2f", face.eyeDirection.pitch)), Yaw: \(String(format: "%.2f", face.eyeDirection.yaw))")
                            Text("Eyeglasses: \(face.eyeglasses.value ? "Yes" : "No") with confidence \(String(format: "%.2f", face.eyeglasses.confidence))")
                            Text("Eyes Open: \(face.eyesOpen.value ? "Yes" : "No") with confidence \(String(format: "%.2f", face.eyesOpen.confidence))")
                            Text("Face Occluded: \(face.faceOccluded.value ? "Yes" : "No") with confidence \(String(format: "%.2f", face.faceOccluded.confidence))")
                            Text("Gender: \(face.gender.value) with confidence \(String(format: "%.2f", face.gender.confidence))")

                            Text("Landmarks:")
                            ForEach(face.landmarks) { landmark in
                                Text("\(landmark.type) - X: \(String(format: "%.2f", landmark.x)), Y: \(String(format: "%.2f", landmark.y))")
                            }

                            Text("Mouth Open: \(face.mouthOpen.value ? "Yes" : "No") with confidence \(String(format: "%.2f", face.mouthOpen.confidence))")
                            Text("Mustache: \(face.mustache.value ? "Yes" : "No") with confidence \(String(format: "%.2f", face.mustache.confidence))")

                            Text("Pose - Pitch: \(String(format: "%.2f", face.pose.pitch)), Roll: \(String(format: "%.2f", face.pose.roll)), Yaw: \(String(format: "%.2f", face.pose.yaw))")

                            Text("Quality - Brightness: \(String(format: "%.2f", face.quality.brightness)), Sharpness: \(String(format: "%.2f", face.quality.sharpness))")
                            Text("Smile: \(face.smile.value ? "Yes" : "No") with confidence \(String(format: "%.2f", face.smile.confidence))")
                            Text("Sunglasses: \(face.sunglasses.value ? "Yes" : "No") with confidence \(String(format: "%.2f", face.sunglasses.confidence))")
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
            })

        }
    }
}

struct accessCameraView: UIViewControllerRepresentable {
    
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var isPresented
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        imagePicker.delegate = context.coordinator
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(picker: self)
    }
}

// Coordinator will help to preview the selected image in the View.
class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var picker: accessCameraView
    
    init(picker: accessCameraView) {
        self.picker = picker
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else { return }
        self.picker.selectedImage = selectedImage
        self.picker.isPresented.wrappedValue.dismiss()
    }
}

#Preview {
    CameraView()
}
