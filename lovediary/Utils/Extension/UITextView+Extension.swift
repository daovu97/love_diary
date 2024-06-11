//
//  UITextView+Extension.swift
//  lovediary
//
//  Created by vu dao on 18/03/2021.
//

import UIKit

extension UITextView {
    func insertImage(_ image: UIImage) {
        let attributedString = NSMutableAttributedString(attributedString: attributedText)
        let width = UIApplication.width
                    - textContainer.lineFragmentPadding * 2
        let textAttachment = NSTextAttachment()
        textAttachment.image = image.scaleTo(size: CGSize(width: width - 34, height: .greatestFiniteMagnitude))
        guard let cursorPosition = selectedTextRange?.start else { return }
        let offset = self.offset(from: beginningOfDocument, to: cursorPosition)
        attributedString.insert(NSAttributedString(attachment: textAttachment), at: offset)
        attributedText = attributedString
        if let newPosition = position(from: cursorPosition, offset: 1) {
            selectedTextRange = textRange(from: newPosition, to: newPosition)
        }
    }
    
    func setAttributes(_ attributes: [NSAttributedString.Key: Any]) {
        let (newAttributedString, imageInfos) = attributedText.replaceImageWithWhitespace()
        let mutableAttributedString = NSMutableAttributedString(string: newAttributedString.string, attributes: attributes)
        for imageInfo in imageInfos {
            let textAttachment = NSTextAttachment()
            textAttachment.image = imageInfo.image
            mutableAttributedString.replaceCharacters(in: imageInfo.range, with: NSAttributedString(attachment: textAttachment))
        }
        attributedText = mutableAttributedString
    }
    
    func setLinkAttributes(color: UIColor, underlineStyleRawValue: Int) {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            let matches = detector.matches(in: attributedText.string, options: [], range: NSRange(location: 0, length: attributedText.string.utf16.count))
            let mutableAttributedString = NSMutableAttributedString(attributedString: attributedText)
            for match in matches {
                mutableAttributedString.addAttribute(.foregroundColor, value: color, range: match.range)
                mutableAttributedString.addAttribute(.underlineStyle, value: underlineStyleRawValue, range: match.range)
            }
            attributedText = mutableAttributedString
        } catch {
            debugPrint("Error set link attributes")
        }
    }
    
    func setFirstLineFont(_ font: UIFont) {
        guard let range = attributedText.getFirstLineRange() else { return }
        let mutableAttributedString = NSMutableAttributedString(attributedString: attributedText)
        mutableAttributedString.addAttribute(.font, value: font, range: range)
        attributedText = mutableAttributedString
    }
    
    func insertAttributeText(text: String) {
        guard let selectedRange = selectedTextRange else {
            return
        }
        let attributedString = NSAttributedString(string: text, attributes: SettingsHelper.textViewAttributes)
        let cursorIndex = offset(from: beginningOfDocument, to: selectedRange.start)
        let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)
        mutableAttributedText.insert(attributedString, at: cursorIndex)
        attributedText = mutableAttributedText
        
        if let newPosition = position(from: selectedRange.start, offset: text.count ) {
            selectedTextRange = textRange(from: newPosition, to: newPosition)
        }
    }
    
    var currentAtBeginningOfDocument: Bool {
        guard let cursorPosition = selectedTextRange?.start else { return false }
        return compare(cursorPosition, to: beginningOfDocument) == .orderedSame
    }
    
    var currentAtEndOfDocument: Bool {
        guard let cursorPosition = selectedTextRange?.start else { return false }
        return compare(cursorPosition, to: endOfDocument) == .orderedSame
    }
    
    func characterFromCursor(offset: Int) -> String? {
        // get the cursor position
        if let cursorRange = selectedTextRange {
            // get the position one character before the cursor start position
            if let newPosition = position(from: cursorRange.start, offset: offset),
                let range = textRange(from: newPosition, to: cursorRange.start) {
                return text(in: range)
            }
        }
        return nil
    }

    var imageLocations: [Int] {
        var locations: [Int] = []
        attributedText.enumerateAttribute(.attachment, in: NSRange(location: 0, length: attributedText.length), options: []) { (value, range, stop) in
            if let attachment = value as? NSTextAttachment,
                let _ = attachment.image {
                locations.append(range.location)
            }
        }
        return locations
    }
    
    var caretLocation: Int {
        if let selectedRange = selectedTextRange {
            // cursorPosition is an Int
            return offset(from: beginningOfDocument, to: selectedRange.start)
        } else {
            return 0
        }
    }
        
    private func addLineBreakBeforeImage(image: UIImage, of imageList: [UIImage]) {
        if !currentAtBeginningOfDocument {
            if image == imageList.first {
                // check if image after another image
                if characterFromCursor(offset: -1) != "\n" || imageLocations.contains(caretLocation - 2) {
                    insertAttributeText(text: "\n")
                }
                // if cursor is next to an image before insert, insert line break
                if imageLocations.contains(caretLocation - 2) {
                    insertAttributeText(text: "\n")
                }
            } else {
                insertAttributeText(text: "\n")
            }
        }
    }

    private func addLineBreakAfterImage() {
        //if after image is before another image
        let isBeforeAnImage = imageLocations.contains(caretLocation + 2) && characterFromCursor(offset: 1) == "\n"
        if !isBeforeAnImage {
            insertAttributeText(text: "\n")
        }
    }

    private func addLineBreakAfterImageList(image: UIImage, of imageList: [UIImage]) {
        //check if image is the last image of list and at the end of textview
        let needLineBreakAtListEnd = currentAtEndOfDocument && image == imageList.last
        //check if cursor is next to an image after insert
        if needLineBreakAtListEnd || imageLocations.contains(caretLocation) {
            insertAttributeText(text: "\n")
        }
    }

    func insertImageToTextField(_ images: [UIImage]) {
    
        for image in images {
            addLineBreakBeforeImage(image: image, of: images)
            insertImage(image)
            addLineBreakAfterImage()
            addLineBreakAfterImageList(image: image, of: images)
        }
        //reset cursor position
        guard let cursorPosition = selectedTextRange?.start else { return }
        setAttributes(SettingsHelper.textViewAttributes)
        if let newPosition = position(from: cursorPosition, offset: 0) {
            selectedTextRange = textRange(from: newPosition, to: newPosition)
        }
    }
}
