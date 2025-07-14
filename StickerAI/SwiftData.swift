import SwiftUI
import SwiftData
import Foundation

// MARK: - SwiftData Models
@Model
class ImageFile {
    @Attribute(.unique) var id: UUID
    var imagePath: String
    var createdAt: Date
    
    init(imagePath: String) {
        self.id = UUID()
        self.imagePath = imagePath
        self.createdAt = Date()
    }
}

@Model
class StickerPackEntity {
    @Attribute(.unique) var id: UUID
    var identifier: String
    var name: String
    var publisher: String
    var trayImagePath: String
    var animated: Bool = false  // statik için false hep

    @Relationship(deleteRule: .cascade, inverse: \StickerEntity.pack)
    var stickers: [StickerEntity] = []

    init(
        id: UUID = UUID(),
        identifier: String,
        name: String,
        publisher: String,
        trayImagePath: String
    ) {
        self.id = id
        self.identifier = identifier
        self.name = name
        self.publisher = publisher
        self.trayImagePath = trayImagePath
    }
}

@Model
class StickerEntity {
    @Attribute(.unique) var id: UUID
    var imagePath: String
    var accessibilityText: String?  // opsiyonel bırakıyorum, istersen kullanabilirsin
    
    @Relationship var pack: StickerPackEntity?

    init(
        id: UUID = UUID(),
        imagePath: String,
        accessibilityText: String? = nil
    ) {
        self.id = id
        self.imagePath = imagePath
        self.accessibilityText = accessibilityText
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
            let image = ImageFile(imagePath: fileName)
            context.insert(image)
            
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
    func deleteImage(_ image: ImageFile, context: ModelContext) {
        // 1. Dosyayı sil
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsPath.appendingPathComponent(image.imagePath)
        try? FileManager.default.removeItem(at: fileURL)
        
        // 2. Database'den sil
        context.delete(image)
        try? context.save()
        
        print("✅ Image deleted: \(image.imagePath)")
    }
    
    func saveStickerAndReturn(from image: UIImage, context: ModelContext) -> StickerEntity? {
        guard let pngData = image.pngData() else {
            print("Failed to convert UIImage to PNG data")
            return nil
        }
        
        do {
            let fileName = "STICKER_\(UUID().uuidString).png"  // sadece dosya adı
            let folderURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = folderURL.appendingPathComponent(fileName)
            
            try pngData.write(to: fileURL)
            
            let sticker = StickerEntity(
                id: UUID(),
                imagePath: fileName,  // sadece dosya adı kaydediliyor
                accessibilityText: nil
            )
            
            context.insert(sticker)
            try context.save()
            
            print("Sticker saved with file name: \(fileName)")
            return sticker
        } catch {
            print("Failed to save sticker: \(error)")
            return nil
        }
    }

    
    func loadImageFromPath(_ fileName: String) -> UIImage? {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documents.appendingPathComponent(fileName)
        
        if let data = try? Data(contentsOf: fileURL) {
            return UIImage(data: data)
        }
        return nil
    }
}
