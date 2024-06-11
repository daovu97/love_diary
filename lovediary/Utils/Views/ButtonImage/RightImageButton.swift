//
//  RightImageButton.swift
//  lovediary
//
//  Created by daovu on 11/03/2021.
//

import UIKit

@IBDesignable
class RightImageButton: BaseView {
    lazy var titleLable: IncreaseHeightLabel = {
        let label = IncreaseHeightLabel()
        label.font = Fonts.getHiraginoSansFont(fontSize: 18, fontWeight: .bold)
        label.text = self.title
        return label
    }()
    
    private lazy var iconImageView: UIImageView = {
        let image = UIImageView()
        image.image = self.image
        image.tintColor = self.imageColor
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    @IBInspectable
    var image: UIImage? = UIImage(named: "ic_male")
    
    @IBInspectable
    var title: String = "Fe"
    
    @IBInspectable
    var imageColor: UIColor? = .systemBlue
    
    @IBInspectable
    var deselectedColor: UIColor? = .lightGray
    
    var isSelected: Bool = false {
        didSet {
            if isSelected {
                setSelected()
            } else {
                deSelected()
            }
        }
    }
    
    private func setSelected() {
        titleLable.textColor = Colors.textColor
        iconImageView.tintColor = self.imageColor
        alpha = 1
    }
    
    private func deSelected() {
        titleLable.textColor = deselectedColor
        iconImageView.tintColor = deselectedColor
        self.alpha = 0.6
    }
    
    override func setupUI() {
        super.setupUI()
        backgroundColor = .clear
        let stack = UIStackView(arrangedSubviews: [titleLable, iconImageView])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.alignment = .fill
        stack.axis = .horizontal
        stack.spacing = 16
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.heightAnchor.constraint(equalTo: iconImageView.widthAnchor)
        ])
        titleLable.text = self.title
        iconImageView.tintColor = self.imageColor
        isSelected = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        iconImageView.image = self.image
        titleLable.text = self.title
    }
}
