//
//  PhotosNavigator.swift
//  lovediary
//
//  Created by vu dao on 22/03/2021.
//

import UIKit

protocol PhotosNavigatorType: NavigatorType {
    func toImagePreview(images: [ImageAttachment], selectedIndex: Int, showDiaryTrigger: ((String) -> Void)?)
    func toDiaryDetail(diaryModel: DiaryModel?, createDate: Date?)
    func createNewDiary()
}

class PhotosNavigator: PhotosNavigatorType {
  
    weak var viewController: UIViewController?
    private var dependency: DiariesDependency
    
    init(dependency: DiariesDependency) {
        self.dependency = dependency
    }
    
    func start(with viewController: UIViewController?) {
        self.viewController = viewController
    }
    
    func toImagePreview(images: [ImageAttachment], selectedIndex: Int, showDiaryTrigger: ((String) -> Void)?) {
        let imageViewController = ImagePreviewViewController.instantiate {
            return ImagePreviewViewController(coder: $0, imageAttachments: images, selectedIndex: selectedIndex)
        }
        imageViewController.showDiaryTrigger = showDiaryTrigger
        let navViewController = BaseNavigationController(rootViewController: imageViewController)
        navViewController.modalPresentationStyle = .fullScreen
        viewController?.present(navViewController, animated: true, completion: nil)
    }
    
    func toDiaryDetail(diaryModel: DiaryModel? = nil, createDate: Date?) {
        let navController = BaseNavigationController(rootViewController: getDiaryDetailVc(diaryModel: diaryModel, createDate: createDate, viewMode: .preview))
        navController.modalPresentationStyle = .fullScreen
        UIApplication.topViewController()?.present(navController, animated: true, completion: nil)
    }
    
    func createNewDiary() {
        let diaryVC = getDiaryDetailVc(viewMode: .edit)
        viewController?.navigationController?.pushAndHideTabbar(diaryVC)
    }
    
    private func getDiaryDetailVc(diaryModel: DiaryModel? = nil, createDate: Date? = Date(), viewMode: DiaryViewMode) -> DiaryDetailViewController {
        return DiaryDetailViewController.instantiate {[weak self] in
            guard let self = self else { return nil }
            let dependency = self.dependency.getDiaryDetailDependency()
            let navigator = DiaryDetailNavigator()
            let viewModel = DiaryDetailViewModel(dependency: dependency, navigator: navigator,
                                                 diaryModel: diaryModel,
                                                 createDate: createDate, viewMode: viewMode)
            let diaryDetailVC = DiaryDetailViewController(coder: $0, viewModel: viewModel)
            navigator.start(with: diaryDetailVC)
            return diaryDetailVC
        }
    }
    
}
