import SwiftUI
import SwiftData
import Foundation

// MARK: - SwiftData Models
@Model
class StickerImage {
    @Attribute(.unique) var id: UUID
    var imagePath: String
    var createdAt: Date
    var isSticker: Bool // false = normal image, true = sticker
    
    init(imagePath: String, isSticker: Bool = false) {
        self.id = UUID()
        self.imagePath = imagePath
        self.createdAt = Date()
        self.isSticker = isSticker
    }
}

@Model
class StickerPack {
    @Attribute(.unique) var id: UUID
    var name: String
    var createdAt: Date
    @Relationship(deleteRule: .cascade) var stickers: [StickerImage]
    
    init(name: String) {
        self.id = UUID()
        self.name = name
        self.createdAt = Date()
        self.stickers = []
    }
}

// MARK: - Database Manager
class DatabaseManager {
    static let shared = DatabaseManager()
    private init() {}
    
    // 🎯 ANA FONKSİYON: Resmi kaydet
    func saveImage(_ image: UIImage, context: ModelContext) -> Bool {
        do {
            // 1. Resmi dosya olarak kaydet
            let fileName = saveImageToFile(image)
            
            // 2. Database'e kaydet
            let stickerImage = StickerImage(imagePath: fileName, isSticker: false)
            context.insert(stickerImage)
            
            // 3. Değişiklikleri kaydet
            try context.save()
            
            print("✅ Image saved: \(fileName)")
            return true
            
        } catch {
            print("❌ Save error: \(error)")
            return false
        }
    }
    
    // 🗂️ Resmi dosya olarak kaydet
    private func saveImageToFile(_ image: UIImage) -> String {
        // Documents klasörü
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        // Benzersiz dosya adı
        let fileName = "IMG_\(UUID().uuidString).png"
        let fileURL = documentsPath.appendingPathComponent(fileName)
        
        // PNG olarak kaydet
        if let imageData = image.pngData() {
            try? imageData.write(to: fileURL)
        }
        
        return fileName
    }
    
    // 🖼️ Dosyadan resim yükle
    func loadImage(fileName: String) -> UIImage? {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsPath.appendingPathComponent(fileName)
        
        if let imageData = try? Data(contentsOf: fileURL) {
            return UIImage(data: imageData)
        }
        
        return nil
    }
    
    // 🗑️ Resmi sil
    func deleteImage(_ stickerImage: StickerImage, context: ModelContext) {
        // 1. Dosyayı sil
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsPath.appendingPathComponent(stickerImage.imagePath)
        try? FileManager.default.removeItem(at: fileURL)
        
        // 2. Database'den sil
        context.delete(stickerImage)
        try? context.save()
        
        print("✅ Image deleted: \(stickerImage.imagePath)")
    }
}
