//
//  ThemeCollectionViewCell.swift
//  lovediary
//
//  Created by vu dao on 23/03/2021.
//

import UIKit
import Combine

class ThemeCollectionViewCell: UICollectionViewCell{
    
    @IBOutlet weak var imageView: UIImageView!
    func bind(theme: Themes) {
        imageView.image = theme.image
    }
}
