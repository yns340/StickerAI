import SwiftUI
import SwiftData

struct LibraryView: View {
    @Environment(\.modelContext) private var context
        
    // 🎯 Tüm ImageFile öğelerini çek (filtreye gerek yok artık)
    @Query(sort: \ImageFile.createdAt, order: .reverse)
    private var savedImages: [ImageFile]
    
    @Query(sort: \StickerPackEntity.name, order: .forward)
    private var stickerPacks: [StickerPackEntity]

    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(spacing: 15) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Images")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        let spacing: CGFloat = 15
                        let horizontalPadding: CGFloat = 15
                        let totalSpacing = spacing + (horizontalPadding * 2)
                        let itemWidth = (geometry.size.width - totalSpacing) / 2
                        
                        ScrollView {
                            if savedImages.isEmpty {
                                // Boş durum
                                VStack(spacing: 20) {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray)
                                                        
                                Text("No images saved yet")
                                    .font(.title3)
                                    .foregroundColor(.gray)
                                                            
                                Text("Create cartoon images to see them here!")
                                    .font(.body)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.top, 50)
                            } else {
                                // Resimler grid
                                LazyVGrid(columns: [
                                    GridItem(.fixed(itemWidth), spacing: spacing),
                                    GridItem(.fixed(itemWidth), spacing: spacing)
                                ], spacing: spacing) {
                                    ForEach(savedImages) { stickerImage in
                                        ImageGridItem(
                                            imageFile: stickerImage,
                                            itemWidth: itemWidth
                                        )
                                    }
                                }
                                .padding(.horizontal, horizontalPadding)
                            }
                        }
                    }
                    .frame(height: geometry.size.height / 2)
                    
                    Divider()
                        .frame(height: 1)
                        .background(Color.black)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Sticker Packs")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.horizontal)

                        ScrollView {
                            if stickerPacks.isEmpty {
                                // 🆕 Boş durum
                                VStack(spacing: 20) {
                                    Image(systemName: "square.stack.3d.down.forward")
                                        .font(.system(size: 60))
                                        .foregroundColor(.gray)

                                    Text("No sticker packs yet")
                                        .font(.title3)
                                        .foregroundColor(.gray)

                                    Text("Save your favorite cartoon images as stickers and group them into packs!")
                                        .font(.body)
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.top, 50)
                            } else {
                                // Sticker paketleri gösteriliyor
                                VStack(spacing: 15) {
                                    ForEach(stickerPacks, id: \.id) { pack in
                                        VStack(alignment: .leading) {
                                            Text(pack.name)
                                                .font(.headline)
                                                .padding(.leading, 10)
                                            
                                            ScrollView(.horizontal, showsIndicators: false) {
                                                HStack(spacing: 10) {
                                                    ForEach(pack.stickers, id: \.id) { sticker in
                                                        if let uiImage = DatabaseManager.shared.loadImageFromPath(sticker.imagePath) {
                                                            Image(uiImage: uiImage)
                                                                .resizable()
                                                                .aspectRatio(contentMode: .fill)
                                                                .frame(width: 60, height: 60)
                                                                .cornerRadius(8)
                                                                .shadow(radius: 2)
                                                        } else {
                                                            RoundedRectangle(cornerRadius: 8)
                                                                .fill(Color.gray.opacity(0.3))
                                                                .frame(width: 60, height: 60)
                                                        }
                                                    }
                                                }
                                                .padding(.horizontal, 10)
                                            }
                                        }
                                        .padding(.vertical, 5)
                                        .background(Color.purple.opacity(0.1))
                                        .cornerRadius(12)
                                        .padding(.horizontal)
                                        
                                        .contextMenu {
                                                Button {
                                                    exportToWhatsApp(pack)
                                                } label: {
                                                    Label("Export to WhatsApp", systemImage: "paperplane")
                                                }
                                            }
                                    }
                                }
                            }
                        }
                    }
                    .frame(height: geometry.size.height / 2)

                }
                .navigationTitle("Library")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
    
    // MARK: - WhatsApp'a Gönderme ve Sıkıştırma Fonksiyonları
    
    func exportToWhatsApp(_ pack: StickerPackEntity) {
        guard Interoperability.canSend() else {
            print("WhatsApp yüklü değil")
            return
        }
        
        guard pack.stickers.count >= 3 else {
            print("En az 3 sticker gerekli")
            return
        }
        
        do {
            // Tray icon'u database'den yükle
            let trayIconData: Data
            if let trayImage = DatabaseManager.shared.loadImageFromPath(pack.trayImagePath) {
                // Tray image'i sıkıştır
                guard let compressedTrayData = compressTrayImage(trayImage) else {
                    print("Tray icon sıkıştırılamadı")
                    return
                }
                trayIconData = compressedTrayData
            } else {
                // Fallback - ilk sticker'ı kullan
                guard let firstSticker = pack.stickers.first,
                      let firstImage = DatabaseManager.shared.loadImageFromPath(firstSticker.imagePath) else {
                    print("Tray icon yüklenemedi")
                    return
                }
                guard let compressedTrayData = compressTrayImage(firstImage) else {
                    print("Fallback tray icon sıkıştırılamadı")
                    return
                }
                trayIconData = compressedTrayData
            }
            
            let whatsappPack = try StickerPack(
                identifier: pack.identifier,
                name: pack.name,
                publisher: pack.publisher,
                trayImagePNGData: trayIconData,
                publisherWebsite: nil,
                privacyPolicyWebsite: nil,
                licenseAgreementWebsite: nil
            )
            
            for stickerEntity in pack.stickers {
                guard let stickerImage = DatabaseManager.shared.loadImageFromPath(stickerEntity.imagePath) else { continue }
                
                // Resmi sıkıştır ve boyutunu küçült
                let compressedData = compressImageForWhatsApp(stickerImage)
                guard let pngData = compressedData else { continue }
                    
                print("Sticker: \(pngData.count / 1024) KB")
            
                try whatsappPack.addSticker(
                    imageData: pngData,     // bu artık JPEG ama değişken adı kalsın sorun değil
                    type: .png,            // <<< 🔁 BURADA png → jpeg OLACAK
                    emojis: nil,
                    accessibilityText: nil
                )

            }
            
            whatsappPack.sendToWhatsApp { success in
                print(success ? "✅ Gönderildi" : "❌ Hata")
            }
             
        } catch {
            print("Hata: \(error)")
        }
    }

    
    private func compressImageForWhatsApp(_ image: UIImage) -> Data? {
        let targetSize = CGSize(width: 512, height: 512)

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0 // Boyut tam 512x512 olsun
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)

        let resizedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }

        // Sadece JPEG ve küçük kalite (çok fark edilmiyor)
        guard let jpegData = resizedImage.jpegData(compressionQuality: 0.25) else {
            return nil
        }

        print("Sticker boyutu: \(jpegData.count / 1024) KB")
        return jpegData
    }


    
    private func compressTrayImage(_ image: UIImage) -> Data? {
        let traySize = CGSize(width: 96, height: 96)

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0 // ÖLÇEK = 1.0 → 96x96 olsun, 288 değil!
        
        let renderer = UIGraphicsImageRenderer(size: traySize, format: format)
        let resizedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: traySize))
        }

        // JPEG ile sıkıştır
        guard let jpegData = resizedImage.jpegData(compressionQuality: 0.2) else {
            return nil
        }

        print("Tray icon boyutu: \(jpegData.count / 1024) KB")
        return jpegData
    }

}

// MARK: - Grid Item Component
struct ImageGridItem: View {
    let imageFile: ImageFile
    let itemWidth: CGFloat
    @Environment(\.modelContext) private var context
    
    var body: some View {
        Group {
            if let uiImage = DatabaseManager.shared.loadImage(fileName: imageFile.imagePath) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: itemWidth, height: itemWidth)
                    .clipped()
            } else {
                // Yüklenemedi
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: itemWidth, height: itemWidth)
                    .overlay(
                        VStack {
                            Image(systemName: "photo")
                                .font(.title)
                                .foregroundColor(.gray)
                            Text("Not found")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    )
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.black, lineWidth: 4)
        )
        .cornerRadius(8)
        .contextMenu {
            Button {
                saveToPhotoLibrary()
            } label: {
                Label("Save to Photo Library", systemImage: "square.and.arrow.down")
            }
            
            Button {
                shareImage()
            } label: {
                Label("Share", systemImage: "square.and.arrow.up")
            }
            
            Button(role: .destructive) {
                deleteImage()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    private func saveToPhotoLibrary() {
        guard let uiImage = DatabaseManager.shared.loadImage(fileName: imageFile.imagePath) else { return }
        UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
    }
    
    private func shareImage() {
        guard let uiImage = DatabaseManager.shared.loadImage(fileName: imageFile.imagePath) else { return }
        
        let activityVC = UIActivityViewController(activityItems: [uiImage], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
    
    private func deleteImage() {
        DatabaseManager.shared.deleteImage(imageFile, context: context)
    }
}

#Preview {
    LibraryView()
}

