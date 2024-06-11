//
//  ThumpBackgroundCell.swift
//  lovediary
//
//  Created by vu dao on 13/03/2021.
//

import UIKit
import SDWebImage

class ThumpBackgroundCell: UICollectionViewCell {
    
    private lazy var backgroundImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        return image
    }()
    
    private lazy var coverSelectedView: UIView = {
        let view = UIView()
        let tickImage = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        tickImage.tintColor = Colors.toneColor
        view.addSubview(tickImage)
        let width = self.contentView.bounds.width - 10
        tickImage.centerInSuperview(size: .init(width: width, height: width))
        view.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        return view
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
        contentView.addSubview(backgroundImage)
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            backgroundImage.topAnchor.constraint(equalTo: contentView.topAnchor)
        ])
        contentView.clipsToBounds = true
        contentView.addSubview(coverSelectedView)
        coverSelectedView.fillSuperview()
        contentView.cornerWithBorder(cornerRadius: 8, borderWidth: 0, borderColor: .clear)
    }
    
    func bind(to background: BackgroundPresentModel, selected: Bool = false) {
        contentView.backgroundColor = .clear
        let frame = contentView.frame
        backgroundImage.image = background.image?.resize(size: .init(width: frame.width, height: frame.height))
        coverSelectedView.isHidden = !selected
        backgroundImage.contentMode = .scaleAspectFill
    }
    
    func bindToPlus() {
        coverSelectedView.isHidden = true
        contentView.backgroundColor = UIColor.init(white: 0.9, alpha: 0.5)
        backgroundImage.image = Images.Icon.plus
        backgroundImage.tintColor = Colors.toneColor
        backgroundImage.contentMode = .center
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        backgroundImage.contentMode = .scaleAspectFill
        coverSelectedView.isHidden = true
    }
}
