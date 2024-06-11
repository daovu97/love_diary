//
//  PickerDetailImageCell.swift
//  lovediary
//
//  Created by vu dao on 18/03/2021.
//

import Foundation
import DKImagePickerController

class PickerDetailImageCell: DKAssetGroupDetailBaseCell {
    class override func cellReuseIdentifier() -> String {
        return "DKImageAssetIdentifier"
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.thumbnailImageView.frame = self.bounds
        self.thumbnailImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.contentView.addSubview(self.thumbnailImageView)
        
        self.checkView.frame = self.bounds
        self.checkView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.checkView.checkImageView.tintColor = nil
        self.checkView.checkLabel.font = UIFont.boldSystemFont(ofSize: 14)
        self.checkView.checkLabel.textColor = UIColor.white
        self.contentView.addSubview(self.checkView)
        self.contentView.accessibilityIdentifier = "DKImageAssetAccessibilityIdentifier"
        self.contentView.isAccessibilityElement = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // DKImageCheckView
    class DKImageCheckView: UIView {
        internal lazy var checkImageView: UIImageView = {
            var image = DKImagePickerControllerResource.checkedImage().tintColor(with: UIColor.systemPink)
            image = DKImagePickerControllerResource.stretchImgFromMiddle(image)
            let imageView = UIImageView(image: image)
            return imageView
        }()
        
        internal lazy var checkLabel: UILabel = {
            let label = UILabel()
            label.textAlignment = .right
            return label
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            self.addSubview(self.checkImageView)
            self.addSubview(self.checkLabel)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            self.checkImageView.frame = self.bounds
            self.checkLabel.frame = CGRect(x: 0, y: 5, width: self.bounds.width - 5, height: 20)
        }
    }
    
    override var thumbnailImage: UIImage? {
        didSet {
            self.thumbnailImageView.image = self.thumbnailImage
        }
    }
    
    override var selectedIndex: Int {
        didSet {
            self.checkView.checkLabel.text =  "\(self.selectedIndex + 1)"
        }
    }
    
    internal lazy var imageView: UIImageView = {
        let thumbnailImageView = UIImageView()
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        
        return thumbnailImageView
    }()
    
    override var thumbnailImageView: UIImageView {
        return imageView
    }
    
    private let checkView = DKImageCheckView()
    
    override var isSelected: Bool {
        didSet {
            self.checkView.isHidden = !super.isSelected
        }
    }
}

