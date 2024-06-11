//
//  UIView+Constrain+Extension.swift
//  AutoLayoutEx2
//
//  Created by daovu on 9/1/20.
//  Copyright © 2020 daovu. All rights reserved.
//

import Foundation

import UIKit

struct AnchoredConstraints {
  var top, leading, bottom, trailing, width, height: NSLayoutConstraint?
}

extension UIView {

  @discardableResult
  func anchor(top: NSLayoutYAxisAnchor?, leading: NSLayoutXAxisAnchor?,
              bottom: NSLayoutYAxisAnchor?, trailing: NSLayoutXAxisAnchor?,
              padding: UIEdgeInsets = .zero, size: CGSize = .zero) -> AnchoredConstraints {

    translatesAutoresizingMaskIntoConstraints = false
    var anchoredConstraints = AnchoredConstraints()

    if let top = top {
      anchoredConstraints.top = topAnchor.constraint(equalTo: top, constant: padding.top)
    }

    if let leading = leading {
      anchoredConstraints.leading = leadingAnchor.constraint(equalTo: leading, constant: padding.left)
    }

    if let bottom = bottom {
      anchoredConstraints.bottom = bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom)
    }

    if let trailing = trailing {
      anchoredConstraints.trailing = trailingAnchor.constraint(equalTo: trailing, constant: -padding.right)
    }

    if size.width != 0 {
      anchoredConstraints.width = widthAnchor.constraint(equalToConstant: size.width)
    }

    if size.height != 0 {
      anchoredConstraints.height = heightAnchor.constraint(equalToConstant: size.height)
    }

    [anchoredConstraints.top, anchoredConstraints.leading,
     anchoredConstraints.bottom, anchoredConstraints.trailing,
     anchoredConstraints.width, anchoredConstraints.height].forEach { $0?.isActive = true }

    return anchoredConstraints
  }

  func fillSuperview(padding: UIEdgeInsets = .zero) {
    translatesAutoresizingMaskIntoConstraints = false
    if let superviewTopAnchor = superview?.topAnchor {
      topAnchor.constraint(equalTo: superviewTopAnchor, constant: padding.top).isActive = true
    }

    if let superviewBottomAnchor = superview?.bottomAnchor {
      bottomAnchor.constraint(equalTo: superviewBottomAnchor, constant: -padding.bottom).isActive = true
    }

    if let superviewLeadingAnchor = superview?.leadingAnchor {
      leadingAnchor.constraint(equalTo: superviewLeadingAnchor, constant: padding.left).isActive = true
    }

    if let superviewTrailingAnchor = superview?.trailingAnchor {
      trailingAnchor.constraint(equalTo: superviewTrailingAnchor, constant: -padding.right).isActive = true
    }
  }

  func centerInSuperview(size: CGSize = .zero) {
    translatesAutoresizingMaskIntoConstraints = false
    if let superviewCenterXAnchor = superview?.centerXAnchor {
      centerXAnchor.constraint(equalTo: superviewCenterXAnchor).isActive = true
    }

    if let superviewCenterYAnchor = superview?.centerYAnchor {
      centerYAnchor.constraint(equalTo: superviewCenterYAnchor).isActive = true
    }

    if size.width != 0 {
      widthAnchor.constraint(equalToConstant: size.width).isActive = true
    }

    if size.height != 0 {
      heightAnchor.constraint(equalToConstant: size.height).isActive = true
    }
  }

}

extension UIView {
 
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
 
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
 
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}

extension UIView {
    func addBlur(style: UIBlurEffect.Style) {
        if subviews.contains(where: { view -> Bool in
            return view is UIVisualEffectView
        }) { return }
        let blurEffect = UIBlurEffect(style: style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = bounds
        blurEffectView.alpha = 0.4
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurEffectView)
    }
}

extension UIImageView {
    func applyshadowWithCorner(containerView: UIView, cornerRadious: CGFloat) {
        containerView.clipsToBounds = false
        containerView.layer.apply {
            $0.shadowColor = UIColor.black.cgColor
            $0.shadowOpacity = 0.3
            $0.shadowOffset = CGSize(width: 0.0, height: 3.0)
            $0.shadowRadius = 3
            $0.cornerRadius = cornerRadious
            $0.shadowPath = UIBezierPath(roundedRect: containerView.bounds,
                                         cornerRadius: cornerRadious).cgPath
        }
        self.clipsToBounds = true
        self.layer.cornerRadius = cornerRadious
    }
}

extension UIViewController {
    /// Call this once to dismiss open keyboards by tapping anywhere in the view controller
    func setupHideKeyboardOnTap() {
        self.view.addGestureRecognizer(self.endEditingRecognizer())
        self.navigationController?.navigationBar.addGestureRecognizer(self.endEditingRecognizer())
    }

    /// Dismisses the keyboard from self.view
    private func endEditingRecognizer() -> UIGestureRecognizer {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(self.view.endEditing(_:)))
        tap.cancelsTouchesInView = false
        return tap
    }
}
