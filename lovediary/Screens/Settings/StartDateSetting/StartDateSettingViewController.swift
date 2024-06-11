//
//  StartDateSettingViewController.swift
//  lovediary
//
//  Created by daovu on 24/03/2021.
//

import UIKit
import Combine

class StartDateSettingViewController: BaseViewController<StartDateSettingViewModel> {
    
    @IBOutlet weak var mInforImageView: UIImageView!
    @IBOutlet weak var pInforImageView: UIImageView!
    @IBOutlet weak var dateTimePikerContainer: UIStackView!
    
    @IBOutlet weak var startLoveLabel: UILabel!
    
    private lazy var loadData = PassthroughSubject<Void, Never>()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.date = Date()
        datePicker.maximumDate = Date()
        return datePicker
    }()
    
    private lazy var dateLabel: IncreaseHeightLabel = {
        let label = IncreaseHeightLabel()
        label.text = ""
        label.setLineSpacing(12)
        label.textAlignment = .center
        label.textColor = .systemPink
        label.font = Fonts.getHiraginoSansFont(fontSize: 22, fontWeight: .bold)
        return label
    }()
    
    override func setupView() {
        super.setupView()
        setupDatePickerView()
        startLoveLabel.text = LocalizedString.startLoveSettingDetailTitle
        mInforImageView.image = ProfileImageManager.load(of: .me)?.resize() ?? DefaultInfo.mProfileImage
        pInforImageView.image = ProfileImageManager.load(of: .partner)?.resize() ?? DefaultInfo.pProfileImage
    }
    
    private func setupDatePickerView() {
        if #available(iOS 14.0, *) {
            if #available(iOS 15.0, *) {
                setupDatePickerForIos13()
                return
            }
            datePicker.addSubview(dateLabel)
            dateLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                dateLabel.leadingAnchor.constraint(equalTo: datePicker.leadingAnchor),
                dateLabel.trailingAnchor.constraint(equalTo: datePicker.trailingAnchor),
                dateLabel.topAnchor.constraint(equalTo: datePicker.topAnchor),
                dateLabel.bottomAnchor.constraint(equalTo: datePicker.bottomAnchor)
                
            ])
            datePicker.bringSubviewToFront(dateLabel)
            datePicker.subviews.first?.subviews.forEach { $0.alpha = 0 }
            datePicker.sizeToFit()
            
            dateTimePikerContainer.addArrangedSubview(datePicker)
        } else {
            setupDatePickerForIos13()
        }
    }
    
    private func setupDatePickerForIos13() {
        dateTimePikerContainer.addArrangedSubview(dateLabel)
        dateLabel.viewTapPublisher().sink {[weak self] _ in
            self?.showDate()
        }.store(in: &anyCancelables)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cornerWithBorder(view: mInforImageView)
        cornerWithBorder(view: pInforImageView)
    }
    
    private func cornerWithBorder(view: UIView, color: UIColor = .white) {
        view.cornerWithBorder(cornerRadius: view.frame.width / 2,
                              borderWidth: LoveInfoView.profileImageBorderWidth,
                              borderColor: color)
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        let dateChange = datePicker.publisher(for: .editingDidEnd)
            .map {[weak self] _ in return self?.datePicker.date }
            .compactMap { $0 }
            .eraseToAnyPublisher()
        
        let input = StartDateSettingViewModel.Input(loadData: loadData.eraseToAnyPublisher(),
                                                    dateChange: dateChange)
        let output = viewModel.transform(input)
        output.date.sink {[weak self] date in
            self?.dateLabel.text = date.format(partern: .fullDate)
            self?.datePicker.date = date
        }.store(in: &anyCancelables)
        loadData.send()
        datePicker.sendActions(for: .editingDidEnd)
    }
    
    private func showDate() {
        showDatePicker(datePicker: datePicker)
    }
}
