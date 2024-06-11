//
//  DiaryKeyboardToolbar.swift
//  lovediary
//
//  Created by vu dao on 17/03/2021.
//

import Combine
import UIKit

class DiaryKeyboardToolbar: UIToolbar {
    
    lazy var photoButton = UIBarButtonItem(image: Images.Icon.photo,
                                           style: .plain, target: self,
                                           action: nil)
    lazy var cameraButton = UIBarButtonItem(image: Images.Icon.camera,
                                            style: .plain, target: self,
                                            action: nil)
    lazy var doneButton =  UIBarButtonItem(title: LocalizedString.done, style: .done, target: self, action: nil)
    
    lazy var textCountLabel =  UIBarButtonItem(title: "0", style: .done, target: self, action: nil)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initView()
    }
    
    private func initView() {
        self.frame = CGRect(x: 0, y: 0, width: UIApplication.windowBound.width, height: 0)
        self.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        textCountLabel.isEnabled = false
        textCountLabel.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.blue], for: .disabled)
        self.items = [photoButton, cameraButton, flexibleSpace, textCountLabel, doneButton]
    }
}
