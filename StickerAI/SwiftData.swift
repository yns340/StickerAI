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
}
