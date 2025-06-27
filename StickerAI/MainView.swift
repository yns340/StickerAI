import SwiftUI
import UIKit

//MARK: - DESIGN
struct MainView: View {
    @State private var isShowingImagePicker = false
    @State private var isShowingSourceDialog = false
    @State private var selectedImage: UIImage?
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary

    var body: some View {
        VStack {
            Spacer()
            
            if let selectedImage = selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: UIScreen.main.bounds.height * 0.4)
                    .padding()
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: UIScreen.main.bounds.height * 0.4)
                    .foregroundColor(.gray)
                    .padding()
            }
            
            Spacer()
            
            VStack(spacing: UIScreen.main.bounds.height * 0.03) {
                Button(action: {
                    isShowingSourceDialog = true
                }) {
                    Text("Resim yükle")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                
                Button(action: {
                    if selectedImage != nil {
                        selectedImage = nil
                    }
                }) {
                    Text("Resmi sil")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(selectedImage != nil ? Color.red : Color.gray)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .disabled(selectedImage == nil)
                
                Button(action: {
                    if let image = selectedImage {
                        if let cartoonImage = cartoonizeImage(image) {
                            selectedImage = cartoonImage
                        }
                    }
                }) {
                    Text("Karikatürleştir")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(selectedImage != nil ? Color.blue : Color.gray)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .disabled(selectedImage == nil)
            }
            .padding(.bottom, UIScreen.main.bounds.height * 0.03)
            
            Spacer()
        }
        .confirmationDialog("Resim Seç", isPresented: $isShowingSourceDialog) {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                Button("Şimdi Çek") {
                    sourceType = .camera
                    isShowingImagePicker = true
                }
            }
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                Button("Fotoğraflardan Yükle") {
                    sourceType = .photoLibrary
                    isShowingImagePicker = true
                }
            }
            Button("İptal", role: .cancel) {}
        }
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker(
                image: $selectedImage,
                sourceType: sourceType
            ) {
                isShowingImagePicker = false
            }
        }
        .navigationTitle("Ana Sayfa")
    }
}

// MARK: - Image Picker

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    let sourceType: UIImagePickerController.SourceType
    let onDismiss: () -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        uiViewController.sourceType = sourceType
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            picker.dismiss(animated: true) {
                self.parent.onDismiss()
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true) {
                self.parent.onDismiss()
            }
        }
    }
}

// MARK: - Preview

#Preview {
    MainView()
}
