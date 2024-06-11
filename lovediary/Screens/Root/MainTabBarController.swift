//
//  MainTabBarController.swift
//  QikNote
//
//  Created by daovu on 02/03/2021.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    private var dependency: ApplicationDependency
    
    private var tapCounter = 0
    private var previousViewController = UIViewController()
    private let maximumDoubleTapTimeInterval = 0.3
    
    init(dependency: ApplicationDependency) {
        self.dependency = dependency
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var anniversaryVC = AnniversaryViewController.instantiate { [weak self] in
        guard let self = self else { return nil }
        let navigator = AnniversaryNavigator(dependency: self.dependency)
        let viewModel = AnniversaryViewModel(dependency: self.dependency.getAnniversaryDependency(),
                                             navigator: navigator)
        let viewController = AnniversaryViewController(coder: $0, viewModel: viewModel)
        navigator.start(with: viewController)
        return viewController
    }
    
    lazy var eventViewController = EventViewController.instantiate {[weak self] in
        guard let self = self else { return nil }
        let navigator = EventNavigator(dependency: self.dependency)
        let viewModel = EventViewModel(navigator: navigator,
                                       dependecy: .init(eventManager: self.dependency.eventManager))
        let viewController = EventViewController(coder: $0, viewModel: viewModel)
        navigator.start(with: viewController)
        return viewController
    }
    
    lazy var diariesVC = DiariesViewController.instantiate {[weak self] in
        guard let self = self else { return nil }
        let diaryDependency = self.dependency.diaryDependency
        let navigator = DiariesNavigator(dependency: diaryDependency)
        let viewModel = DiariesViewModel(dependency: diaryDependency.getDiaryDependency(),
                                         navigator: navigator)
        let viewController = DiariesViewController(coder: $0, viewModel: viewModel)
        navigator.start(with: viewController)
        return viewController
    }
    
    lazy var photosViewController = PhotosViewController.instantiate {[weak self] in
        guard let self = self else { return nil }
        let diaryDependency = self.dependency.diaryDependency
        let navigator = PhotosNavigator(dependency: diaryDependency)
        let viewModel = GaleriesViewModel(dependency: diaryDependency.getGaleryDependency(),
                                          navigator: navigator)
        
        let photoViewController = PhotosViewController(coder: $0, viewModel: viewModel)
        navigator.start(with: photoViewController)
        return photoViewController
    }
    
    lazy var settingViewController = SettingsViewController.instantiate {[weak self] in
        guard let self = self else { return nil }
        let dependency = SettingViewModel.Dependency()
        let navigator = SettingsNavigator(dependency: self.dependency)
        let viewModel = SettingViewModel(dependency: dependency, navigator: navigator)
        let viewController = SettingsViewController(coder: $0, viewModel: viewModel)
        navigator.start(with: viewController)
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        addChild(viewController: anniversaryVC, item: .anniversary)
        addChild(viewController: eventViewController, item: .event)
        addChild(viewController: diariesVC, item: .diaries)
        addChild(viewController: photosViewController, item: .photos)
        addChild(viewController: settingViewController, item: .settings)
        selectedIndex = 0
        tabBar.isTranslucent = true
        selectedIndex = Settings.tabbarLastTime.value
    }
    
    private func addChild(viewController: UIViewController, item: TabBarItem) {
        viewController.tabBarItem = UITabBarItem(title: item.title, image: item.icon, tag: item.rawValue)
        let nav = BaseNavigationController(rootViewController: viewController)
        viewController.navigationItem.title = ""
        addChild(nav)
    }
    
    var isHidingTabBar = false
    
    func hideTabBarIfNeeded() {
        guard !self.isHidingTabBar else { return }
        self.isHidingTabBar = true
        self.setTabBar(hidden: true, animated: true)
    }

    func showTabBarIfNeeded() {
        guard self.isHidingTabBar else { return }
        self.isHidingTabBar = false
        self.setTabBar(hidden: false, animated: true)
    }
}
// swiftlint:disable force_cast
extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        tapCounter += 1
        let didTapSameTabTwice = (previousViewController == viewController)
        previousViewController = viewController
        
        if tapCounter == 2 && didTapSameTabTwice {
            tapCounter = 0
            if let diariesViewController = UIApplication.topViewController() as? DiariesViewController {
                diariesViewController.resetToToday()
            }
        }
        
        if tapCounter == 1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + maximumDoubleTapTimeInterval, execute: {
                self.tapCounter = 0
            })
        }
        
        if UIApplication.topViewController() is SettingsViewController {
            return
        } else {
            Settings.tabbarLastTime.value = selectedIndex
        }
    }
}
// swiftlint:enable force_cast

private enum TabBarItem: Int, CaseIterable {
    case anniversary
    case event
    case diaries
    case photos
    case settings
    
    var icon: UIImage? {
        switch self {
        case .anniversary: return UIImage(systemName: "heart.fill")
        case .event: return UIImage(named: "ic_lineweight")
        case .diaries: return UIImage(named: "text_book_closed")
        case .photos: return UIImage(named: "ic_photo_on_rectangle_angled")
        case .settings: return UIImage(named: "gearshape")
        }
    }
    
    var title: String? {
        switch self {
        case .anniversary: return LocalizedString.tabBarItemPlanner
        case .diaries: return LocalizedString.tabBarItemCalendar
        case .photos: return LocalizedString.tabBarItemPhotos
        case .settings: return LocalizedString.tabBarItemSettings
        case .event: return LocalizedString.tabBarItemEvents
        }
    }
}
var kAnimationDuration = 0.3
extension UITabBarController {
    
    func setTabBar(hidden: Bool, animated: Bool) {
        let animationDuration = animated ? kAnimationDuration : 0
        UIView.animate(withDuration: animationDuration, animations: {
            var frame = self.tabBar.frame
            frame.origin.y = self.view.frame.height
            if !hidden {
                frame.origin.y -= frame.height
            } else {
                let backgroundImageSize = self.tabBar.backgroundImage?.size ?? CGSize.zero
                let heightDiff: CGFloat = backgroundImageSize.height - frame.height
                // If background image size is large, tabBar top seem.
                if heightDiff > 0 {
                    frame.origin.y += heightDiff
                }
            }
            self.tabBar.frame = frame
        }, completion:nil)
    }
}

extension UIViewController {
    func hideTabbar() {
        if let tabbarController = self.tabBarController as? MainTabBarController {
            tabbarController.hideTabBarIfNeeded()
        }
    }
    
    func showTabbar() {
        if let tabbarController = self.tabBarController as? MainTabBarController {
            tabbarController.showTabBarIfNeeded()
        }
    }
}
