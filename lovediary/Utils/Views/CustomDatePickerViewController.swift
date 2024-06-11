//
//  CustomDatePickerViewController.swift
//  lovediary
//
//  Created by daovu on 11/03/2021.
//

import Foundation
import UIKit

class CustomDatePickerViewController: UIViewController {
    
    static let maxDate = "31/12/2079".toDate(pattern: "dd/mm/yyyy")
    
    private let datePicker: UIDatePicker
    private let keyboardToolbar = ToolbarHelper()
    init(datePicker: UIDatePicker) {
        self.datePicker = datePicker
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var dateTextField: UITextField = {
        let textfield = UITextField()
        return textfield
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        setupTextField()
        setupKeyboardToolbar()
        setupDatePicker()
        dateTextField.becomeFirstResponder()
    }
    
}

extension CustomDatePickerViewController {
    private func setupTextField() {
        view.addSubview(dateTextField)
        dateTextField.delegate = self
    }
    
    private func setupDatePicker() {
        datePicker.calendar = Calendar(identifier: .gregorian)
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        dateTextField.inputView = datePicker.createPickerInputView()
    }
    
    private func closingKeyboard() {
        self.view.endEditing(true)
        removeReferenceCount()
        self.dismiss(animated: true, completion: nil)
    }
    
    private func removeReferenceCount() {
        keyboardToolbar.handlerOkAction = nil
        keyboardToolbar.handlerCancelAction = nil
        dateTextField.inputAccessoryView = nil
    }
}

extension CustomDatePickerViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        closingKeyboard()
        
    }
}

// MARK: Setup keyboard toolbar
extension CustomDatePickerViewController {
    private func setupKeyboardToolbar() {
        keyboardToolbar.handlerOkAction = tappedOkButton
        keyboardToolbar.handlerCancelAction = tappedCancelButton
        dateTextField.inputAccessoryView = keyboardToolbar
    }
    
    @objc func tappedOkButton() {
        closingKeyboard()
        datePicker.sendActions(for: .editingDidEnd)
        //        dateTextField.text = StringsHelper.getYearMonthDayString(from: datePicker.date)
    }
    
    @objc func tappedCancelButton() {
        closingKeyboard()
    }
}

extension CustomDatePickerViewController {
    static func show(_ viewController: UIViewController?,
                     datePicker: UIDatePicker,
                     handle: ((CustomDatePickerViewController) -> Void)? = nil) {
        guard let viewController = viewController else { return }
        let datePicker = CustomDatePickerViewController(datePicker: datePicker)
        handle?(datePicker)
        datePicker.modalPresentationStyle = .overCurrentContext
        datePicker.modalTransitionStyle = .crossDissolve
        viewController.present(datePicker, animated: true, completion: nil)
    }
}

extension UIViewController {
    func showDatePicker(datePicker: UIDatePicker, handle: ((CustomDatePickerViewController) -> Void)? = nil) {
        CustomDatePickerViewController.show(self, datePicker: datePicker, handle: handle)
    }
}

extension UIView {
    
    var size: CGSize {
        get {
            return self.frame.size
        }
        set {
            var frame = self.frame
            frame.size = newValue
            self.frame = frame
        }
    }
    
    func createPickerInputView() -> UIView {
        // fix input accessory view lost on IPAD in multi window mode, on right side
        let inputView = UIView()
        inputView.size.height = 216
        inputView.backgroundColor = .clear
        self.translatesAutoresizingMaskIntoConstraints = false
        inputView.addSubview(self)
        NSLayoutConstraint.activate([
            inputView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            inputView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            inputView.topAnchor.constraint(equalTo: self.topAnchor),
            inputView.bottomAnchor.constraint(equalTo: self.topAnchor)
        ])
        return inputView
    }
}
