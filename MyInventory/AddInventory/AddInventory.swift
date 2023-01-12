//
//  AddInventory.swift
//  MyInventory
//
//  Created by Muhammad Faruuq Qayyum on 10/01/23.
//

import SwiftUI
import Combine
import UIKit.UIImagePickerController

struct AddInventory: View {
    
    @Binding var label: String
    @State private var showAlert = false
    @Binding var isBeingPresented: Bool
    @State private var showCamera = false
    @Binding var uploadedImage: UIImage?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                loadedImage
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: UIScreen.main.bounds.size.height / 3)
                
                Form {
                    TextField("Item label", text: $label)
                        .autocorrectionDisabled()

                    Section {
                        Button {
                            showCamera = true
                        } label: {
                            HStack(spacing: 10) {
                                Spacer()
                                Image(systemName: "paperclip.circle")
                                Text("Upload image")
                                Spacer()
                            }
                            .tint(.teal)
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isBeingPresented.toggle()
                    } label: {
                        Text("Save")
                            .fontWeight(.semibold)
                            .foregroundColor(.teal)
                    }

                }
            }
                .navigationTitle("Add Inventory")
                .sheet(isPresented: $showCamera) {
                    CameraView(selectedImage: $uploadedImage,
                               isBeingPresented: $showCamera)
                }
        }
    }
}

// MARK: - Functions
extension AddInventory {
    var loadedImage: Image {
        var image = Image("ImagePlaceholder")
        if let uploadedImage {
            image = Image(uiImage: uploadedImage)
        }
        return image
    }
}

// MARK: - Previews
struct AddInventory_Previews: PreviewProvider {
    static var previews: some View {
        AddInventory(
            label: .constant(""),
            isBeingPresented: .constant(false),
            uploadedImage: .constant(nil)
        )
    }
}
