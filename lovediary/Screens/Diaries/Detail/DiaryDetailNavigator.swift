//
//  DiaryDetailNavigator.swift
//  lovediary
//
//  Created by daovu on 26/03/2021.
//

import UIKit
import Combine

protocol DiaryDetailNavigatorType: NavigatorType {
    func pop()
    func sharePDF(url: URL) -> AnyPublisher<Bool, Never>
    func shareImage(from view: AttachmentTextView) -> AnyPublisher<Void, Never>
    func toImagePreview(images: [UIImage], selectedIndex: Int)
}

class DiaryDetailNavigator: DiaryDetailNavigatorType {
    
    weak var viewController: UIViewController?
    
    func start(with viewController: UIViewController?) {
        self.viewController = viewController
    }
    
    func toImagePreview(images: [UIImage], selectedIndex: Int) {
        let imageViewController = ImagePreviewViewController.instantiate {
            return ImagePreviewViewController(coder: $0, images: images, selectedIndex: selectedIndex)
        }
        let navViewController = BaseNavigationController(rootViewController: imageViewController)
        navViewController.modalPresentationStyle = .fullScreen
        viewController?.present(navViewController, animated: true, completion: nil)
    }
    
    func pop() {
        DispatchQueue.main.async {[weak self] in
            if self?.viewController?.isModal == true {
                self?.viewController?.dismiss(animated: true, completion: nil)
                return
            }
            self?.viewController?.navigationController?.popViewController(animated: true)
        }
    }
    
    func sharePDF(url: URL) -> AnyPublisher<Bool, Never> {
        guard let viewController = viewController else { return .empty() }
        return viewController.share(activityItems: [url])
    }
    
    func shareImage(from view: AttachmentTextView) -> AnyPublisher<Void, Never> {
        guard let viewController = viewController else { return .empty() }
        return getScreenShot(from: viewController, with: view)
    }
    
    private func getScreenShot(from viewController: UIViewController,
                               with view: AttachmentTextView) -> AnyPublisher<Void, Never> {
        ProgressHelper.shared.show()
        return Just(view.getTextViewScreenShot())
            .compactMap { $0 }
            .flatMap { image -> AnyPublisher<Void, Never> in
                let shareText = LocalizedString.shareAppName + "\n"
                let shareItems = [shareText, image] as [Any]
                ProgressHelper.shared.hide()
                return viewController.share(activityItems: shareItems).eraseToVoidAnyPublisher()
            }.eraseToAnyPublisher()
    }
}
