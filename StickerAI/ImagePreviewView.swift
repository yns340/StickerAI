import SwiftUI

struct ImagePreviewView: View {
    let image: UIImage?
    @Environment(\.dismiss) private var dismiss
    @State private var isProcessing = false
    @State private var cartoonImage: UIImage?
    @State private var showCartoonView = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Ana görsel alanı
                VStack {
                    Spacer()
                    
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(
                                maxWidth: geometry.size.width * 0.8,
                                maxHeight: geometry.size.height * 0.5
                            )
                            .cornerRadius(geometry.size.width * 0.04)
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                
                // Alt buton alanı
                VStack(spacing: geometry.size.height * 0.02) {
                    Button(action: {
                        generateCartoon()
                    }) {
                        Text("Generate Cartoon")
                        .frame(maxWidth: .infinity)
                        .frame(height: geometry.size.height * 0.095)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(geometry.size.width * 0.06)
                        .font(.system(size: geometry.size.width * 0.045, weight: .semibold))
                    }
                    
                    Button(action: {
                        dismiss()

                    }) {
                        Text("Delete")
                        .frame(maxWidth: .infinity)
                        .frame(height: geometry.size.height * 0.095)
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(geometry.size.width * 0.06)
                        .font(.system(size: geometry.size.width * 0.045, weight: .semibold))
                    }
                }
                .padding(.horizontal, geometry.size.width * 0.07)
                .padding(.bottom, geometry.size.height * 0.07)
            }
        }
        .navigationTitle("Generate")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showCartoonView) {
                    if let cartoonImage = cartoonImage {
                        CartoonImagePreviewView(cartoonImage: cartoonImage)
                    }
                }
    }
    
    private func generateCartoon() {
            guard let image = image else { return }
            
            isProcessing = true
            
            DispatchQueue.global(qos: .userInitiated).async {
                let result = cartoonizeImage(image)
                
                DispatchQueue.main.async {
                    isProcessing = false
                    
                    if let cartoonResult = result {
                        cartoonImage = cartoonResult
                        showCartoonView = true
                    } else {
                        print("Cartoon generation failed")
                    }
                }
            }
        }
}

#Preview {
    NavigationStack {
        ImagePreviewView(image: UIImage(systemName: "photo"))
    }
}
