//
//  Progresshelper.swift
//  lovediary
//
//  Created by daovu on 22/03/2021.
//

import UIKit

typealias ProgressCancelHandler = () -> Void

class ProgressHelper: NSObject {
    static let shared = ProgressHelper()
    
    private var backgroundView: UIView!
    private var activityIndicatorBackgroundView: UIView!
    private var activityIndicatorView: UIActivityIndicatorView!
    private var cancelButton: UIButton!
    private(set) var isShowing = false
    
    var cancelHandler: ProgressCancelHandler?
    
    private override init() {
        super.init()
        if self.backgroundView == nil {
            self.backgroundView = UIView()
            self.backgroundView.backgroundColor = .black
            self.backgroundView.layer.opacity = 0.2
        }
        if self.activityIndicatorBackgroundView == nil {
            self.activityIndicatorBackgroundView = UIView()
            self.activityIndicatorBackgroundView.backgroundColor = .black
            self.activityIndicatorBackgroundView.layer.cornerRadius = 10
        }
        if self.activityIndicatorView == nil {
            self.activityIndicatorView = UIActivityIndicatorView(style: .medium)
            self.activityIndicatorView.center = self.activityIndicatorBackgroundView.center
        }
        
        if self.cancelButton == nil {
            self.cancelButton = UIButton()
            self.cancelButton.setTitle(LocalizedString.cancel, for: .normal)
            self.cancelButton.setTitleColor(.blue, for: .normal)
            self.cancelButton.layer.cornerRadius = 10
            self.cancelButton.layer.masksToBounds = true
            self.cancelButton.backgroundColor = .white
            self.cancelButton.addTarget(self, action: #selector(self.cancelButtonTouchUpInside), for: .touchUpInside)
        }
    }
    
    private func setupCancelButton() {
        guard let window = UIApplication.shared.windows.first else { return }
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        window.addSubview(cancelButton)
        NSLayoutConstraint.activate([
            cancelButton.heightAnchor.constraint(equalToConstant: 50),
            cancelButton.trailingAnchor.constraint(equalTo: window.trailingAnchor, constant: -10),
            cancelButton.leadingAnchor.constraint(equalTo: window.leadingAnchor, constant: 10),
            cancelButton.bottomAnchor.constraint(equalTo: window.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupBackgroundView() {
        guard let window = UIApplication.shared.windows.first else { return }
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        window.addSubview(backgroundView)
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: window.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: window.bottomAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: window.trailingAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: window.leadingAnchor)
        ])
    }
    
    private func setupActivityIndicatorBackgroundView() {
        guard let window = UIApplication.shared.windows.first else { return }
        activityIndicatorBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        window.addSubview(activityIndicatorBackgroundView)
        NSLayoutConstraint.activate([
            activityIndicatorBackgroundView.centerXAnchor.constraint(equalTo: window.centerXAnchor),
            activityIndicatorBackgroundView.centerYAnchor.constraint(equalTo: window.centerYAnchor),
            activityIndicatorBackgroundView.widthAnchor.constraint(equalToConstant: 75),
            activityIndicatorBackgroundView.heightAnchor.constraint(equalToConstant: 75)
        ])
    }
    
    private func setupIndicatorView() {
        guard let window = UIApplication.shared.windows.first else { return }
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        window.addSubview(activityIndicatorView)
        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: window.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: window.centerYAnchor)
        ])
    }
    
    private func setupTheme() {
        applyTheme()
    }
    
    private func applyTheme() {
        activityIndicatorView.color = .white
        activityIndicatorBackgroundView.backgroundColor = .black
        //        if Theme.current == .dark {
        //            activityIndicatorView.color = .black
        //            activityIndicatorBackgroundView.backgroundColor = .white
        //        } else {
        //            activityIndicatorView.color = .white
        //            activityIndicatorBackgroundView.backgroundColor = .black
        //        }
    }
    
    func show(isShowCancelButton: Bool = false) {
        if !isShowing {
            isShowing = true
            cancelButton.setTitle(LocalizedString.cancel, for: .normal)
            activityIndicatorView.startAnimating()
            setupBackgroundView()
            setupActivityIndicatorBackgroundView()
            setupIndicatorView()
            setupTheme()
            if isShowCancelButton {
                setupCancelButton()
            }
        }
    }
    
    @objc func cancelButtonTouchUpInside() {
        hide()
        cancelHandler?()
    }
    
    func hide() {
        guard isShowing else { return }
        isShowing = false
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.activityIndicatorView.stopAnimating()
            self.activityIndicatorView.removeFromSuperview()
            self.activityIndicatorBackgroundView.removeFromSuperview()
            self.backgroundView.removeFromSuperview()
            self.cancelButton.removeFromSuperview()
        }
    }
}
