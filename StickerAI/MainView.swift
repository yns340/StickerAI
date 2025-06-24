import SwiftUI
import UIKit

struct MainView: View {
    @State private var isShowingImagePicker = false
    @State private var selectedImage: UIImage?
    
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
                    isShowingImagePicker = true
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
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePickerOptionsView(
                selectedImage: $selectedImage,
                isPresented: $isShowingImagePicker
            )
            .presentationDetents([.fraction(0.25), .medium])
            .presentationDragIndicator(.visible)
        }
        .navigationTitle("Ana Sayfa")
    }
}

struct ImagePickerOptionsView: View {
    @Binding var selectedImage: UIImage?
    @Binding var isPresented: Bool
    @State private var showingImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 20) {
                Button(action: {
                    sourceType = .camera
                    showingImagePicker = true
                }) {
                    HStack {
                        Image(systemName: "camera.fill")
                            .font(.title2)
                        Text("Şimdi Çek")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .disabled(!UIImagePickerController.isSourceTypeAvailable(.camera))
                .padding(.horizontal, 20)
                
                Button(action: {}) {
                    HStack {
                        Image(systemName: "photo.on.rectangle")
                            .font(.title2)
                        Text("Fotoğraflardan Yükle")
                            .font(.headline)
                    }
                    .foregroundColor(.gray)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(12)
                }
                .disabled(true)
                .padding(.horizontal, 20)
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $selectedImage, sourceType: sourceType) {
                isPresented = false
            }
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    let sourceType: UIImagePickerController.SourceType
    let onDismiss: () -> Void
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
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

#Preview {
    MainView()
}
