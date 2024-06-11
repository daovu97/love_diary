//
//  GaleryImageCollectionViewCell.swift
//  lovediary
//
//  Created by vu dao on 21/03/2021.
//

import UIKit
import SDWebImage

class GaleryImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    func bind(image: ImageAttachment) {
        imageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        imageView.sd_setImage(with: image.getImageUrl())
    }
}
