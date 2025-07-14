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

