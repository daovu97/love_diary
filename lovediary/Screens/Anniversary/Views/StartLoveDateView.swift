//
//  StartLoveDateView.swift
//  lovediary
//
//  Created by daovu on 10/03/2021.
//

import Foundation
import UIKit
import Combine

class StartLoveDateView: BaseView, ThemeNotification {
    var subscription: AnyCancellable?
    
    func themeChange() {
        applyTheme()
    }
    
    private lazy var startDateLabel: IncreaseHeightLabel = {
       let label = IncreaseHeightLabel()
        label.font = Fonts.primaryBoldFont
        label.text = "15/05/2014"
        return label
    }()

    override func setupUI() {
        super.setupUI()
        let stack = UIStackView(arrangedSubviews: [startDateLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.alignment = .center
        stack.axis = .horizontal
        stack.spacing = 8
        addSubview(stack)
        stack.centerInSuperview()
        applyTheme()
        addThemeObserver()
    }
    
    private func applyTheme() {
        startDateLabel.textColor = Colors.toneColor
    }
    
    func setStartDate(date: String) {
        startDateLabel.text = date
    }
    
    func setTextColor(_ color: UIColor) {
        startDateLabel.textColor = color
    }
    
    deinit {
       removeThemeObserver()
    }
  
}
