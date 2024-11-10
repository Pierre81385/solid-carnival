//
//  ProfileView.swift
//  swift-solid-carnival
//
//  Created by m1_air on 11/7/24.
//

import SwiftUI

struct VerifyView: View {
    @State var userViewModel: UserViewModel = UserViewModel()
    @State var s3ViewModel: S3ViewModel = S3ViewModel()
    @State var rekognitionViewModel: RekognitionViewModel = RekognitionViewModel()
    @State var selectedImage: UIImage?
    @State var showImagePicker: Bool = true
    @State var showCamera = false
    @State var uploaded: Bool = false
    @State var processing: Bool = false
    @State var logout: Bool = false
    @State var compared: Bool = false

    var body: some View {
        NavigationStack{
            VStack{
                Spacer()
                if let selectedImage {
                    
                    // Display the captured image
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 325, height: 325)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                        .onTapGesture {
                            self.showCamera.toggle()
                        }
                    
                    HStack{
                        Spacer()
                        Button(action: {
                            self.selectedImage = nil
                            showCamera = false
                        }, label: {
                            Image(systemName: "xmark").tint(Color.black)
                        })
                        Spacer()
                        Button(action: {
                            processing = true
                            //upload function here!
                            Task{
                                uploaded = await s3ViewModel.uploadImageToS3(image: selectedImage)
                                compared = await rekognitionViewModel.compareWithAWSRekognition(source: userViewModel.userData.profileImg, target: s3ViewModel.imageUrl)
                                processing = false
                            }
                        }, label: {
                            if (processing) {
                                ProgressView()
                            } else {
                                Image(systemName: "checkmark").tint(Color.black)
                            }
                        })
                        Spacer()
                    }.padding()
                } else {
                    
                    Button(action: {
                        self.showCamera.toggle()
                    }, label: {
                        Image(systemName: "camera.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundStyle(.black)
                    }).fullScreenCover(isPresented: $showCamera) {
                        accessCameraView(selectedImage: $selectedImage)
                            .background(.black)
                    }
                    
                }
                if (compared) {
                    ScrollView(content: {
                        Text("Similarity: \(rekognitionViewModel.similarity ?? 0.00)")
                    })
                }
                
            }.onAppear{
                Task{
                    let loggedIn = await userViewModel.getCurrentUser()
                    let docFound = await userViewModel.getUserData()
                    if(!loggedIn) {
                        logout = true
                    }
                }
            }
        }
    }
}

#Preview {
    VerifyView()
}
