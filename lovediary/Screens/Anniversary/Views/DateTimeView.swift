//
//  DateTimeView.swift
//  lovediary
//
//  Created by daovu on 10/03/2021.
//

import Foundation
import UIKit

class DateTimeView: BaseView {
    
    private lazy var detailTextLabel: IncreaseHeightLabel = {
        let label = IncreaseHeightLabel()
        label.font = Fonts.primaryBoldFont
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.text = ""
        label.textColor = .white
        label.contentMode = .center
        label.textAlignment = .center
        return label
    }()
    
    private lazy var backgroundImage: UIImageView = {
        let image = UIImageView(image: Images.Icon.hearIcon)
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    lazy var textLabel: IncreaseHeightLabel = {
        let label = IncreaseHeightLabel()
        label.font = Fonts.primaryBoldFont
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.text = ""
        label.textColor = .white
        label.contentMode = .center
        label.textAlignment = .center
        return label
    }()
    
    init(frame: CGRect = .zero, name: String) {
        super.init(frame: frame)
        detailTextLabel.text = name
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        detailTextLabel.text = ""
    }
    
    override func setupUI() {
        super.setupUI()
        addSubview(backgroundImage)
        addSubview(textLabel)
        addSubview(detailTextLabel)
        
        [backgroundImage.topAnchor.constraint(equalTo: topAnchor),
         backgroundImage.leadingAnchor.constraint(equalTo: leadingAnchor),
         backgroundImage.trailingAnchor.constraint(equalTo: trailingAnchor),
         backgroundImage.heightAnchor.constraint(equalTo: backgroundImage.widthAnchor)]
            .forEach { $0.isActive = true }
        
        [textLabel.topAnchor.constraint(equalTo: topAnchor, constant: 3),
         textLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
         textLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
         textLabel.heightAnchor.constraint(equalTo: textLabel.widthAnchor)]
            .forEach { $0.isActive = true }
        
        [detailTextLabel.topAnchor.constraint(equalTo: backgroundImage.bottomAnchor),
         detailTextLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
         detailTextLabel.trailingAnchor.constraint(equalTo: trailingAnchor)]
            .forEach { $0.isActive = true }
    }
    
    func setImage(icon: UIImage) {
        backgroundImage.image = icon
    }
    
    func setImageColor(color: UIColor) {
        backgroundImage.tintColor = color
    }
    
    func setTextColor(color: UIColor) {
        textLabel.textColor = color
    }
    
    func setTextFont(font: UIFont) {
        textLabel.font = font
    }
    
    func setDetailTextColor(color: UIColor) {
        detailTextLabel.textColor = color
    }
}
