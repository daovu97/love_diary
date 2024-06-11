//
//  AttachmentTextView.swift
//  lovediary
//
//  Created by vu dao on 17/03/2021.
//

import Foundation
import UIKit

protocol AttachmentTextViewDelegate: class {
    func tappedAttachment(_ attachemnt: NSTextAttachment)
}

class PasteTextView: UITextView {
    var isPastingText: Bool = false
    
    override func paste(_ sender: Any?) {
        isPastingText = true
        super.paste(sender)
    }
}

class AttachmentTextView: PasteTextView {
        
        override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
            guard action == #selector(selectAll(_:)) else {
                return super.canPerformAction(action, withSender: sender)
            }
            return true
        }
        
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            if !isEditable && selectedTextRange?.start == beginningOfDocument && selectedTextRange?.end == endOfDocument {
                selectedTextRange = textRange(from: endOfDocument, to: endOfDocument)
            }
        }

        weak var attachmentDelegate: AttachmentTextViewDelegate?
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            // fix touch on attachment text in ios 13.1 and above
            // if ios is fixxing this problem. Please remove this code
            addAttachRecognizer()
        }
        
        override init(frame: CGRect, textContainer: NSTextContainer?) {
            super.init(frame: frame, textContainer: textContainer)
            // fix touch on attachment text in ios 13.1 and above
            // if ios is fixxing this problem. Please remove this code
            addAttachRecognizer()
        }

    override func caretRect(for position: UITextPosition) -> CGRect {
        var rect = super.caretRect(for: position)
        guard let font = self.font else {
            return rect
        }
        //Calculating cursor size base on text font
        let size = CGSize(width: rect.width, height: font.pointSize - font.descender)
        //check if current cursor height is smaller than 5 times line height
        //if true, cursor is in an image, return current cursor size
        //if false, return calculated cursor
        if rect.height < font.lineHeight * 3 || font.pointSize < 12 {
            rect = CGRect(origin: CGPoint(x: rect.origin.x, y: rect.origin.y), size: size)
        }
        return rect
    }
    
    private func addAttachRecognizer() {
        // fix touch on attachment text in ios 13.1 and above
        // if ios is fixxing this problem. Please remove this code
        if #available(iOS 13.1, *) {
            let attachmentRecognizer = AttachmentTapGestureRecognizer(target: self, action: #selector(handleAttachmentTap(_:)))
            addAttacthRecognizer(attachmentRecognizer)
        }
    }
    
    @IBAction func handleAttachmentTap(_ sender: AttachmentTapGestureRecognizer) {
        guard let tappedState = sender.tappedState else { return }
        attachmentDelegate?.tappedAttachment(tappedState.attachment)
    }
}

extension AttachmentTextView {
    /// Add an attachment recognizer to a UITTextView
    func addAttacthRecognizer(_ attachmentRecognizer: AttachmentTapGestureRecognizer) {
        for other in gestureRecognizers ?? [] {
            other.require(toFail: attachmentRecognizer)
        }
        addGestureRecognizer(attachmentRecognizer)
    }
}

extension AttachmentTextView {
    func getTextViewScreenShot(updateConstraintHandler: (() -> Void)? = nil) -> UIImage? {
        let savedContentOffset = self.contentOffset
        let savedFrame = self.frame
        
        self.contentOffset = .zero
        self.frame = CGRect(x: 0, y: 0, width: self.contentSize.width, height: self.contentSize.height)
        
        let tempView = UIView(frame: CGRect(x: 0, y: 0, width: self.contentSize.width, height: self.contentSize.height))
        let tempSuperView = self.superview
        self.removeFromSuperview()
        tempView.addSubview(self)

        let image = tempView.getScreenShot()
        
        self.contentOffset = savedContentOffset
        self.frame = savedFrame

        tempView.subviews[0].removeFromSuperview()
        tempSuperView?.addSubview(self)
        
        if let superView = self.superview {
            NSLayoutConstraint.activate([
                self.topAnchor.constraint(equalTo: superView.topAnchor),
                self.leadingAnchor.constraint(equalTo: superView.leadingAnchor),
                self.trailingAnchor.constraint(equalTo: superView.trailingAnchor),
                self.bottomAnchor.constraint(equalTo: superView.bottomAnchor)
            ])
            superView.layoutIfNeeded()
        }
      
        return image
    }
}

extension UIView {
    func getScreenShot() -> UIImage? {
        let contentSize = self.size
        UIGraphicsBeginImageContextWithOptions(contentSize, false, 0.0)
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        self.layer.render(in: context)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    func asImage() -> UIImage? {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
            return renderer.image { rendererContext in
                layer.render(in: rendererContext.cgContext)
            }
        } else {
            UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0.0)
            defer { UIGraphicsEndImageContext() }
            guard let currentContext = UIGraphicsGetCurrentContext() else {
                return nil
            }
            self.layer.render(in: currentContext)
            return UIGraphicsGetImageFromCurrentImageContext()
        }
    }
    
    func removeAllSubviews() {
        self.subviews.forEach({ $0.removeFromSuperview() })
    }
    
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = offSet
        self.layer.shadowRadius = radius
        
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: 10).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    func scaleWithBounce(in duration: TimeInterval, springDamping: CGFloat, isShow: Bool = true) {
        let options: UIView.AnimationOptions = isShow ? .curveEaseOut : .curveLinear
        let transform: CGAffineTransform = isShow ? CGAffineTransform.identity : CGAffineTransform(scaleX: 0.01, y: 0.01)
        UIView.animate(withDuration: duration, delay: 0.0,
                       usingSpringWithDamping: springDamping,
                       initialSpringVelocity: 0.0,
                       options: options,
                       animations: { [weak self] in
                        guard let self = self else { return }
                        self.transform = transform
            }, completion: { [weak self] _ in
                guard let self = self, !isShow else { return }
                self.isHidden = true
        })
    }
    
    
    func swipeAnimation(isSwipeLeft: Bool, duration: TimeInterval = 0.5) {
        let transition = CATransition()
        transition.type = .push
        transition.subtype = isSwipeLeft ? .fromRight : .fromLeft
        transition.duration = duration
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        transition.fillMode = .removed
        self.layer.add(transition, forKey: nil)
    }
    
    func createGradientLayer(colors: [CGColor], startPoint: CGPoint, endPoint: CGPoint, cornerRadius: CGFloat) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = colors
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        gradientLayer.cornerRadius = cornerRadius
        self.layer.addSublayer(gradientLayer)
    }
    
    func fadeIn(duration: TimeInterval, completion: ((Bool) -> Void)? = nil) {
        UIView.transition(with: self, duration: duration, options: .transitionCrossDissolve, animations: {
            self.isHidden = false
        }, completion: completion)
    }
    
    func fadeOut(duration: TimeInterval, completion: ((Bool) -> Void)? = nil) {
        UIView.transition(with: self, duration: duration, options: .transitionCrossDissolve, animations: {
            self.isHidden = true
        }, completion: completion)
    }
    
    func updateConstraintsAndLayout() {
        self.setNeedsUpdateConstraints()
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
}

class AttachmentTapGestureRecognizer: UITapGestureRecognizer {
    typealias TappedAttachment = (attachment: NSTextAttachment, characterIndex: Int)

         private(set) var tappedState: TappedAttachment?

         override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
             tappedState = nil

             guard let textView = view as? UITextView else {
                 state = .failed
                 return
             }

             if let touch = touches.first {
                 tappedState = evaluateTouch(touch, on: textView)
             }

             if tappedState != nil {
                 // UITapGestureRecognizer can accurately differentiate discrete taps from scrolling
                 // Therefore, let the super view evaluate the correct state.
                 super.touchesBegan(touches, with: event)

             } else {
                 // User didn't initiate a touch (tap or otherwise) on an attachment.
                 // Force the gesture to fail.
                 state = .failed
             }
         }

         /// Tests to see if the user has tapped on a text attachment in the target text view.
         private func evaluateTouch(_ touch: UITouch, on textView: UITextView) -> TappedAttachment? {
             let point = touch.location(in: textView)
             let glyphIndex: Int = textView.layoutManager.glyphIndex(for: point, in: textView.textContainer, fractionOfDistanceThroughGlyph: nil)
             let glyphRect = textView.layoutManager.boundingRect(forGlyphRange: NSRange(location: glyphIndex, length: 1), in: textView.textContainer)
             guard glyphRect.contains(point) else {
                 return nil
             }
             let characterIndex: Int = textView.layoutManager.characterIndexForGlyph(at: glyphIndex)
             guard characterIndex < textView.textStorage.length else {
                 return nil
             }
             guard NSTextAttachment.character == (textView.textStorage.string as NSString).character(at: characterIndex) else {
                 return nil
             }
             guard let attachment = textView.textStorage.attribute(.attachment, at: characterIndex, effectiveRange: nil) as? NSTextAttachment else {
                 return nil
             }
             return (attachment, characterIndex)
         }
}

