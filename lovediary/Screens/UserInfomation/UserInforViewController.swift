//
//  UserInforViewController.swift
//  lovediary
//
//  Created by vu dao on 10/03/2021.
//

import UIKit
import Combine

extension Locale {
    static var currentLocale: Locale {
        return Locale(identifier: Language.languageCodeDevice)
    }
}

class UserInforViewController: BaseViewController<UserInforViewModel> {
    
    func themeChange() {
        view.backgroundColor = Colors.settingTableViewBackgroundColor
        backgroundImageView.backgroundColor = Colors.toneColor
        profileImageView.backgroundColor = Colors.toneColor
        nickNameTextField.textColor = Colors.textColor
    }
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nickNameTextField: UITextField!
    @IBOutlet weak var maleButton: RightImageButton!
    @IBOutlet weak var femaleButton: RightImageButton!
    @IBOutlet weak var birthDayViewContainer: UIView!
    
    @IBOutlet weak var profileImageContainer: UIView!
    
    private lazy var customDatePickerView: CustomDatePickerView = {
        let customDatePicker = CustomDatePickerView()
        let datePicker = customDatePicker.datePicker
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()
        datePicker.locale = Locale.currentLocale
        return customDatePicker
    }()
    
    private lazy var birthDayLabel: ThemeCommonColorLabel = {
        let label = ThemeCommonColorLabel()
        label.font = Fonts.getHiraginoSansFont(fontSize: 18, fontWeight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func setupView() {
        super.setupView()
        maleButton.title = LocalizedString.male
        femaleButton.title = LocalizedString.female
        setupBirthDayView()
        setupHideKeyboardOnTap()
        nickNameTextField.placeholder = DefaultInfo.name
        themeChange()
    }
    
    private func setupBirthDayView() {
        birthDayLabel.text = Date().format(partern: .fullDate)
        customDatePickerView.translatesAutoresizingMaskIntoConstraints = false
        birthDayViewContainer.addSubview(customDatePickerView)
        customDatePickerView.centerInSuperview()
        customDatePickerView.containerView.addSubview(birthDayLabel)
        NSLayoutConstraint.activate([
            birthDayLabel.centerXAnchor.constraint(equalTo: customDatePickerView.containerView.centerXAnchor),
            birthDayLabel.centerYAnchor.constraint(equalTo: customDatePickerView.containerView.centerYAnchor)
        ])
       
        if #available(iOS 14.0, *) {
            if #available(iOS 15.0, *) {
                birthDayViewContainer.viewTapPublisher().sink { _ in
                    self.showDatePicker(datePicker: self.customDatePickerView.datePicker)
                }.store(in: &anyCancelables)
            }
        } else {
            birthDayViewContainer.viewTapPublisher().sink { _ in
                self.showDatePicker(datePicker: self.customDatePickerView.datePicker)
            }.store(in: &anyCancelables)
        }
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        let selectGender = Publishers.Merge(maleButton.viewTapPublisher().map {_ in return Gender.male },
                                            femaleButton.viewTapPublisher().map {_ in return Gender.female })
            .receiveOutput(outPut: {[weak self] _ in self?.nickNameTextField.endEditing(true) })
            
        let dateChange = customDatePickerView.datePicker.publisher(for: .editingDidEnd)
            .map {[weak self] _ in return self?.customDatePickerView.datePicker.date }
            .compactMap { $0 }
            .eraseToAnyPublisher()
        
        let selectProfileImageTrigger = profileImageView
            .viewTapPublisher()
            .flatMap {[weak self] _ -> AnyPublisher<UIImage, Never> in
                guard let self = self else { return .empty() }
                return self.showSingleImagePicker(size: CGSize(width: 1, height: 1))
            }.receiveOutput {[weak self] image in
                self?.profileImageView.image = image
                self?.backgroundImageView.image = image
            }.eraseToAnyPublisher()
        
        let input = UserInforViewModel.Input(selectGenderTrigger: selectGender.eraseToAnyPublisher(),
                                             nameTextChange: nickNameTextField.textPublisher,
                                             birthDayChange: dateChange,
                                             selectProfileImageTrigger: selectProfileImageTrigger)
        let output = viewModel.transform(input)
        output.userData
            .receive(on: DispatchQueue.main)
            .sink {[weak self] userModel in
                self?.nickNameTextField.text = userModel.name
                self?.setgender(gender: Gender(value: userModel.gender))
                if let birthDay = userModel.birthDay {
                    self?.customDatePickerView.datePicker.date = birthDay
                    self?.birthDayLabel.text = birthDay.format(partern: .fullDate)
                    self?.birthDayLabel.alpha = 1
                } else {
                    self?.customDatePickerView.datePicker.date = Date()
                    self?.birthDayLabel.text = Date().format(partern: .fullDate)
                    self?.birthDayLabel.alpha = 0.5
                }
            }.store(in: &anyCancelables)
        
        ProfileImageManager.didChange.sink {[weak self] type in
            let image = ProfileImageManager.load(of: type)
            let defaultImage = type == .me ? DefaultInfo.mProfileImage : DefaultInfo.pProfileImage
            self?.profileImageView.image = image?.resize(size: .init(width: UIApplication.width * 0.42,
                                                                     height: UIApplication.width * 0.42)) ?? defaultImage
            self?.backgroundImageView.image = image?.resize(size: .init(width: UIApplication.width,
                                                                        height: UIApplication.height * 0.3))
        }.store(in: &anyCancelables)
        
        output.voidAction.sink {} .store(in: &anyCancelables)
    }
    
    private func setgender(gender: Gender) {
        self.maleButton.isSelected = gender == .male
        self.femaleButton.isSelected = gender == .female
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.async {
            self.profileImageView
                .applyshadowWithCorner(containerView: self.profileImageContainer,
                                       cornerRadious: self.profileImageView.bounds.height / 2)
        }
        
        backgroundImageView.addBlur(style: .regular)
    }
    
}
