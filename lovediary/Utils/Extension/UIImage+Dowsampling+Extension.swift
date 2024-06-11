//
//  UIImage+Dowsampling+Extension.swift
//  lovediary
//
//  Created by daovu on 12/03/2021.
//

import UIKit

struct ImageIOConverter {
    static func resize(url: URL) -> UIImage {
        
        guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            fatalError("Can not get imageSource")
        }
        
        let options: [NSString: Any]  = [
            kCGImageSourceThumbnailMaxPixelSize: 300,
            kCGImageSourceCreateThumbnailFromImageAlways: true
        ]
        
        guard let scaledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary) else {
            fatalError("Can not get scaledImage")
        }
        
        return UIImage(cgImage: scaledImage)
    }
}

extension UIImage {
    func resize(size: CGSize = CGSize(width: 300, height: 300)) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        let resizedImage = renderer.image { _ in
            draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        }
        return resizedImage
    }
}

extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    func jpeg(_ jpegQuality: JPEGQuality) -> Data? {
        return jpegData(compressionQuality: jpegQuality.rawValue)
    }
    
    func tintColor(with color: UIColor) -> UIImage {
        var image = withRenderingMode(.alwaysTemplate)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        color.set()
        
        image.draw(in: CGRect(origin: .zero, size: size))
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    func merge(with image: UIImage) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        image.draw(in: CGRect(origin: .zero, size: size))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func scaleTo(size targetSize: CGSize) -> UIImage? {
        let oldSize = self.size
        let widthRatio  = targetSize.width  / oldSize.width
        let heightRatio = targetSize.height / oldSize.height
        
        if widthRatio > heightRatio {
            return self.scaleTo(widthRatio: heightRatio, heightRatio: heightRatio)
        } else {
            return self.scaleTo(widthRatio: widthRatio, heightRatio: widthRatio)
        }
    }
    
    func scaleTo(widthRatio: CGFloat, heightRatio: CGFloat) -> UIImage? {
        let oldSize = self.size
        let newSize = CGSize(width: oldSize.width * widthRatio, height: oldSize.height * widthRatio)
        let frame = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: frame)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
