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
                    
                    HStack(spacing: geometry.size.height * 0.02) {
                        Button(action: {
                            saveImageToGallery()
                        }) {
                            Text("Save as Image")
                                .frame(maxWidth: .infinity)
                                .frame(height: geometry.size.height * 0.095)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(geometry.size.width * 0.06)
                                .font(.system(size: geometry.size.width * 0.045, weight: .semibold))
                        }
                        
                        Button(action: {
                            saveAsStickerPack()
                        }) {
                            Text("Save as Sticker")
                                .frame(maxWidth: .infinity)
                                .frame(height: geometry.size.height * 0.095)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(geometry.size.width * 0.06)
                                .font(.system(size: geometry.size.width * 0.045, weight: .semibold))
                        }
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
        .navigationTitle("Cartoon Result")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func saveImageToGallery() {
        UIImageWriteToSavedPhotosAlbum(cartoonImage, nil, nil, nil)
    }
    
    func saveAsStickerPack() {
        // Buraya sticker paketine kaydetme işlemi gelecek
        // Daha sonra StickerKit, Telegram API ya da WhatsApp için uygun API eklenebilir
    }
}

#Preview {
    NavigationStack {
        CartoonImagePreviewView(cartoonImage: UIImage(systemName: "star.fill")!)
    }
}
