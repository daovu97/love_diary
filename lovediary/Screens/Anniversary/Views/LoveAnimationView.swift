//
//  LoveAnimationView.swift
//  lovediary
//
//  Created by daovu on 10/03/2021.
//

import UIKit
import Lottie

@IBDesignable
class LoveAnimationView: BaseView {
    
    private lazy var animationView: AnimationView = {
        let animView = AnimationView(name: "main_heart")
        animView.apply {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.contentMode = .scaleAspectFill
            $0.animationSpeed = 1
            $0.loopMode = .loop
        }
        return animView
    }()
    
    override func setupUI() {
        super.setupUI()
        addSubview(animationView)
        animationView.fillSuperview()
        play()
    }
    
    func play() {
        animationView.play()
    }
    
    func stop() {
        animationView.pause()
        animationView.currentTime = 10.12
    }
    
    func pause() {
        animationView.pause()
    }
    
    deinit {
        stop()
        animationView.removeFromSuperview()
        self.removeFromSuperview()
    }
}
