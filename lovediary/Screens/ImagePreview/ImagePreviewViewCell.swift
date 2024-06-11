//
//  ImagePreviewViewCell.swift
//  lovediary
//
//  Created by vu dao on 21/03/2021.
//

import UIKit
import SDWebImage

class ImagePreviewViewCell: UICollectionViewCell {
    
    private lazy var imageView: ImageScrollView = {
       let imageView = ImageScrollView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.imageContentMode = .aspectFit
        imageView.initialOffset = .center
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func bind(url: URL?, image: UIImage?, tap: UITapGestureRecognizer) {
        if let url = url {
            SDWebImageManager.shared.loadImage(with: url, context: nil, progress: nil, completed: {[weak self] image,_, _, _, _, _ in
                if let image = image {
                    self?.imageView.setup()
                    self?.imageView.display(image: image)
                }
            })
        } else {
            if let image = image {
                self.imageView.setup()
                self.imageView.display(image: image)
            }
        }
        self.imageView.layoutIfNeeded()
        imageView.zoomScale = 1
        imageView.config(with: tap)
    }
    
    func resetZoom() {
        imageView.zoomScale = 1
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
