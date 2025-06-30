import SwiftUI

struct CartoonImagePreviewView: View {
    let cartoonImage: UIImage
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Ana görsel alanı
                VStack {
                    Spacer()
                    
                    Image(uiImage: cartoonImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(
                            maxWidth: geometry.size.width * 0.8,
                            maxHeight: geometry.size.height * 0.5
                        )
                        .cornerRadius(geometry.size.width * 0.04)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                
                // Alt buton alanı
                VStack(spacing: geometry.size.height * 0.02) {
                    Button("Save as Image") {
                        saveImageToGallery()
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: geometry.size.height * 0.095)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(geometry.size.width * 0.06)
                    .font(.system(size: geometry.size.width * 0.045, weight: .semibold))
                    
                    Button("Save as Sticker Pack") {
                        saveAsStickerPack()
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: geometry.size.height * 0.095)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(geometry.size.width * 0.06)
                    .font(.system(size: geometry.size.width * 0.045, weight: .semibold))
                    
                    Button("Delete") {
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: geometry.size.height * 0.095)
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(geometry.size.width * 0.06)
                    .font(.system(size: geometry.size.width * 0.045, weight: .semibold))
                }
                .padding(.horizontal, geometry.size.width * 0.07)
                .padding(.bottom, geometry.size.height * 0.07)
            }
        }
        .navigationTitle("Cartoon Result")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func saveImageToGallery() {
        // UIImageWriteToSavedPhotosAlbum implementasyonu
        UIImageWriteToSavedPhotosAlbum(cartoonImage, nil, nil, nil)
    }
    
    private func saveAsStickerPack() {
        // Sticker pack kaydetme implementasyonu
        // Bu kısım daha complex olacak
    }
    
}

#Preview {
    NavigationStack {
        CartoonImagePreviewView(cartoonImage: UIImage(systemName: "star.fill")!)
    }
}
