//
//  LoveInfoView.swift
//  lovediary
//
//  Created by daovu on 10/03/2021.
//

import UIKit
import Combine

@IBDesignable
class LoveInfoView: BaseView {
    static let profileImageSizeMultipier = CGFloat(0.18)
    static let profileImageBorderWidth = CGFloat(3)
    
    var tapToEdit: AnyPublisher<UserType, Never>!
    
    private lazy var mProfileImage: UIImageView = {
        let image = getProfileImage()
        image.image = DefaultInfo.mProfileImage
        return image
    }()
    
    private lazy var partnerProfileImage: UIImageView = {
        let image = getProfileImage()
        image.image = DefaultInfo.pProfileImage
        return image
    }()
    
    private lazy var mNameLabel: IncreaseHeightLabel = {
        let label = getNameLabel()
        label.text = DefaultInfo.name
        return label
    }()
    
    private lazy var partnerNameLabel: IncreaseHeightLabel = {
        let label = getNameLabel()
        label.text = LocalizedString.name
        return label
    }()
    
    private func getProfileImage() -> UIImageView {
        let image = UIImageView()
        image.contentMode = .scaleToFill
        image.backgroundColor = .white
        image.clipsToBounds = true
        image.isUserInteractionEnabled = false
        image.translatesAutoresizingMaskIntoConstraints = false
        image.isUserInteractionEnabled = true
        return image
    }
    
    private func getNameLabel() -> IncreaseHeightLabel {
        let label = IncreaseHeightLabel()
        label.font = Fonts.primaryBoldFont
        label.textColor = .white
        label.isUserInteractionEnabled = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }
    
    private lazy var loveImage: UIImageView = {
        let image = UIImageView()
        image.image = Images.Icon.loveImage
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        return image
    }()
    
    private lazy var someView = UIView()
    
    override func setupUI() {
        super.setupUI()
        addSubview(loveImage)
        addSubview(mProfileImage)
        addSubview(partnerProfileImage)
        loveImage.centerInSuperview(size: .init(width: 210, height: 45))
        setConstrainProfileImage(view: mProfileImage)
        setConstrainProfileImage(view: partnerProfileImage,
                                 centerXMultiplier: 1.5)
        
        tapToEdit = Publishers.Merge(mProfileImage.viewTapPublisher().map { return UserType.me },
                                     partnerProfileImage.viewTapPublisher().map { return UserType.partner })
            .eraseToAnyPublisher()
        
        addSubview(mNameLabel)
        addSubview(partnerNameLabel)
        
        setConstrainLabelName(of: mNameLabel, to: mProfileImage)
        setConstrainLabelName(of: partnerNameLabel, to: partnerProfileImage, centerXMultiplier: 1.5)
    }
    
    private func setConstrainLabelName(of view: UILabel,
                                       to constrainView: UIImageView,
                                       centerXMultiplier: CGFloat = CGFloat(0.5)) {
        [view.topAnchor.constraint(equalTo: constrainView.bottomAnchor, constant: 8),
         NSLayoutConstraint(item: view,
                            attribute: .centerX,
                            relatedBy: .equal,
                            toItem: self,
                            attribute: .centerX,
                            multiplier: centerXMultiplier,
                            constant: 0),
         view.widthAnchor.constraint(equalTo: constrainView.widthAnchor, multiplier: 2)]
            .forEach { $0.isActive = true }
    }
    
    private func setConstrainProfileImage(view: UIImageView, centerXMultiplier: CGFloat = CGFloat(0.5)) {
        view.clipsToBounds = true
        [NSLayoutConstraint(item: view,
                            attribute: .centerX,
                            relatedBy: .equal,
                            toItem: self,
                            attribute: .centerX,
                            multiplier: centerXMultiplier,
                            constant: 0),
         view.centerYAnchor.constraint(equalTo: centerYAnchor),
         view.widthAnchor.constraint(equalTo: widthAnchor,
                                     multiplier: LoveInfoView.profileImageSizeMultipier),
         view.heightAnchor.constraint(equalTo: view.widthAnchor)]
            .forEach { $0.isActive = true }
        
        view.isUserInteractionEnabled = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        cornerWithBorder(view: mProfileImage)
        cornerWithBorder(view: partnerProfileImage)
    }
    
    private func cornerWithBorder(view: UIView, color: UIColor = .white) {
        view.cornerWithBorder(cornerRadius: view.frame.width / 2,
                              borderWidth: LoveInfoView.profileImageBorderWidth,
                              borderColor: color)
    }
    
    func setData(userInfo: UserInfoModel?) {
        guard let userInfo = userInfo else { return }
        if userInfo.getUserType() == .me {
            mNameLabel.text = (userInfo.name.isEmpty ? DefaultInfo.name : userInfo.name).capitalized
        } else {
            partnerNameLabel.text = (userInfo.name.isEmpty ? DefaultInfo.name : userInfo.name).capitalized
        }
    }
    
    func setImage(type: UserType) {
        if type == .me {
            mProfileImage.image = ProfileImageManager.load(of: .me)?.resize() ?? DefaultInfo.mProfileImage
        } else {
            partnerProfileImage.image = ProfileImageManager.load(of: .partner)?.resize() ?? DefaultInfo.pProfileImage
        }
    }
}

class UserInfoView: BaseView {
    override func setupUI() {
        super.setupUI()
    }
}

extension UIView {
    func cornerWithBorder(cornerRadius: CGFloat, borderWidth: CGFloat = 0, borderColor: UIColor = .white) {
        layer.cornerRadius = cornerRadius
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
        layer.masksToBounds = true
    }
}
