//
//  ClearToolBar.swift
//  QikNote
//
//  Created by daovu on 04/03/2021.
//

import UIKit

@IBDesignable
class ClearToolBar: UIToolbar {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    func setupView() {
        setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        setShadowImage(UIImage(), forToolbarPosition: .any)
        backgroundColor = .clear
    }
}
