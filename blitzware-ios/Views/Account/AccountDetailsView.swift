//
//  AccountDetailsView.swift
//  blitzware-ios
//
//  Created by Lander De Kesel on 14/11/2023.
//

import SwiftUI
import _PhotosUI_SwiftUI

struct AccountInfoItemView: View {
    var icon: String
    var text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
            Text(text)
        }
    }
}

struct ProfilePictureView: View {
    @EnvironmentObject var viewModel: AppViewModel

    var body: some View {
        let profileImage: Image

        if let profilePictureDataString = viewModel.accountData?.account.profilePicture,
           let data = profilePictureDataString.data(using: .utf8),
           let profilePictureData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let dataURL = profilePictureData["dataURL"] as? String,
           let base64String = dataURL.components(separatedBy: ",").last,
           let imageData = Data(base64Encoded: base64String),
           let uiImage = UIImage(data: imageData) {
            profileImage = Image(uiImage: uiImage)
        } else {
            profileImage = Image(.avatar)
            if let profilePictureData = viewModel.accountData?.account.profilePicture {
                if Data(base64Encoded: profilePictureData) != nil {
                } else {
                    print("Base64 Decoding Failed")
                }
            } else {
                print("Profile Picture Data is nil")
            }
        }

        return profileImage
            .resizable()
            .frame(width: 100, height: 100)
            .clipShape(Circle())
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) private var presentationMode
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Binding var selectedImage: UIImage
    @Binding var imageSelected: Bool

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {

        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator

        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {

    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.selectedImage = image
                parent.imageSelected = true
            }

            parent.presentationMode.wrappedValue.dismiss()
        }

    }
}

struct AccountDetailsView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var image = UIImage()
    @State private var showSheet = false
    @State private var imageSelected = false
    @State private var showAlert = false
    
    var body: some View {
        VStack {
            if viewModel.requestState == .error {
                Text(viewModel.errorData?.message ?? "Unknown error")
                    .foregroundColor(.red)
            }
            if viewModel.requestState == .pending || viewModel.requestState == .sent {
                ProgressView()
            }
            HStack {
                ProfilePictureView()
                VStack {
                    CustomButton(title: "Change photo", isDisabled: false) {
                        showSheet = true
                    }
                    CustomButton(title: "Upload", isDisabled: !imageSelected) {
                        uploadImage()
                    }
                }
            }
            .buttonStyle(.borderless)
            VStack(alignment: .leading, spacing: 20) {
                AccountInfoItemView(icon: "key.fill", text: viewModel.accountData!.account.id)
                AccountInfoItemView(icon: "person.fill", text: viewModel.accountData!.account.username)
                AccountInfoItemView(icon: "envelope.fill", text: "\(viewModel.accountData!.account.email)")
                AccountInfoItemView(icon: rolesIcon(), text: viewModel.accountData!.account.roles[0])
            }
            .padding()
        }
        .padding()
        .navigationTitle("Account Details")
        .onAppear(perform: {
            Task {
                await viewModel.getAccountById(id: viewModel.accountData!.account.id)
            }
        })
        .sheet(isPresented: $showSheet) {
            ImagePicker(sourceType: .photoLibrary, selectedImage: self.$image, imageSelected: self.$imageSelected)
//            ImagePicker(sourceType: .camera, selectedImage: self.$image)
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Success"),
                message: Text("Image uploaded successfully."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func uploadImage() {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            print("Failed to convert image to data.")
            return
        }

        let imageType = getImageType(data: imageData)
        let base64String = imageData.base64EncodedString()

        let profilePicture: [String: Any] = [
            "profilePicture": [
                "name": "avatar.png",
                "type": imageType,
                "size": imageData.count,
                "dataURL": "data:\(imageType);base64,\(base64String)"
            ]
        ]
        
        Task {
            await viewModel.updateAccountProfilePictureById(
                id: viewModel.accountData!.account.id,
                profilePicture: profilePicture
            )
            imageSelected = false
            showAlert = true
        }
    }
    
    func getImageType(data: Data) -> String {
        var buffer = [UInt8](repeating: 0, count: 1)
        data.copyBytes(to: &buffer, count: 1)
        
        switch buffer {
        case [0xFF]:
            return "image/jpeg"
        case [0x89]:
            return "image/png"
        default:
            return "application/octet-stream"
        }
    }
    
    func rolesIcon() -> String {
        switch viewModel.accountData?.account.roles[0] {
        case "admin": return "checkmark.shield.fill"
        case "basic": return "shield.lefthalf.filled"
        case "pro": return "shield.fill"
        case "enterprise": return "checkmark.shield.fill"
        case "free": return "shield"
        default: return "slider.horizontal.3"
        }
    }
}
