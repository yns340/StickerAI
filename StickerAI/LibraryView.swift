import SwiftUI
import SwiftData

struct LibraryView: View {
    @Environment(\.modelContext) private var context
        
    // 🎯 Database'den sadece normal image'ları çek
    @Query(filter: #Predicate<StickerImage> { $0.isSticker == false },
        sort: \StickerImage.createdAt, order: .reverse)
    private var savedImages: [StickerImage]
    
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
                                            stickerImage: stickerImage,
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
                        Text("StickerPacks")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        ScrollView {
                            VStack(spacing: 15) {
                                ForEach(0..<6, id: \.self) { index in
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.purple.opacity(0.2))
                                        .frame(height: geometry.size.height * 0.13)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.black, lineWidth: 2)
                                        )
                                }
                            }
                            .padding(.horizontal, 15)
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
    let stickerImage: StickerImage
    let itemWidth: CGFloat
    @Environment(\.modelContext) private var context
    
    var body: some View {
        Group {
            if let uiImage = DatabaseManager.shared.loadImage(fileName: stickerImage.imagePath) {
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
        guard let uiImage = DatabaseManager.shared.loadImage(fileName: stickerImage.imagePath) else { return }
        UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
    }
    
    private func shareImage() {
        guard let uiImage = DatabaseManager.shared.loadImage(fileName: stickerImage.imagePath) else { return }
        
        let activityVC = UIActivityViewController(activityItems: [uiImage], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
    
    private func deleteImage() {
        DatabaseManager.shared.deleteImage(stickerImage, context: context)
    }
}

#Preview {
    LibraryView()
}

