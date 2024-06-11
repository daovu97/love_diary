//
//  AboutAppViewController.swift
//  lovediary
//
//  Created by daovu on 22/03/2021.
//

import UIKit
import Combine
import Configuration

class AboutAppViewController: BasetableViewController<BaseViewModel> {
  
    // MARK: - Section 0
    private let shareAnalyticsIndexPath               = IndexPath(row: 1, section: 0)
    private let privacyPolicyIndexPath               = IndexPath(row: 0, section: 0)
    // MARK: - Section 1
    private let reviewInAppStore                = IndexPath(row: 0, section: 1)
    private let shareToFriends                = IndexPath(row: 1, section: 1)
    
    private lazy var didSelectRowAt = PassthroughSubject<IndexPath, Never>()
    
    @IBOutlet var icon: [UIImageView]!
    @IBOutlet weak var analyticLabel: UILabel!
    @IBOutlet weak var reviewStoreLabel: UILabel!
    @IBOutlet weak var sendAppFriendlabel: UILabel!
    @IBOutlet weak var analyticSwitch: UISwitch!
    @IBOutlet weak var privacyAndPolicyLabel: SettingTableViewLabel!
    
    private lazy var tableFooterViewLabel: ThemeCommonColorLabel = {
        let label = ThemeCommonColorLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12)
        label.text = tableFooterViewTitle()
        return label
    }()
    
    override func setupView() {
        super.setupView()
        analyticLabel.text = LocalizedString.analyticLabel
        reviewStoreLabel.text = LocalizedString.reviewOnAppstore
        sendAppFriendlabel.text = LocalizedString.sendToFriends
        privacyAndPolicyLabel.text = LocalizedString.privacyAndPolicyLabel
        
        tableView.tableFooterView = getTableFooterView()
        
        didSelectRowAt.sink {[weak self] indexPath in
            guard let self = self else { return }
            switch indexPath {
            case self.reviewInAppStore:
                ReviewHelper.reviewInStore()
            case self.shareToFriends:
                ReviewHelper.shareAppToFriend()?.show()
            case self.privacyPolicyIndexPath:
                self.showPrivacyPolicy()
            default: break
            }
        }.store(in: &anyCancelables)
        analyticSwitch.isOn = Settings.isAllowAnalytic.value
        analyticSwitch.publisher(for: .valueChanged).sink {[weak self] _ in
            Settings.isAllowAnalytic.value = self?.analyticSwitch.isOn ?? false
        }.store(in: &anyCancelables)
        
    }
    
    private func showPrivacyPolicy() {
        if let privacyUrl = URL(string:AppConfigs.appPrivacyUrl) {
            SettingsHelper.go(to: privacyUrl)
        }
    }
    
    override func setupNavigationView() {
        super.setupNavigationView()
        navigationItem.title = LocalizedString.aboutAppSettingTitle
    }
    
    override func refreshView(_ animated: Bool) {
        super.refreshView(animated)
        defautlNavi()
    }
    
    private func getTableFooterView() -> UIView {
        let footer = UIView(frame: .init(x: 0, y: 0, width: tableView.frame.width, height: 60))
        footer.backgroundColor = .clear
        footer.addSubview(tableFooterViewLabel)
        [tableFooterViewLabel.centerYAnchor.constraint(equalTo: footer.centerYAnchor),
         tableFooterViewLabel.centerXAnchor.constraint(equalTo: footer.centerXAnchor)]
            .forEach { $0.isActive = true }
        return footer
    }
    
    private func tableFooterViewTitle() -> String {
        return "\(LocalizedString.appName) \(SettingsHelper.getVersion()) by ©Dao"
    }
    
}

extension AboutAppViewController {
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == 0 ? 70 : .leastNonzeroMagnitude
    }
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return section == 0 ? getFooterView(text: LocalizedString.sharedAnalyticDetail) : nil
    }
    
    private func getFooterView(text: String) -> UIView {
        let view = UIView()
        let label = IncreaseHeightLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Fonts.getHiraginoSansFont(fontSize: 11, fontWeight: .regular)
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
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return indexPath != shareAnalyticsIndexPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        didSelectRowAt.send(indexPath)
    }
}

extension UIViewController {
    
    var isModal: Bool {
        
        let presentingIsModal = presentingViewController != nil
        let presentingIsNavigation = navigationController?.presentingViewController?.presentedViewController == navigationController
        let presentingIsTabBar = tabBarController?.presentingViewController is UITabBarController
        
        return presentingIsModal || presentingIsNavigation || presentingIsTabBar
    }
}
