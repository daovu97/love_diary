//
//  PasscodeSettingViewController.swift
//  lovediary
//
//  Created by daovu on 30/03/2021.
//

import UIKit
import Combine
import LocalAuthentication

class PasscodeSettingViewController: BasetableViewController<BaseViewModel>, ThemeNotification {
    var subscription: AnyCancellable?
    
    func themeChange() {
        tableView.backgroundColor = Themes.current.settingTableViewColor.background
    }
    
    deinit {
        removeThemeObserver()
    }
    
    @IBOutlet weak var sensorIconImageView: ThemeImageIcon!
    @IBOutlet weak var usingSensorSwitch: UISwitch!
    @IBOutlet weak var lockImmediatelySwitch: UISwitch!
    
    @IBOutlet weak var usingSensorTitle: SettingTableViewLabel!
    @IBOutlet weak var changePasscodeTitle: SettingTableViewLabel!
    @IBOutlet weak var turnOffPasscodeTitle: SettingTableViewLabel!
    @IBOutlet weak var lockImmediatelyTitle: SettingTableViewLabel!
    
    @IBOutlet weak var lockImmediatelyCell: SettingTableViewCell!
    
    
    @IBOutlet weak var usingSensorCell: UITableViewCell!
    //MARK: -Indexpath
    
    private let usingFaceIDIndexPath = IndexPath(row: 0, section: 0)
    private let lockImmediatelyIndexPath = IndexPath(row: 1, section: 0)
    private let changePasscodeIndexPath = IndexPath(row: 0, section: 1)
    private let turnOffPasscodeIndexPath = IndexPath(row: 1, section: 1)
    
    private lazy var didSelectRowPublisher = PassthroughSubject<IndexPath, Never>()
    private lazy var biometricType = PascodeManager.shared.biometricType
    
    private func setIsLockImmediately() {
        lockImmediatelySwitch.isOn = PascodeManager.shared.isLockImmediately
        
        lockImmediatelySwitch.publisher(for: .valueChanged)
            .sink { [weak self] in
                guard let self = self else { return }
                PascodeManager.shared.setLockImmediately(isImmediate: self.lockImmediatelySwitch.isOn)
            }.store(in: &anyCancelables)
    }
    
    override func setupView() {
        super.setupView()
        setupLocalizeString()
        setUpUsingFaceID()
        setupObserver()
        addThemeObserver()
        themeChange()
        setIsLockImmediately()
    }
    
    override func setupNavigationView() {
        super.setupNavigationView()
        navigationItem.title = LocalizedString.passcodeSettingTitle
    }
    
    private func setupObserver() {
        didSelectRowPublisher
            .debounce(for: .milliseconds(200), scheduler: DispatchQueue.main)
            .sink {[weak self] indexPath in
                guard let self = self else { return }
                switch indexPath {
                case self.changePasscodeIndexPath:
                    self.changePassCode()
                case self.turnOffPasscodeIndexPath:
                    self.turnOffPasscode()
                default: break
                }
            }.store(in: &anyCancelables)
    }
    
    private func changePassCode() {
        PascodeManager.shared.changePasscode(from: self)
    }
    
    private func turnOffPasscode() {
        PascodeManager.shared.deactive(from: UIApplication.topViewController(), onWillSuccessDismiss: { [weak self] in
            if $0 == .deactive {
                DispatchQueue.main.async {
                    PascodeManager.shared.setUsingSensor(isUsing: false)
                    self?.navigationController?.popViewController(animated: true)
                    self?.navigationController?.isNavigationBarHidden = false
                }
            }
        })
    }
    
    private func setUpUsingFaceID() {
        usingSensorSwitch.isOn = PascodeManager.shared.isUsingSensor
        usingSensorSwitch.publisher(for: .valueChanged)
            .receive(on: DispatchQueue.main)
            .flatMap {[weak self] _ -> AnyPublisher<Bool, Never> in
                guard let self = self else { return .empty() }
                if self.usingSensorSwitch.isOn {
                    return self.checkFaceID()
                } else {
                    return .just(false)
                }
            }
            .sink { PascodeManager.shared.setUsingSensor(isUsing: $0)}
            .store(in: &anyCancelables)
    }
    
    private func checkFaceID() -> AnyPublisher<Bool, Never> {
        return Deferred {
            Future { promise in
                let context = LAContext()
                var policy: LAPolicy = .deviceOwnerAuthenticationWithBiometrics
                policy = .deviceOwnerAuthentication
                var err: NSError?
                guard context.canEvaluatePolicy(policy, error: &err) else {
                    promise(.success(false))
                    return
                }
                context.evaluatePolicy(policy, localizedReason: ALConstants.kLocalizedReason,
                                       reply: {  success, error in
                                        promise(.success(success))
                                       })
            }
        }.eraseToAnyPublisher()
        
    }
    
    private func setupLocalizeString() {
        sensorIconImageView.image = biometricType.icon
        usingSensorTitle.text = String(format: LocalizedString.usingSensorTitle, "\(biometricType.title)")
        changePasscodeTitle.text = LocalizedString.changePasscodeTitle
        turnOffPasscodeTitle.text = LocalizedString.turnOffPasscodeTitle
        lockImmediatelyTitle.text = LocalizedString.lockImmediatelyTitle
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        didSelectRowPublisher.send(indexPath)
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return indexPath != usingFaceIDIndexPath
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case usingFaceIDIndexPath.section:
            return biometricType == .none ? 1 : 2
        case changePasscodeIndexPath.section:
            return 2
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if biometricType == .none {
                return lockImmediatelyCell
            }
            super.tableView(tableView, cellForRowAt: indexPath)
        }
        return super.tableView(tableView, cellForRowAt: indexPath)
    }
}
