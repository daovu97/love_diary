//
//  AdsHelper.swift
//  lovediary
//
//  Created by daovu on 29/03/2021.
//

import Foundation
import UIKit.UIViewController
import GoogleMobileAds
import AppTrackingTransparency
import AdSupport
import Configuration
import Combine

@objc protocol AdsPresented {
    @objc optional func removeAdsIfNeeded(bannerView: UIView)
    @objc optional func bannerViewDidShow(bannerView: UIView, height: CGFloat)
}

enum AdsLoadResult {
    case error
    case loaded
    case initial
}

class AdsHelper: NSObject, GADBannerViewDelegate {
    
    var anycancelable = Set<AnyCancellable>()
    
    private var bannerView: GADBannerView?
    var bannerViewDidloaded = AdsLoadResult.initial
    
    static let shared = AdsHelper()
    
    private override init() {
        super.init()
    }
    
    static var showAdsAfterDay: Int {
        return Int(AppConfigs.showAdsAfterDay)
    }
    
    static func shouldDisplayAds() -> Bool {
        return !Settings.isRemoveAds.value && Utilities.usedAppDays() >= showAdsAfterDay
    }
    
    @available(iOS 14.5, *)
    private func checkAtt() {
        if ATTrackingManager.trackingAuthorizationStatus != .authorized {
            requestIDFA { _ in }
        }
    }
    
    func configure() {
        setupAds()
        if #available(iOS 14.5, *) {
            checkAtt()
        }
    }
    
    private func setupAds() {
        guard AdsHelper.shouldDisplayAds() else { return }
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        self.bannerView = GADBannerView()
        self.bannerView!.adUnitID = AppConfigs.adUnitID
        self.bannerView!.delegate = self
        self.bannerView!.backgroundColor = .clear
        self.bannerView?.load(GADRequest())
    }
    
    func getBannerView() -> GADBannerView? {
        return bannerView
    }
    
    static func adsSize(width: CGFloat) -> GADAdSize {
        return GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(width)
    }
    
    func removeBannerView() {
        bannerView?.removeFromSuperview()
        bannerView = nil
    }
    
    func requestIDFA(completion: ((Bool) -> Void)?) {
        if #available(iOS 14.5, *) {
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                completion?(status == .authorized)
            })
        } else {
            completion?(true)
        }
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerViewDidloaded = .loaded
        NotificationCenter.default.post(name: .bannerViewLoadedNotification, object: bannerViewDidloaded)
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        bannerViewDidloaded = .error
        NotificationCenter.default.post(name: .bannerViewLoadedNotification, object: bannerViewDidloaded)
    }
    
}

extension AdsPresented where Self: UIViewController {
    
    func setBannerView(with container: UIView,
                       heightConstraint: NSLayoutConstraint,
                       forceUpdate: Bool = false,
                       fixedWidth: CGFloat? = nil) {
        guard AdsHelper.shouldDisplayAds() else {
            container.isHidden = true
            heightConstraint.constant = 0
            return
        }
        
        guard let bannerView = AdsHelper.shared.getBannerView(),
              container.subviews.firstIndex(of: bannerView) == nil || forceUpdate
        else {
            return
        }
        
        AdsHelper.shared.anycancelable.cancel()
        DispatchQueue.main.async {
            self.initBannerView(container, bannerView, heightConstraint, fixedWidth)
        }
       
        addAdsRemoveNotification(container, heightConstraint)
    }
    
    private func addAdsLoadedNotification(bannerView: UIView, height: CGFloat,
                                          heightConstraint: NSLayoutConstraint) {
        heightConstraint.constant = height
        self.bannerViewDidShow?(bannerView: bannerView, height: height)
    }
    
    
    
    // fixedWidth: is fixed size of banner, if nil return width of window
    private func initBannerView(_ container: UIView,
                                _ bannerView: GADBannerView,
                                _ heightConstraint: NSLayoutConstraint,
                                _ fixedWidth: CGFloat? = nil) {
        container.isHidden = false
        container.backgroundColor = .clear
        container.addSubview(bannerView)
        bannerView.rootViewController = self
        
        let adSize = AdsHelper.adsSize(width: fixedWidth ?? UIApplication.windowBound.width)
        bannerView.adSize = adSize
        heightConstraint.constant = adSize.size.height
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bannerView.topAnchor.constraint(equalTo: container.topAnchor),
            bannerView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            bannerView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            bannerView.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
        addAdsLoadedNotification(bannerView: bannerView, height: adSize.size.height,
                                 heightConstraint: heightConstraint)
    }
    
    private func addAdsRemoveNotification(_ container: UIView, _ heightConstraint: NSLayoutConstraint) {
        NotificationCenter.default.publisher(for: .IAPHelperPurchaseNotification)
            .compactMap { (notification) -> Bool? in
                return notification.object as? Bool
            }.sink {[weak self] isPurchase in
                if isPurchase {
                    self?.removeAdsIfNeeded?(bannerView: container)
                    AdsHelper.shared.removeBannerView()
                    heightConstraint.constant = 0
                }
            }.store(in: &AdsHelper.shared.anycancelable)
    }
}

