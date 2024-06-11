//
//  AnniversaryViewController.swift
//  lovediary
//
//  Created by daovu on 10/03/2021.
//

import UIKit
import Combine

class AnniversaryViewController: BaseViewController<AnniversaryViewModel> {
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var loveInforView: LoveInfoView!
    @IBOutlet weak var dateTimeView: WatchDateTimeView!
    @IBOutlet weak var animationView: LoveAnimationView!
    
    private lazy var shareBarButton = UIBarButtonItem(image: Images.Icon.share,
                                                      style: .done, target: self, action: nil)
    
    private lazy var moreOptionBarButton = UIBarButtonItem(image: Images.Icon.photo,
                                                           style: .done, target: self, action: nil)
    
    private lazy var refreshUserTrigger = PassthroughSubject<Void, Never>()
    private lazy var refreshTimeTrigger = PassthroughSubject<Void, Never>()
    private lazy var showDateSelect = PassthroughSubject<Void, Never>()
    
    override func setupView() {
        super.setupView()
        shareAction()
        requestReviewIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshUserTrigger.send()
        refreshTimeTrigger.send()
    }
    
    override func setupNavigationView() {
        super.setupNavigationView()
        navigationItem.title = ""
        navigationItem.rightBarButtonItems = [moreOptionBarButton, shareBarButton]
    }
    
    override func refreshView(_ animated: Bool) {
        super.refreshView(animated)
        replayAnimationView()
        transparentNavi()
    }
    
    func replayAnimationView() {
        DispatchQueue.main.async {
            self.animationView.play()
        }
        
    }
    
    private func shareAction() {
        shareBarButton.tapPublisher
            .debounce(for: .milliseconds(200), scheduler: DispatchQueue.main)
            .flatMap {[weak self] _ -> AnyPublisher<Void, Never> in
                guard let self = self else { return .empty() }
                self.animationView.stop()
                return self.shareImage(from: self.view)
            }
            .sink {[weak self] in self?.animationView.play()  }
            .store(in: &anyCancelables)
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        let input = AnniversaryViewModel
            .Input(refreshTrigger: refreshUserTrigger.eraseToAnyPublisher(),
                   refreshTimeTrigger: refreshTimeTrigger.eraseToAnyPublisher(),
                   userInfoTrigger: loveInforView.tapToEdit,
                   toSelectBackgroundTrigger: moreOptionBarButton.tapPublisher.eraseToVoidAnyPublisher(),
                   showSelectDate: showDateSelect.eraseToVoidAnyPublisher()
            )
        let output = viewModel.transform(input)
        output.userInfo.sink {[weak self] userInfors in
            userInfors.forEach {  self?.loveInforView.setData(userInfo: $0) }
        }.store(in: &anyCancelables)
        
        output.timeInfo.sink {[weak self] date in
            self?.dateTimeView.setData(from: date)
        }.store(in: &anyCancelables)
        
        ProfileImageManager.didChange.sink {[weak self] type in
            self?.loveInforView.setImage(type: type)
        }.store(in: &anyCancelables)
        
        ProfileImageManager.didChange.send(.me)
        ProfileImageManager.didChange.send(.partner)
        
        output.actionVoid.sink {}.store(in: &anyCancelables)
        
        output.background.sink {[weak self] backgroundModel in
            self?.backgroundImage.image = backgroundModel.getImage()?.resize(size: UIScreen.main.bounds.size)
        }.store(in: &anyCancelables)
        showDateSelect.send()
    }
    
    private func requestReviewIfNeeded() {
        if !PascodeManager.shared.isLocked {
            ReviewHelper.checkAndRequestReview()
        }
    }
}

extension AnniversaryViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        refreshTimeTrigger.send()
    }
}

extension UIViewController {
    func shareImage(from view: UIView) -> AnyPublisher<Void, Never> {
        return Just(view.getScreenShot())
            .compactMap { $0 }
            .flatMap { image -> AnyPublisher<Void, Never> in
                let shareText = LocalizedString.shareAppName + "\n"
                let shareItems = [shareText, image] as [Any]
                return self.share(activityItems: shareItems).eraseToVoidAnyPublisher()
            }.eraseToAnyPublisher()
    }
    
    func share(activityItems: [Any]) -> AnyPublisher<Bool, Never> {
        return Deferred {
            Future { promise in
                let activityViewController = CustomActivityViewController(self, activityItems: activityItems, applicationActivities: nil)
                activityViewController.customCompletionHandler = {
                    promise(.success($0))
                }
                activityViewController.show()
            }
        }.eraseToAnyPublisher()
    }
}
