//
//  SettingsViewController.swift
//  QikNote
//
//  Created by daovu on 02/03/2021.
//

import UIKit
import Combine

class SettingsViewController: BaseViewController<SettingViewModel>, ThemeNotification {
    var subscription: AnyCancellable?
    
    func themeChange() {
        tableView.backgroundColor = Themes.current.settingTableViewColor.background
        tableView.reloadData()
        tableView.reloadInputViews()
        tableView.reloadSectionIndexTitles()
    }
    
    deinit {
        removeThemeObserver()
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var adsContainerView: UIView!
    @IBOutlet weak var adsHeightConstrain: NSLayoutConstraint!
    private var settingDatas: [SettingViewModel.SectionInfo] = SettingViewModel.SettingData.generateData()
    private let sectionHeaderHeight = CGFloat(34)
    
    private lazy var didSelectRowAt = PassthroughSubject<IndexPath, Never>()
    
    override func setupView() {
        super.setupView()
        addThemeObserver()
        themeChange()
        self.tableView.contentInset.bottom = 30
        isIAPPurchase().sink {[weak self] isPurchase in
                if isPurchase {
                    self?.refreshData()
                }
            }.store(in: &anyCancelables)
    }
    
    override func setupNavigationView() {
        super.setupNavigationView()
        navigationItem.title = LocalizedString.settingScreenTitle
    }
    
    func refreshData() {
        settingDatas = SettingViewModel.SettingData.generateData()
        tableView.reloadData()
        tableView.reloadSectionIndexTitles()
    }
    
    override func refreshView(_ animated: Bool) {
        super.refreshView(animated)
        defautlNavi()
        setBannerView(with: adsContainerView, heightConstraint: adsHeightConstrain)
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        let didSelect = didSelectRowAt.compactMap {[weak self] indexPath -> SettingViewModel.Cell? in
            return self?.settingDatas[indexPath.section].cells[indexPath.row]
        }
        
        let input = SettingViewModel.Input(didSelectRowTrigger: didSelect.eraseToAnyPublisher())
        let output = viewModel.transform(input)
        output.actionVoid.sink { }.store(in: &anyCancelables)
    }
}

extension SettingsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let cell = settingDatas[indexPath.section].cells[indexPath.row]
        if (Settings.isRemoveAds.value && cell == .removeAds) {
            return false
        } else {
            return true
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return settingDatas.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingDatas[section].cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionInfo = settingDatas[indexPath.section]
        let row = sectionInfo.cells[indexPath.row]
        switch row.info.type {
        case .normal(let icon, let title, let isDisable):
            let cell = tableView.dequeueReusableCell(SettingNormalTableViewCell.self, for: indexPath)
            cell.bind(icon: icon, title: title)
            cell.setDisable(isDisable: isDisable)
            return cell
        case .withSwitch(let icon, let title, let isOn):
            let cell = tableView.dequeueReusableCell(SettingWithSwitchTableViewCell.self, for: indexPath)
            cell.bind(icon: icon, title: title, isOn: isOn)
//            cell.didValueChange = { [weak self] value in
//                if value {
//                    self?.passcodeValueChange.send(indexPath)
//                } else {
//                    PascodeManager.shared.removePasscode()
//                }
//            }
            return cell
        case .delete(let icon, let title):
            let cell = tableView.dequeueReusableCell(SettingDeleteTableViewCell.self, for: indexPath)
            cell.bind(icon: icon, title: title)
            return cell
        }
    }
}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return getHeaderViewForSection(with: settingDatas[section].title)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return getFooterView(text: settingDatas[section].footer)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard !settingDatas[section].footer.isEmpty else { return 0 }
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard !settingDatas[section].title.isEmpty else { return 0 }
        return sectionHeaderHeight
    }
    
    private func getFooterView(text: String) -> UIView? {
        guard !text.isEmpty else { return nil }
        let view = UIView()
        let label = IncreaseHeightLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Fonts.getHiraginoSansFont(fontSize: 12, fontWeight: .regular)
        label.numberOfLines = 0
        label.text = text
        label.textAlignment = .left
        label.sizeToFit()
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0)
        ])
        label.setLineSpacing(6)
        return view
    }
    
    private func getHeaderViewForSection(with title: String) -> UIView? {
        guard !title.isEmpty else { return nil }
        let header = UIView()
        header.backgroundColor = .clear
        let headerTitle = ThemeCommonColorLabel()
        header.addSubview(headerTitle)
        headerTitle.translatesAutoresizingMaskIntoConstraints = false
        [headerTitle.centerYAnchor.constraint(equalTo: header.centerYAnchor),
         headerTitle.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 20)]
            .forEach { $0.isActive = true }
        headerTitle.frame.origin.x = 20
        headerTitle.font = Fonts.getHiraginoSansFont(fontSize: 12, fontWeight: .regular)
        headerTitle.text = title
        return header
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let cell = settingDatas[indexPath.section].cells[indexPath.row]
        if Settings.isRemoveAds.value && cell == .removeAds  {
            return nil
        } else {
            return indexPath
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        didSelectRowAt.send(indexPath)
    }
}

extension SettingsViewController: AdsPresented {
    func bannerViewDidShow(bannerView: UIView, height: CGFloat) {
        self.tableView.contentInset.bottom = height + 50
    }
    
    func removeAdsIfNeeded(bannerView: UIView) {
        self.tableView.contentInset.bottom = 30
    }
}

extension UIViewController {
    func isIAPPurchase() -> AnyPublisher<Bool, Never> {
      return NotificationCenter.default.publisher(for: .IAPHelperPurchaseNotification)
            .receive(on: DispatchQueue.main)
            .compactMap { (notification) -> Bool? in
               return notification.object as? Bool
            }.eraseToAnyPublisher()
    }
}
