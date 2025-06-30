import SwiftUI
import UIKit

struct GenerateView: View {
    @State private var isShowingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var showingPreview = false

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(spacing: 24) {
                    Spacer()
                    
                    // Başlık
                    Text("Create Your Cartoonized Stickers")
                        .font(.system(size: geometry.size.width * 0.09, weight: .semibold))
                        .multilineTextAlignment(.center)
                    
                    // Upload Image Button
                    if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                        Button(action: {
                            sourceType = .photoLibrary
                            isShowingImagePicker = true
                        }) {
                            Text("Upload Image")
                                .frame(maxWidth: .infinity)
                                .frame(height: geometry.size.height * 0.095)
                                .foregroundColor(.white)
                                .background(Color.blue)
                                .cornerRadius(geometry.size.width * 0.06)
                                .font(.system(size: geometry.size.width * 0.045, weight: .semibold))

                        }
                    }
                    
                    // Take Photo Button
                    if UIImagePickerController.isSourceTypeAvailable(.camera){
                        Button(action: {
                            sourceType = .camera
                            isShowingImagePicker = true
                        }) {
                            Text("Take Photo")
                                .frame(maxWidth: .infinity)
                                .frame(height: geometry.size.height * 0.095)
                                .foregroundColor(.white)
                                .background(Color.blue)
                                .cornerRadius(geometry.size.width * 0.06)
                                .font(.system(size: geometry.size.width * 0.045, weight: .semibold))

                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, geometry.size.width * 0.07)
                .navigationTitle("StickerAI")
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(isPresented: $showingPreview) {
                    ImagePreviewView(image: selectedImage)
                }
                .sheet(isPresented: $isShowingImagePicker) {
                    ImagePicker(
                        image: $selectedImage,
                        sourceType: sourceType
                    ) {
                        isShowingImagePicker = false
                    }
                }
                .onChange(of: selectedImage) { _, newValue in
                    if newValue != nil {
                        showingPreview = true
                    }
                }
            }
        }
    }
}

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


#Preview {
    GenerateView()
}
