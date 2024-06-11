//
//  NSAttributedString+Extension.swift
//  lovediary
//
//  Created by vu dao on 18/03/2021.
//

import UIKit

extension NSAttributedString {
    var images: [UIImage] {
        var result: [UIImage] = []
        self.enumerateAttribute(.attachment, in: NSRange(location: 0, length: length), options: []) { (value, range, stop) in
            if let attachment = value as? NSTextAttachment, let image = attachment.image {
                result.append(image)
            }
        }
        return result
    }
    
    func removeImages() -> NSAttributedString {
        var ranges: [NSRange] = []
        self.enumerateAttribute(.attachment, in: NSRange(location: 0, length: length), options: []) { (value, range, stop) in
            if let attachment = value as? NSTextAttachment, attachment.image != nil {
                ranges.append(range)
            }
        }
        let mutableAttributedString = NSMutableAttributedString(attributedString: self)
        for index in 0..<ranges.count {
            mutableAttributedString.replaceCharacters(in: ranges[index], with: "")
            if index + 1 < ranges.count {
                for i in (index + 1)..<ranges.count {
                    ranges[i].location = max(ranges[i].location - ranges[index].length, 0)
                }
            }
        }
        return mutableAttributedString
    }
    
    func replaceImageWithWhitespace() -> (newAttributedString: NSAttributedString, imageInfos: [(range: NSRange, image: UIImage)]) {
        var imageInfos: [(range: NSRange, image: UIImage)] = []
        self.enumerateAttribute(.attachment, in: NSRange(location: 0, length: length), options: []) { (value, range, stop) in
            if let attachment = value as? NSTextAttachment, let image = attachment.image {
                imageInfos.append((range: range, image: image))
            }
        }
        let newAttributedString = NSMutableAttributedString(attributedString: self)
        for imageInfo in imageInfos {
            newAttributedString.replaceCharacters(in: imageInfo.range, with: String(repeating: " ", count: imageInfo.range.length))
        }
        return (newAttributedString: newAttributedString, imageInfos: imageInfos)
    }
    
    func getFirstLineRange() -> NSRange? {
        return self.string.getFirstLineRange()
    }
    
    func fitImage(with ratio: CGFloat) -> NSAttributedString {
        self.enumerateAttribute(.attachment, in: NSRange(location: 0, length: length), options: []) { (value, range, stop) in
            if let attachment = value as? NSTextAttachment, let image = attachment.image {
                 attachment.image = image.scaleTo(widthRatio: ratio, heightRatio: ratio)
            }
        }
        return self
    }
    
    func fitImageToWindow(with newWidth: CGFloat) -> NSAttributedString {
        self.enumerateAttribute(.attachment, in: NSRange(location: 0, length: length), options: []) { (value, range, stop) in
            if let attachment = value as? NSTextAttachment, let image = attachment.image {
                let imageWidth = image.size.width
                let ratio = newWidth/imageWidth
                attachment.image = image.scaleTo(widthRatio: ratio, heightRatio: ratio)
            }
        }
        return self
    }
    
    func getAllImage() -> [UIImage] {
        self.enumerateAttribute(.attachment, in: NSRange(location: 0, length: length), options: []) { (value, range, stop) in
            var images: [UIImage] = []
            if let attachment = value as? NSTextAttachment, let image = attachment.image {
                images.append(image)
            }
        }
        return images
    }
}

extension String {
    func getFirstLineRange() -> NSRange? {
        let firstLine = self
            .components(separatedBy: .newlines)
            .compactMap({ $0 }).first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard let range = self.range(of: firstLine) else { return nil }
        let nsRange = NSRange(range, in: self)
        return nsRange
    }
    
    func substring(with range: NSRange) -> Substring? {
        guard let range = Range(range, in: self) else { return nil }
        return self[range]
    }
    
    func splistFirstLine() -> (first: String, detail: String) {
        var arrayLine = self.components(separatedBy: .newlines).compactMap({ $0 })
        var first = ""
        var detail = ""
        if let firstLine = arrayLine.first?.trimmingCharacters(in: .whitespacesAndNewlines) {
            first = firstLine
            arrayLine.removeFirst()
            detail = arrayLine.joined()
        }
       
        return (first, detail)
        
    }
}
