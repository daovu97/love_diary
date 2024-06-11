//
//  PremiumViewModel.swift
//  lovediary
//
//  Created by daovu on 19/04/2021.
//

import Foundation
import Combine
import StoreKit

enum PremiumAction {
    case purchase
    case restore
}

class PremiumViewModel: ViewModelType {
    
    private let iAPHelper = IAPHelper.shared
    
    // MARK: - Ads
    private var productRemoveAds: SKProduct?
    
    struct Input {
        let unlockPremiumTrigger: AnyPublisher<PremiumAction,Never>
        let requestProductTrigger: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let productPrice: AnyPublisher<String, Never>
        let actionVoid: AnyPublisher<Void, Never>
    }
    
    func transform(_ input: Input) -> Output {
        let purchase = input.unlockPremiumTrigger
            .debounce(for: .milliseconds(200), scheduler: DispatchQueue.main)
            .flatMap { [weak self] action -> AnyPublisher<Void, Never> in
                guard let self = self else { return .empty() }
                return self.unlockPremium(action: action)
            }
        
        let price = input.requestProductTrigger.flatMap {[weak self] _ -> AnyPublisher<String, Never> in
            guard let self = self else { return .empty() }
            if let product = self.iAPHelper.productRemoveAds {
                self.productRemoveAds = product
                return .just(IAPHelper.formatPrice(from: product))
            } else {
                return self.iAPHelper.requestAdsProductInfo()
                    .receive(on: DispatchQueue.main)
                    .map {[weak self] product -> String in
                        self?.iAPHelper.productRemoveAds = product
                        self?.productRemoveAds = product
                        return IAPHelper.formatPrice(from: product)
                    }.eraseToAnyPublisher()
            }
        }
        
        return .init(productPrice: price.eraseToAnyPublisher(),
                     actionVoid: purchase.eraseToAnyPublisher())
    }
    
    private func unlockPremium(action: PremiumAction) -> AnyPublisher<Void, Never> {
        if action == .restore {
            iAPHelper.restorePurchases()
            return .empty()
        } else {
            if let product = iAPHelper.productRemoveAds {
                return removeAds(product: product)
            } else {
                return iAPHelper.requestAdsProductInfo()
                    .receive(on: DispatchQueue.main)
                    .flatMap({[weak self] product -> AnyPublisher<Void, Never> in
                        guard let self = self else { return .empty() }
                        self.productRemoveAds = product
                        self.iAPHelper.productRemoveAds = product
                        return self.removeAds(product: product).eraseToAnyPublisher()
                    }).eraseToAnyPublisher()
            }
        }
    }
    
    private func removeAds(product: SKProduct) -> AnyPublisher<Void, Never> {
        let messageRemoveAds = String(format: LocalizedString.removeAdsConfirmLabel + "  \(IAPHelper.formatPrice(from: product))")
        
        return AlertManager.shared
            .showConfirmMessage(message: messageRemoveAds,
                                confirm: LocalizedString.yes,
                                cancel: LocalizedString.cancel)
            .receiveOutput {
                if $0 == .confirm {
                    IAPHelper.shared.buyProduct(product)
                }
            }.eraseToVoidAnyPublisher()
    }
}
