//
//  CustomDatePicker.swift
//  lovediary
//
//  Created by daovu on 17/03/2021.
//

import UIKit

class CustomDatePickerView: BaseView {
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.locale = Locale.current
        return datePicker
    }()
    
    override func setupUI() {
        super.setupUI()
        if #available(iOS 14.0, *) {
            datePicker.addSubview(containerView)
            NSLayoutConstraint.activate([
                containerView.leadingAnchor.constraint(equalTo: datePicker.leadingAnchor),
                containerView.trailingAnchor.constraint(equalTo: datePicker.trailingAnchor),
                containerView.bottomAnchor.constraint(equalTo: datePicker.bottomAnchor),
                containerView.topAnchor.constraint(equalTo: datePicker.topAnchor)
            ])
            datePicker.date = Date()
            addSubview(datePicker)
            NSLayoutConstraint.activate([
                datePicker.leadingAnchor.constraint(equalTo: leadingAnchor),
                datePicker.trailingAnchor.constraint(equalTo: trailingAnchor),
                datePicker.bottomAnchor.constraint(equalTo: bottomAnchor),
                datePicker.topAnchor.constraint(equalTo: topAnchor)
            ])
            datePicker.bringSubviewToFront(containerView)
            datePicker.subviews.first?.subviews.forEach { $0.isHidden = true }
            containerView.isUserInteractionEnabled = false
        } else {
            addSubview(containerView)
            containerView.isUserInteractionEnabled = true
            NSLayoutConstraint.activate([
                containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
                containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
                containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
                containerView.topAnchor.constraint(equalTo: topAnchor)
            ])
        }
    }
}
