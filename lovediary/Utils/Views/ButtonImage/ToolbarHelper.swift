//
//  ToolbarHelper.swift
//  lovediary
//
//  Created by daovu on 11/03/2021.
//

import Foundation
import UIKit

typealias KeyboardHandler = () -> Void

enum ToolbarType {
    case confirm
    case touchId
}

class ToolbarHelper: UIToolbar {
    var handlerOkAction: KeyboardHandler?
    var handlerCancelAction: KeyboardHandler?
    var okBarButton: UIBarButtonItem!
    var cancelBarButton: UIBarButtonItem!
    var typeToolbar: ToolbarType = .confirm {
        didSet {
            if typeToolbar == .touchId {
                //                var touchIdBarButtonTitle = LocalizedStrings.cs02TouchIdLogin
                //                if #available(iOS 11.0, *) {
                //                    switch TouchIDHelper.context.biometryType {
                //                    case .faceID:
                //                        touchIdBarButtonTitle = LocalizedStrings.cs02FaceIdLogin
                //                    default:
                //                        touchIdBarButtonTitle = LocalizedStrings.cs02TouchIdLogin
                //                    }
                //                }
                //                let touchIdBarButton = UIBarButtonItem(title: touchIdBarButtonTitle, style: .plain, target: self, action: #selector(tappedOkButton))
                //                self.items = [touchIdBarButton]
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
        //        applyTheme()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initView()
        //        applyTheme()
    }
    
    private func initView() {
        self.frame = CGRect(x: 0, y: 0, width: UIApplication.windowBound.width, height: 0)
        
        self.sizeToFit()
        if typeToolbar == .confirm {
            let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            okBarButton = UIBarButtonItem(title: LocalizedString.ok, style: .plain, target: self, action: #selector(tappedOkButton))
            //            okBarButton.setTitleTextAttributes([.foregroundColor: Colors.buttonTint,
            //                                                .font: UIFont.systemFont(ofSize: 17)], for: UIControl.State())
            cancelBarButton = UIBarButtonItem(title: LocalizedString.cancel, style: .plain, target: self, action: #selector(tappedCancelButton))
            //            cancelBarButton.setTitleTextAttributes([.foregroundColor: Colors.buttonTint,
            //                                                    .font: UIFont.systemFont(ofSize: 17)], for: UIControl.State())
            
            self.items = [cancelBarButton, flexibleSpace, okBarButton]
            //            applyTheme()
        }
    }
    
    //    public func applyTheme() {
    //        barTintColor = Colors.navigationBackground
    //        tintColor = Colors.buttonTint
    //    }
    //
    //    static func applyTheme() {
    //         ToolbarHelper.appearance().barTintColor = Colors.navigationBackground
    //         ToolbarHelper.appearance().tintColor = Colors.navigationBackground
    //    }
    //
    @objc func tappedOkButton() {
        self.handlerOkAction?()
    }
    
    @objc func tappedCancelButton() {
        self.handlerCancelAction?()
    }
}
