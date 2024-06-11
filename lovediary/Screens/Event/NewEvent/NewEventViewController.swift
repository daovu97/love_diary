//
//  NewEventViewController.swift
//  lovediary
//
//  Created by daovu on 05/04/2021.
//

import UIKit
import Combine

class NewEventViewController: BasetableViewController<NewEventViewModel> {
    private let minuteInterval = 5
    private let currentDate = Date()
    
    @IBOutlet weak var eventTitleTextField: UITextField!
    @IBOutlet weak var eventDetailTextField: MultilineTextField!
    @IBOutlet weak var pinTitleLabel: SettingTableViewLabel!
    @IBOutlet weak var pinSwitch: UISwitch!
    @IBOutlet weak var isUsingTimeSwitch: UISwitch!
    @IBOutlet weak var dateTitleLabel: SettingTableViewLabel!
    @IBOutlet weak var timeTitleLabel: SettingTableViewLabel!
    
    @IBOutlet weak var reminderTitleLabel: SettingTableViewLabel!
    @IBOutlet weak var reminderTypeLabel: IncreaseHeightLabel!
    @IBOutlet weak var reminderTimeTitleLabel: SettingTableViewLabel!
    @IBOutlet weak var reminderTimeStackView: UIView!
    
    @IBOutlet weak var dateStackView: UIView!
    @IBOutlet weak var timeStackView: UIStackView!
    
    @IBOutlet weak var timeLabelCell: UITableViewCell!
    
    @IBOutlet weak var deleteLabel: UILabel!
    
    //indexpath
    private let titleIndexPath = IndexPath(row: 0, section: 0)
    private let detailIndexPath = IndexPath(row: 1, section: 0)
    
    private let pinIndexPath = IndexPath(row: 0, section: 1)
    
    private let dateIndexPath = IndexPath(row: 0, section: 2)
    private let timeIndexPath = IndexPath(row: 1, section: 2)
    private let timeLabelIndexPath = IndexPath(row: 2, section: 2)
    
    private let reminderIndexPath = IndexPath(row: 0, section: 3)
    private let reminderTimeIndexPath = IndexPath(row: 1, section: 3)
    
    private let deleteIndexPath = IndexPath(row: 0, section: 4)
    
    private var isUsingTime: Bool = false
    private var isEdit: Bool = false
    private var currentReminderType: ReminderType = .none
    
    var saveCompletion: (() -> Void)?
    
    private lazy var saveBarButton = UIBarButtonItem(title: LocalizedString.saveLabel, style: .done, target: self, action: nil)
    
    private lazy var cancelBarButton = UIBarButtonItem(title: LocalizedString.cancel, style: .done, target: self, action: nil)
    
    private lazy var didSelectRowAt = PassthroughSubject<IndexPath, Never>()
    private lazy var dismissTrigger = PassthroughSubject<Void, Never>()
    private var isDefaultEvent = false
    
    //Date
    private lazy var timePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.locale = .currentLocale
        datePicker.date = currentDate
        datePicker.datePickerMode = .time
        datePicker.minuteInterval = minuteInterval
        if #available(iOS 14.0, *) {
            datePicker.preferredDatePickerStyle = .inline
        } else {
            // Fallback on earlier versions
        }
        return datePicker
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.text = currentDate.format(partern: .fullDate)
        return label
    }()
    
    //Time
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.date = currentDate
        datePicker.locale = .currentLocale
        datePicker.datePickerMode = .date
        return datePicker
    }()
    
    private lazy var timeLabel: SettingTableViewLabel = {
        let label = SettingTableViewLabel()
        label.text = currentDate.format(partern: .timeShort)
        return label
    }()
    
    //Reminder Time
    private lazy var reminderTimePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.date = Date()
        datePicker.locale = .currentLocale
        datePicker.datePickerMode = .time
        datePicker.minuteInterval = minuteInterval
        if #available(iOS 14.0, *) {
            datePicker.preferredDatePickerStyle = .inline
        } else {
            // Fallback on earlier versions
        }
        return datePicker
    }()
    
    private lazy var reminderTimeLabel: SettingTableViewLabel = {
        let label = SettingTableViewLabel()
        label.text = Date().format(partern: .timeShort)
        return label
    }()
    
    private func setSaveButton(isEnable: Bool) {
        saveBarButton.isEnabled = isEnable
    }
    
    private func applyTheme() {
        eventTitleTextField.textColor = Themes.current.settingTableViewColor.text
        eventDetailTextField.textColor = Themes.current.settingTableViewColor.text
    }
    
    private func setupLocalizeString() {
        eventTitleTextField.placeholder = LocalizedString.eventTitlePlaceHolder
        eventDetailTextField.placeholder = LocalizedString.eventDetailPlaceHolder
        pinTitleLabel.text = LocalizedString.pinTitle
        dateTitleLabel.text = LocalizedString.dateTitle
        timeTitleLabel.text = LocalizedString.timeTitle
        reminderTitleLabel.text = LocalizedString.reminderTypeTitle
        reminderTimeTitleLabel.text = LocalizedString.reminderTimeTitle
        deleteLabel.text = LocalizedString.delete
    }
    
    override func setupView() {
        super.setupView()
        applyTheme()
        setupLocalizeString()
        self.navigationController?.presentationController?.delegate = self
        setSaveButton(isEnable: false)
        eventTitleTextField.delegate = self
        setupHideKeyboardOnTap()
        eventTitleTextField.becomeFirstResponder()
        setupDate()
        setupTime()
        setupReminderTime()
        didSelectRowAt.sink {[weak self] indexPath in
            guard let self = self else { return }
            switch indexPath {
            case self.dateIndexPath:
                if self.isDefaultEvent { break }
                self.showDatePicker(datePicker: self.datePicker)
            case self.timeLabelIndexPath:
                self.showDatePicker(datePicker: self.timePicker)
            case self.reminderTimeIndexPath:
                self.showDatePicker(datePicker: self.reminderTimePicker)
            case self.deleteIndexPath:
                break
            default:
                break
            }
        }.store(in: &anyCancelables)
    }
    
    private func checkNotificationAuthorization() -> AnyPublisher<Void, Never> {
        return BadgeHelper.checkNotificationAuthorization().flatMap { granted  -> AnyPublisher<Void, Never> in
            if granted { return .just(()) }
            else {
                return Just(())
                    .receive(on: DispatchQueue.main).flatMap { _ -> AnyPublisher<Void, Never> in
                        AlertManager.shared
                            .showErrorMessage(message: LocalizedString.requestNotificationMessageTitle)
                        .flatMap { _ -> AnyPublisher<Void, Never> in
                            SettingsHelper.goToSettingApp()
                            return .empty()
                        }.eraseToAnyPublisher()
                    }.eraseToAnyPublisher()
            }
        }.eraseToAnyPublisher()
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        let dismiss = Publishers.Merge(dismissTrigger, cancelBarButton.tapPublisher)
        let reminderSelectType = didSelectRowAt
            .filter {[weak self] in return $0 == self?.reminderIndexPath }
            .flatMap {[weak self] _ -> AnyPublisher<Void, Never> in
                guard let self = self else { return .empty() }
                return self.checkNotificationAuthorization()
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        
        let deteleSelect = didSelectRowAt
            .filter {[weak self] in return $0 == self?.deleteIndexPath }
            .receive(on: DispatchQueue.main)
            .eraseToVoidAnyPublisher()
        
        let input = NewEventViewModel.Input(eventTitle: eventTitleTextField.textPublisher,
                                            eventDetail: eventDetailTextField.textChangePublisher,
                                            isPin: pinSwitch.publisher(for: .valueChanged).compactMap {[weak self] in return self?.pinSwitch.isOn }.eraseToAnyPublisher(),
                                            eventDate: datePicker.publisher(for: .valueChanged).compactMap {[weak self] in return self?.datePicker.date }.eraseToAnyPublisher(),
                                            usingTime: isUsingTimeSwitch.publisher(for: .valueChanged).compactMap {[weak self] in return self?.isUsingTimeSwitch.isOn }.eraseToAnyPublisher(),
                                            eventTime: timePicker.publisher(for: .valueChanged).compactMap {[weak self] in return self?.timePicker.date }.eraseToAnyPublisher(),
                                            remiderSelect: reminderSelectType,
                                            reminderTime: reminderTimePicker.publisher(for: .valueChanged).compactMap {[weak self] in return self?.reminderTimePicker.date }.eraseToAnyPublisher(),
                                            saveTrigger: saveBarButton.tapPublisher,
                                            dismissTrigger: dismiss.eraseToAnyPublisher(),
                                            deleteEventTrigger: deteleSelect)
        
        let output = viewModel.transform(input)
        output.editComplete.sink {[weak self] _ in
            self?.saveCompletion?()
            self?.dismiss(animated: true, completion: nil)
        }.store(in: &anyCancelables)
        output.actionVoid.sink {}.store(in: &anyCancelables)
        
        output.reminderType.sink {[weak self] type in
            guard let self = self else { return }
            self.currentReminderType = type
            self.reminderTypeLabel.text = type.title
            if type.isRiminderDay {
                self.setupReminderTime(time: self.timePicker.date)
            }
            self.tableView.reloadData()
        }.store(in: &anyCancelables)
        
        output.isUsingTime.sink {[weak self] isUsing  in
            self?.isUsingTime = isUsing
            if !isUsing {
                self?.setupTimeValue(time: Date())
            }
            self?.tableView.reloadData()
        }.store(in: &anyCancelables)
        
        output.shouldSave.sink { [weak self] in
            self?.setSaveButton(isEnable: $0)
        }.store(in: &anyCancelables)
        
        output.shouldDismiss
            .removeDuplicates()
            .sink { [weak self] in
                self?.isModalInPresentation = $0
            }.store(in: &anyCancelables)
        
        output.event.sink {[weak self] event in
            self?.pinSwitch.isOn = event.pinned
            self?.pinSwitch.isEnabled = !(self?.viewModel.isOudate ?? false)
            self?.setupTitle(event: event)
            self?.setupDate(event: event)
            self?.setupReminderTime(time: event.reminderTime ?? Date())
        }.store(in: &anyCancelables)
        
        output.isEdit.sink { [weak self] isEdit, isDefaultEvent in
            self?.isEdit = isEdit
            self?.isDefaultEvent = isDefaultEvent
            self?.tableView.reloadData()
        }
        setupTitle()
    }
    
    private func setupTitle(event: EventModel) {
        eventTitleTextField.text = event.title
        eventDetailTextField.text = event.detail
        eventTitleTextField.isEnabled = !(event.isDefault || viewModel.isOudate)
        eventTitleTextField.resignFirstResponder()
    }
    
    private func setupReminderTime(time: Date) {
        reminderTimePicker.date = time
        reminderTimeLabel.text = time.format(partern: .timeShort)
    }
    
    private func setupDate(event: EventModel) {
        datePicker.date = event.date
        datePicker.isEnabled = !(event.isDefault || viewModel.isOudate)
        dateLabel.isEnabled = !(event.isDefault || viewModel.isOudate)
        dateLabel.text = event.date.format(partern: .fullDate)
        isUsingTimeSwitch.isOn = event.time != nil
        if let time = event.time {
            setupTimeValue(time: time)
        }
    }
    
    private func setupTimeValue(time: Date) {
        timeLabel.text = time.format(partern: .timeShort)
        timePicker.date = time
        timePicker.isEnabled = !viewModel.isOudate
        isUsingTimeSwitch.isEnabled = !viewModel.isOudate
    }
    
    override func setupNavigationView() {
        super.setupNavigationView()
        navigationItem.rightBarButtonItem = saveBarButton
        navigationItem.leftBarButtonItem = cancelBarButton
    }
    
    private func setupTitle() {
        navigationItem.title = viewModel.currentEvent == nil ? LocalizedString.addNewEventTitle : LocalizedString.tabBarItemEvents
    }
    
    override func refreshView(_ animated: Bool) {
        super.refreshView(animated)
        defautlNavi()
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if isEdit && !isDefaultEvent { return 5 }
        else { return 4 }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case timeLabelIndexPath.section:
            return isUsingTime ? 3 : 2
        case reminderIndexPath.section:
            return currentReminderType.isRiminderDay ? 2 : 1
        default:
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        guard !viewModel.isOudate else { return false }
        
        if #available(iOS 14.0, *) {
            return indexPath == reminderIndexPath || indexPath.section == deleteIndexPath.section
        }
        
        return !(indexPath == timeIndexPath || indexPath == pinIndexPath || indexPath.section == titleIndexPath.section)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        didSelectRowAt.send(indexPath)
    }
}

extension NewEventViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        eventDetailTextField.becomeFirstResponder()
        return false
    }
}

extension NewEventViewController {
    
    private func setupReminderTime() {
        if #available(iOS 14.0, *) {
            reminderTimeStackView.addSubview(reminderTimePicker)
            reminderTimePicker.fillRightAnchor()
        } else {
            reminderTimeStackView.addSubview(reminderTimeLabel)
            reminderTimeLabel.fillRightAnchor()
            reminderTimePicker.publisher(for: .editingDidEnd)
                .sink { [weak self] in
                    guard let self = self else { return }
                    self.reminderTimeLabel.text = self.reminderTimePicker.date.format(partern: .timeShort)
                }.store(in: &anyCancelables)
        }
    }
    
    private func setupDate() {
        if #available(iOS 14.0, *) {
            dateStackView.addSubview(datePicker)
            datePicker.fillRightAnchor()
        } else {
            dateStackView.addSubview(dateLabel)
            dateLabel.fillRightAnchor()
            datePicker.publisher(for: .editingDidEnd)
                .sink { [weak self] in
                    guard let self = self else { return }
                    self.dateLabel.text = self.datePicker.date.format(partern: .fullDate)
                }.store(in: &anyCancelables)
        }
    }
    
    private func setupTime() {
        if #available(iOS 14.0, *) {
            timeStackView.addArrangedSubview(timePicker)
        } else {
            timeStackView.addArrangedSubview(timeLabel)
            timePicker.publisher(for: .editingDidEnd)
                .sink { [weak self] in
                    guard let self = self else { return }
                    self.timeLabel.text = self.timePicker.date.format(partern: .timeShort)
                }.store(in: &anyCancelables)
        }
    }
}

extension NewEventViewController: UIAdaptivePresentationControllerDelegate {
    
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        dismissTrigger.send()
    }
}

extension UIView {
    func fillRightAnchor() {
        guard let superview = superview else { return }
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: superview.topAnchor),
            self.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
            self.trailingAnchor.constraint(equalTo: superview.trailingAnchor)
        ])
    }
}
