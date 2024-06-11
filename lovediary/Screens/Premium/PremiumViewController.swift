//
//  PremiumViewController.swift
//  lovediary
//
//  Created by daovu on 19/04/2021.
//

import UIKit
import Combine

class PremiumViewController: BaseViewController<PremiumViewModel> {
    
    @IBOutlet var spacingConstraints: [NSLayoutConstraint]!
    @IBOutlet weak var premiumTitleLabel: IncreaseHeightLabel!
    
    @IBOutlet weak var unlimitBackgroundLabel: IncreaseHeightLabel!
    @IBOutlet weak var unlimitBackgroundDetailLabel: IncreaseHeightLabel!
    
    @IBOutlet weak var removeAdsLabel: IncreaseHeightLabel!
    @IBOutlet weak var removeAdsDetailLabel: IncreaseHeightLabel!
    
    @IBOutlet weak var moreFuncionLabel: IncreaseHeightLabel!
    @IBOutlet weak var moreFuncionDetailLabel: IncreaseHeightLabel!
    
    @IBOutlet weak var priceLabel: IncreaseHeightLabel!
    
    @IBOutlet weak var purchaseButton: UIButton!
    @IBOutlet weak var restoreButton: UIButton!
    
    @IBOutlet var iconBackgrounds: [UIView]!
    private lazy var closeButton = UIBarButtonItem(image: Images.Icon.xmark, style: .done, target: self, action: nil)
    
    override func setupView() {
        super.setupView()
        
        Publishers.Merge(isIAPPurchase().flatMap { isPurchase -> AnyPublisher<Void, Never> in
            if isPurchase { return .just(()) }
            else { return .empty() }
        }, closeButton.tapPublisher).sink {[weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }.store(in: &anyCancelables)
        applyTheme()
        setupChildView()
        setupLocalizeString()
        
        spacingConstraints.forEach { $0.constant = $0.constant / 1100 * UIApplication.height }
    }
    
    private func setupLocalizeString() {
        premiumTitleLabel.text = LocalizedString.premiumTitle
        unlimitBackgroundLabel.text = LocalizedString.unlimitBackgroundTitle
        unlimitBackgroundDetailLabel.text = LocalizedString.unlimitBackgroundDetailTitle
        removeAdsLabel.text = LocalizedString.removeAdsTitle
        removeAdsDetailLabel.text = LocalizedString.removeAdsDetailTitle
        moreFuncionLabel.text = LocalizedString.moreFuncionTitle
        moreFuncionDetailLabel.text = LocalizedString.moreFuncionDetailTitle
        purchaseButton.setTitle(LocalizedString.purchaseButtonTitle, for: .normal)
        restoreButton.setTitle(LocalizedString.restoreButtonTitle, for: .normal)
    }
    
    private func setupChildView() {
        premiumTitleLabel.setLineSpacing(8)
        unlimitBackgroundDetailLabel.setLineSpacing(6, alignment: .natural)
        removeAdsDetailLabel.setLineSpacing(6)
        moreFuncionDetailLabel.setLineSpacing(6)
        unlimitBackgroundLabel.setLineSpacing(6)
        removeAdsLabel.setLineSpacing(6)
        moreFuncionLabel.setLineSpacing(6)
        purchaseButton.titleLabel?.font = Fonts.getHiraginoSansFont(fontSize: 20, fontWeight: .bold)
        restoreButton.titleLabel?.font = Fonts.getHiraginoSansFont(fontSize: 13, fontWeight: .regular)
        
    }
    
    private func applyTheme() {
        let toneColor = Colors.toneColor
        iconBackgrounds.forEach { $0.backgroundColor = toneColor }
        purchaseButton.backgroundColor = toneColor
        restoreButton.setTitleColor(Themes.current.settingTableViewColor.text, for: .normal)
        navigationController?.navigationBar.tintColor = Colors.toneColor
        defautlNavi(hidenShadow: true, backgroundColor: Themes.current.commonColor.background)
    }
    
    override func setupNavigationView() {
        super.setupNavigationView()
        navigationItem.rightBarButtonItem = closeButton
    }
    
    override func refreshView(_ animated: Bool) {
        super.refreshView(animated)
        navigationController?.navigationBar.tintColor = Colors.toneColor
        defautlNavi(hidenShadow: true, backgroundColor: Themes.current.commonColor.background)
    }
    
    private lazy var requestProductTrigger = PassthroughSubject<Void, Never>()
    
    override func bindViewModel() {
        super.bindViewModel()
        let unlockPremiumTrigger = Publishers.Merge(purchaseButton.tapPublisher.map { return PremiumAction.purchase }, restoreButton.tapPublisher.map { return .restore }).eraseToAnyPublisher()
        let input = PremiumViewModel.Input(unlockPremiumTrigger: unlockPremiumTrigger, requestProductTrigger: requestProductTrigger.eraseToAnyPublisher())
        let output = viewModel.transform(input)
        output.actionVoid.sink{}.store(in: &anyCancelables)
        output.productPrice
            .receive(on: DispatchQueue.main)
            .sink { [weak self]  in self?.priceLabel.text = $0 }
            .store(in: &anyCancelables)
        requestProductTrigger.send()
    }
}

extension PremiumViewController {
    class func show() {
        guard !Settings.isRemoveAds.value else { return }
        let viewController = PremiumViewController.instantiate {
            let viewModel = PremiumViewModel()
            let vc = PremiumViewController(coder: $0, viewModel: viewModel)
            return vc
        }
        let nav = BaseNavigationController(rootViewController: viewController)
        nav.modalPresentationStyle = .fullScreen
        UIApplication.topViewController()?.present(nav, animated: true)
    }
}
