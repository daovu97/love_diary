//
//  UILabel+Extension.swift
//  lovediary
//
//  Created by vu dao on 28/03/2021.
//

import Foundation
import UIKit

extension UILabel {
    func setFontSize(_ size: CGFloat) {
        self.font = UIFont(name: font.fontName, size: size)
    }
    
    func setFontName(_ name: String) {
        self.font = UIFont(name: name, size: font.pointSize)
    }
    
    func highlight(text: String, color: UIColor) {
        guard let textLabel = self.text else { return }
        let attributedString = NSMutableAttributedString(string: textLabel)
        do {
            let regex = try NSRegularExpression(pattern: text.trimmingCharacters(in: .whitespacesAndNewlines), options: .caseInsensitive)
            let range = NSRange(location: 0, length: textLabel.count)
            for match in regex.matches(in: textLabel, options: .withTransparentBounds, range: range) {
                attributedString.addAttribute(NSAttributedString.Key.backgroundColor, value: color, range: match.range)
            }
            self.attributedText = attributedString
        } catch {
            NSLog("Error creating regular expresion: \(error)")
        }
    }
    
    func removeHightLight() {
        guard let textLabel = self.text else { return }
        let attributedString = NSMutableAttributedString(string: textLabel)
        let range = NSRange(location: 0, length: textLabel.count)
        attributedString.addAttribute(NSAttributedString.Key.backgroundColor, value: UIColor.clear, range: range)
        self.attributedText = attributedString
    }
    
    func setLineSpacing(_ spacing: CGFloat, alignment: NSTextAlignment = .natural) {
        guard let labelText = self.text else { return }
        guard let attributedString = self.attributedText else { return }
        
        let mutatedString = NSMutableAttributedString(attributedString: attributedString)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = spacing
        paragraphStyle.alignment = alignment
        let range = NSRange(location: 0, length: labelText.count)
        mutatedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: range)
        self.attributedText = mutatedString
    }
    
    func highlight(keys: [String], color: UIColor) {
        guard let textLabel = self.text else { return }
        for key in keys {
            guard let attributedString = self.attributedText else { return }
            do {
                let mutatedString = NSMutableAttributedString(attributedString: attributedString)
                let regex = try NSRegularExpression(pattern: key.trimmingCharacters(in: .whitespacesAndNewlines), options: .caseInsensitive)
                let range = NSRange(location: 0, length: textLabel.count)
                for match in regex.matches(in: textLabel, options: .withTransparentBounds, range: range) {
                    mutatedString.addAttribute(NSAttributedString.Key.backgroundColor, value: color, range: match.range)
                }
                self.attributedText = mutatedString
            } catch {
                NSLog("Error creating regular expresion: \(error)")
            }
        }
    }
    
    func getFontSize() -> CGFloat {
        let text: NSMutableAttributedString = NSMutableAttributedString(attributedString: self.attributedText!)
        if let font = font {
            text.setAttributes([NSAttributedString.Key.font: font],
                               range: NSRange(location: 0, length: text.length))
        }
        
        let context: NSStringDrawingContext = NSStringDrawingContext()
        
        context.minimumScaleFactor = self.minimumScaleFactor
        
        text.boundingRect(with: self.frame.size,
                          options: NSStringDrawingOptions.usesLineFragmentOrigin,
                          context: context)
        
        let adjustedFontSize: CGFloat = self.font.pointSize * context.actualScaleFactor
        return adjustedFontSize
    }
    
    func highlightTextColor(keys: [String], color: UIColor) {
        guard let textLabel = self.text else { return }
        for key in keys {
            guard let attributedString = self.attributedText else { return }
            do {
                let mutatedString = NSMutableAttributedString(attributedString: attributedString)
                let regex = try NSRegularExpression(pattern: key.trimmingCharacters(in: .whitespacesAndNewlines), options: .caseInsensitive)
                let range = NSRange(location: 0, length: textLabel.count)
                for match in regex.matches(in: textLabel, options: .withTransparentBounds, range: range) {
                    mutatedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: match.range)
                }
                self.attributedText = mutatedString
            } catch {
                NSLog("Error creating regular expresion: \(error)")
            }
        }
    }
}

extension UILabel {
    func setAttributedString(font: UIFont? = nil, foregroundColor: UIColor? = nil, lineSpacing: CGFloat? = nil, characterSpacing: CGFloat? = nil) {
        guard let labelText = text else { return }
        
        let attributedString: NSMutableAttributedString
        if let attributedText = attributedText {
            attributedString = NSMutableAttributedString(attributedString: attributedText)
        } else {
            attributedString = NSMutableAttributedString(string: labelText)
        }
        
        if let font = font {
            attributedString.addAttribute(NSAttributedString.Key.font,
                                          value: font,
                                          range: NSRange(location: 0,
                                                         length: attributedString.length))
        }
        
        if let foregroundColor = foregroundColor {
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                          value: foregroundColor,
                                          range: NSRange(location: 0,
                                                         length: attributedString.length))
        }
        
        if let lineSpacing = lineSpacing {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = lineSpacing
            paragraphStyle.lineBreakMode = lineBreakMode
            paragraphStyle.alignment = textAlignment
            
            attributedString.addAttribute(NSAttributedString.Key.paragraphStyle,
                                          value: paragraphStyle,
                                          range: NSRange(location: 0,
                                                         length: attributedString.length))
        }
        
        if let characterSpacing = characterSpacing {
            attributedString.addAttribute(NSAttributedString.Key.kern,
                                          value: characterSpacing,
                                          range: NSRange(location: 0,
                                                         length: attributedString.length))
        }
        
        attributedText = attributedString
    }
}

