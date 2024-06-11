//
//  IncreaseHeightLabel.swift
//  lovediary
//
//  Created by vu dao on 24/03/2021.
//

import UIKit

class IncreaseHeightLabel: UILabel {
    override var intrinsicContentSize: CGSize {
        let original = super.intrinsicContentSize
        return .init(width: original.width, height: original.height + 6)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        invalidateIntrinsicContentSize()
    }
}

class DiaryDateTitle: UILabel {
    override var intrinsicContentSize: CGSize {
        let original = super.intrinsicContentSize
        return .init(width: original.width + 24, height: original.height + 16)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        invalidateIntrinsicContentSize()
    }
}
