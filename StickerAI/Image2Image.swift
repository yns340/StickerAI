import UIKit
import CoreVideo
import CoreImage
import CoreML

// MARK: - UIImage Extensions

extension UIImage {
    // Resmi istenilen boyuta ölçekle
    func resized(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, self.scale)
        defer { UIGraphicsEndImageContext() }
        self.draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    // UIImage'ı CVPixelBuffer'a dönüştürür
    func toCVPixelBuffer() -> CVPixelBuffer? {
        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue!,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue!
        ] as CFDictionary
        
        let width = Int(self.size.width)
        let height = Int(self.size.height)
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         width,
                                         height,
                                         kCVPixelFormatType_32ARGB,
                                         attrs,
                                         &pixelBuffer)
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(buffer, [])
        let pixelData = CVPixelBufferGetBaseAddress(buffer)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: pixelData,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
                                      space: colorSpace,
                                      bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        else {
            CVPixelBufferUnlockBaseAddress(buffer, [])
            return nil
        }
        
        // CoreGraphics koordinat sistemi ile UIKit koordinat sistemi arasındaki farkı düzelt
        context.translateBy(x: 0, y: CGFloat(height))
        context.scaleBy(x: 1, y: -1)
        
        UIGraphicsPushContext(context)
        self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        UIGraphicsPopContext()
        
        CVPixelBufferUnlockBaseAddress(buffer, [])
        
        return buffer
    }
    
    // CVPixelBuffer'dan UIImage oluşturur
    convenience init?(pixelBuffer: CVPixelBuffer) {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return nil
        }
        self.init(cgImage: cgImage)
    }
}

// MARK: - Cartoonize Fonksiyonu

func cartoonizeImage(_ input: UIImage) -> UIImage? {
    // Modelin beklediği input boyutu (1536x1536)
    let targetSize = CGSize(width: 1536, height: 1536)
    
    // Önce resmi yeniden boyutlandır
    guard let resizedImage = input.resized(to: targetSize),
          let buffer = resizedImage.toCVPixelBuffer(),
          let model = try? whiteboxcartoonization(configuration: MLModelConfiguration()),
          let output = try? model.prediction(Placeholder: buffer) else {
        print("Cartoonization işleminde hata oluştu")
        return nil
    }
    
    // Modelden dönen CVPixelBuffer'ı UIImage'a çevir
    return UIImage(pixelBuffer: output.activation_out)
}


