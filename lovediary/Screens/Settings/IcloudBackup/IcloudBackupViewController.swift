//
//  IcloudBackupViewController.swift
//  lovediary
//
//  Created by daovu on 23/04/2021.
//

import Foundation
import UIKit
import Combine

class IcloudBackupViewController: BasetableViewController<IcloudBackupViewModel> {
    @IBOutlet weak var icloudIcon: UIImageView!
    @IBOutlet weak var backupSizeLabel: UILabel!
    @IBOutlet weak var moddifiedTimeLabel: UILabel!
    @IBOutlet weak var overwriteBakupLabel: SettingTableViewLabel!
    @IBOutlet weak var restoreBackupLabel: SettingTableViewLabel!
    @IBOutlet weak var deletebackupLabel: UILabel!
    @IBOutlet weak var createBackupLabel: SettingTableViewLabel!
    
    @IBOutlet weak var createBackupCell: SettingNormalTableViewCell!
    @IBOutlet weak var deleteBackupCell: SettingNormalTableViewCell!
    
    private var haveBackup = false
    private var reloadButton = UIBarButtonItem(image: Images.Icon.reload, style: .plain, target: self, action: nil)
    
    private lazy var didSelectCellAt = PassthroughSubject<IndexPath, Never>()
    private lazy var loadTrigger = PassthroughSubject<Void, Never>()
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return haveBackup ? 2 : 1
    }
    
    override func setupView() {
        super.setupView()
        navigationItem.rightBarButtonItem = reloadButton
        title = LocalizedString.icloudSettingTitle
//        updateDateTitleLabel.text = LocalizedString.ic01UpdateDate
        createBackupLabel.text = LocalizedString.ic01CreateIcloudBackup
        overwriteBakupLabel.text = LocalizedString.ic01OverrideIcloudBackup
        restoreBackupLabel.text = LocalizedString.ic01RestoreFromIcloudBackup
        deletebackupLabel.text = LocalizedString.ic01RemoveIcloudBackup
    }
    
    private func applyTheme() {
        changeIcloudIcon()
    }
    
    private func changeIcloudIcon() {
        icloudIcon.tintColor = haveBackup ? Colors.toneColor : .lightGray
        backupSizeLabel.textColor = haveBackup ? Colors.toneColor : .lightGray
    }
    
    //MARK: - IndexPath
    var createBackupIndexPath: IndexPath? {
        return haveBackup ? nil : IndexPath(row: 0, section: 0)
    }
    
    var deleteBackupIndexPath: IndexPath? {
        return haveBackup ? IndexPath(row: 0, section: 1) : nil
    }
    
    var overWriteBackupIndexPath: IndexPath? {
        return haveBackup ? IndexPath(row: 0, section: 0) : nil
    }
    
    var restoreBackupIndexPath: IndexPath? {
        return haveBackup ? IndexPath(row: 1, section: 0) : nil
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        let didSelectCell = didSelectCellAt.debounce(for: .milliseconds(200), scheduler: DispatchQueue.main).share()
        let overWriteBackup = didSelectCell.filter { $0 == self.overWriteBackupIndexPath }
            .flatMap { _ -> AnyPublisher<Void, Never> in
               return AlertManager.shared.showConfirmMessage(message: LocalizedString.ic01OverrideDialogTitle,
                                                                 confirm: LocalizedString.ic01OverrideDialogConfirmButtonTitle,
                                                                 cancel: LocalizedString.ic01DialogCancelTitle,
                                                                 isDelete: true).filter { $0 == .confirm }
                .eraseToVoidAnyPublisher()
            }.eraseToVoidAnyPublisher()
        
        
        
        let restoreBackup = didSelectCell.filter { $0 == self.restoreBackupIndexPath }
            .flatMap { _ in
                return AlertManager.shared.showConfirmMessage(message: LocalizedString.ic01RestoreDialogTitle,
                                                              confirm: LocalizedString.ic01RestoreDialogConfirmButtonTitle,
                                                              cancel: LocalizedString.ic01DialogCancelTitle,
                                                              isDelete: true).filter { $0 == .confirm }.eraseToVoidAnyPublisher()
            }.eraseToVoidAnyPublisher()
        let createBackup = didSelectCell.filter { $0 == self.createBackupIndexPath }.eraseToVoidAnyPublisher()
        let deleteBackup = didSelectCell.filter { $0 == self.deleteBackupIndexPath }.flatMap { _ in
            return AlertManager.shared.showConfirmMessage(message: LocalizedString.ic01RemoveDialogTitle,
                                                             confirm: LocalizedString.ic01RemoveDialogConfirmButtonTitle,
                                                             cancel: LocalizedString.ic01DialogCancelTitle,
                                                             isDelete: true).filter { $0 == .confirm }.eraseToVoidAnyPublisher()
        }.eraseToVoidAnyPublisher()
        
        let load = Publishers.Merge(loadTrigger, reloadButton.tapPublisher)
        let input = IcloudBackupViewModel.Input(loadTrigger: load.eraseToAnyPublisher(),
                                                overWriteBackup: overWriteBackup,
                                                restoreBackup: restoreBackup,
                                                createBackup: createBackup,
                                                deleteBackup: deleteBackup)
        let output = viewModel.transform(input)
        
        output.fileInfo.sink {[weak self] fileInfo in
            self?.haveBackup = fileInfo != nil
            self?.tableView.reloadData()
            self?.backupSizeLabel.text = fileInfo?.size ?? LocalizedString.ic01NotExistsBackupStatus
            self?.moddifiedTimeLabel.text = fileInfo?.updateDate ?? ""
            self?.changeIcloudIcon()
        }.store(in: &anyCancelables)
        
        output.isLoading.sink { isLoading in
            if isLoading { ProgressHelper.shared.show() }
            else { ProgressHelper.shared.hide() }
        }.store(in: &anyCancelables)
        
        output.errorContent.flatMap { errorString -> AnyPublisher<Void, Never> in
            return AlertManager.shared.showErrorMessage(message: errorString)
        }.sink {}.store(in: &anyCancelables)
        
        output.actionVoid.sink { }.store(in: &anyCancelables)
        loadTrigger.send()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if haveBackup {
                return 2
            } else {
                return 1
            }
        case 1:
            if haveBackup {
                return 1
            } else {
                return 0
            }
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if haveBackup {
                return super.tableView(tableView, cellForRowAt: indexPath)
            } else {
                return createBackupCell
            }
        case 1:
            if haveBackup {
                return deleteBackupCell
            } else {
                return UITableViewCell()
            }
        default: return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        didSelectCellAt.send(indexPath)
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == tableView.numberOfSections - 1 ? 70 : .leastNonzeroMagnitude
    }
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return section == tableView.numberOfSections - 1 ? getFooterView(text: LocalizedString.backupContainTitle) : nil
    }
    
    private func getFooterView(text: String) -> UIView {
        let view = UIView()
        let label = IncreaseHeightLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Fonts.getHiraginoSansFont(fontSize: 11, fontWeight: .regular)
        label.numberOfLines = 0
        label.text = text

        label.sizeToFit()
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0)
        ])
        label.setLineSpacing(6)
        label.textAlignment = .center
        return view
    }
}

extension IcloudBackupViewController {
    class func get(dependency: ApplicationDependency) -> IcloudBackupViewController {
        return IcloudBackupViewController.instantiate {
            let navigator = IcloudBackupNavigator(dependency: dependency)
            let viewModel = IcloudBackupViewModel(navigator: navigator,
                                                  manager: dependency.getIcloudBackupManagerType())
            let viewController = IcloudBackupViewController(coder: $0, viewModel: viewModel)
            navigator.start(with: viewController)
            return viewController
        }
    }
}
