//
//  SuccessView.swift
//  swift-solid-carnival
//
//  Created by m1_air on 11/3/24.
//

import SwiftUI
import PhotosUI

struct SuccessView: View {
    @State var back: Bool = false
    @Binding var userViewModel: UserViewModel
    @State var imagePickerViewModel: ImagePickerViewModel = ImagePickerViewModel()
    @State var uid: String = ""
    @State private var showCamera = false
    @State private var selectedImage: UIImage?
    @State private var showImagePicker: Bool = true
    
    var body: some View {
        NavigationStack{
            VStack{
                HStack{
                    Button("Logout", action: {
                        Task{
                            back = await userViewModel.logoutUser()
                        }
                    }).foregroundStyle(.black)
                        .fontWeight(.light)
                        .padding()
                        .navigationDestination(isPresented: $back, destination: {
                            LoginUserView().navigationBarBackButtonHidden(true)
                        })
                    Spacer()
                }
                if(showImagePicker) {
                    ImagePickerView(imagePickerViewModel: $imagePickerViewModel, uploadType: "profile").padding()
                }
                if let selectedImage {
                   
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 325, height: 325)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                            .onAppear {
                                showImagePicker = false
                            }
                            .onTapGesture {
                                self.showCamera.toggle()
                            }
                    HStack{
                        Spacer()
                        Button(action: {
                            self.selectedImage = nil
                            showCamera = false
                            showImagePicker = true
                        }, label: {
                            Image(systemName: "xmark").tint(Color.black)
                        })
                        Spacer()
                        Button(action: {
                            //upload function here!
                        }) {
                            Image(systemName: "checkmark").tint(Color.black)
                        }
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
                    }.onAppear{
                        
                    }
                }
        
                Spacer()
            }.onAppear{
                Task{
                    let success = await userViewModel.getCurrentUser()
                    if(!success) {
                        back = true
                    }
                }
            }.navigationDestination(isPresented: $back, destination: {
                LoginUserView().navigationBarBackButtonHidden(true)
            })
        }
    }
}

//#Preview {
//    SuccessView()
//}
