import UIKit
import CoreML
import Vision

// MARK: - CoreML İşleyici Fonksiyonu
func cartoonizeImage(_ image: UIImage) -> UIImage? {
    guard let model = try? face_paint_512_v2_fixed(configuration: .init()) else {
        print("Model yüklenemedi.")
        return nil
    }
    
    guard let resized = image.resized(to: CGSize(width: 512, height: 512)),
          let inputArray = resized.toFloatArray() else {
        print("Resim dönüştürülemedi.")
        return nil
    }
    
    guard let output = try? model.prediction(x: inputArray),
          let outputImage = UIImage.fromFloatArray(output.var_408) else {
        print("Model çıktısı alınamadı.")
        return nil
    }

    return outputImage
}

// MARK: - Giriş Dönüştürücü
extension UIImage {
    func resized(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        defer { UIGraphicsEndImageContext() }
        self.draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    func toFloatArray() -> MLMultiArray? {
        guard let cgImage = self.cgImage else { return nil }

        let width = 512
        let height = 512

        guard let array = try? MLMultiArray(shape: [1, 3, 512, 512], dataType: .float32) else {
            return nil
        }

        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        ) else {
            return nil
        }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        guard let buffer = context.data else { return nil }

        let pixelBuffer = buffer.bindMemory(to: UInt8.self, capacity: width * height * 4)

        for y in 0..<height {
            for x in 0..<width {
                let pixelIndex = (y * width + x) * 4
                let r = Float32(pixelBuffer[pixelIndex]) / 255.0
                let g = Float32(pixelBuffer[pixelIndex + 1]) / 255.0
                let b = Float32(pixelBuffer[pixelIndex + 2]) / 255.0

                array[[0, 0, y as NSNumber, x as NSNumber]] = NSNumber(value: r)
                array[[0, 1, y as NSNumber, x as NSNumber]] = NSNumber(value: g)
                array[[0, 2, y as NSNumber, x as NSNumber]] = NSNumber(value: b)
            }
        }

        return array
    }
}

// MARK: - Çıkış Dönüştürücü
extension UIImage {
    static func fromFloatArray(_ array: MLMultiArray) -> UIImage? {
        let height = 512
        let width = 512
        
        let byteCount = width * height * 4
        var pixelData = [UInt8](repeating: 0, count: byteCount)

        let pointer = UnsafeMutablePointer<Float32>(OpaquePointer(array.dataPointer))
        
        for y in 0..<height {
            for x in 0..<width {
                let index = y * width + x
                let r = pointer[0 * width * height + index]
                let g = pointer[1 * width * height + index]
                let b = pointer[2 * width * height + index]
                
                let offset = index * 4
                pixelData[offset] = 255 // Alpha
                pixelData[offset + 1] = UInt8(max(0, min(255, r * 255)))
                pixelData[offset + 2] = UInt8(max(0, min(255, g * 255)))
                pixelData[offset + 3] = UInt8(max(0, min(255, b * 255)))
            }
        }

        let provider = CGDataProvider(data: Data(pixelData) as CFData)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.first.rawValue)
        
        if let cgImage = CGImage(
            width: width,
            height: height,
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo,
            provider: provider!,
            decode: nil,
            shouldInterpolate: false,
            intent: .defaultIntent
        ) {
            return UIImage(cgImage: cgImage)
        }

        return nil
    }
}
