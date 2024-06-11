//
//  SearchBarView.swift
//  lovediary
//
//  Created by vu dao on 28/03/2021.
//

import Foundation
import UIKit

class IncreaseHeightTextField: UITextField {
    override var intrinsicContentSize: CGSize {
        let original = super.intrinsicContentSize
        return .init(width: original.width, height: original.height + 6)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        invalidateIntrinsicContentSize()
    }
}

class SearchBarView: UIView {
    lazy var textField: IncreaseHeightTextField = {
        let textField = IncreaseHeightTextField()
        textField.returnKeyType = .done
        textField.attributedPlaceholder = NSAttributedString(string: LocalizedString.searchDiaryPlaceHolder,
                                                             attributes: [.foregroundColor: UIColor(white: 0.9, alpha: 0.9)])
        textField.clearButtonMode = .whileEditing
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: textField.bounds.height))
        textField.leftView = leftView
        textField.leftViewMode = .always
        textField.font = Fonts.getHiraginoSansFont(fontSize: 16, fontWeight: .regular)
        var imageView = UIImageView(image: Images.Icon.search)
        imageView.image = Images.Icon.search
        imageView.tintColor = .white
        leftView.addSubview(imageView)
        imageView.anchor(top: leftView.topAnchor, leading: leftView.leadingAnchor,
                         bottom: leftView.bottomAnchor, trailing: leftView.trailingAnchor,
                         padding: .init(top: 8, left: 8, bottom: 8, right: 8))
        return textField
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initViews()
    }
    
    private func initViews() {
        setupViews()
        setupThemeColor()
    }
    
    private func setupViews() {
        textField.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textField)
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: topAnchor),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor)
        ])
        layer.cornerRadius = 12
        textField.becomeFirstResponder()
    }
    
    private func setupThemeColor() {
        backgroundColor = Colors.toneColor.withAlphaComponent(0.6)
        textField.textColor = .white
    }
    
    @objc private func applyTheme() {
        setupThemeColor()
    }
}

