//
//  DiariesNavigator.swift
//  lovediary
//
//  Created by daovu on 17/03/2021.
//

import UIKit

protocol DiariesNavigatorType {
    func toDiaryDetail(diaryModel: DiaryModel?, createDate: Date?)
    func toSearchDiary()
}

class DiariesNavigator: DiariesNavigatorType {
    
    private weak var viewController: UIViewController?
    private var dependency: DiariesDependency
    
    init(dependency: DiariesDependency) {
        self.dependency = dependency
    }
    
    func start(with viewController: UIViewController?) {
        self.viewController = viewController
    }
    
    func toDiaryDetail(diaryModel: DiaryModel? = nil, createDate: Date?) {
        let diaryDetailViewController = DiaryDetailViewController.instantiate {[weak self] in
            guard let self = self else { return nil }
            let dependency = self.dependency.getDiaryDetailDependency()
            let navigator = DiaryDetailNavigator()
            let viewModel = DiaryDetailViewModel(dependency: dependency,
                                                 navigator: navigator,
                                                 diaryModel: diaryModel,
                                                 createDate: createDate)
            let diaryDetailViewController = DiaryDetailViewController(coder: $0, viewModel: viewModel)
            navigator.start(with: diaryDetailViewController)
            return diaryDetailViewController
        }
        
        viewController?.navigationController?.pushAndHideTabbar(diaryDetailViewController)
    }
    
    func toSearchDiary() {
        let searchDiaryVC = SearchDiariesViewController.instantiate { [weak self] in
            guard let self = self else { return nil }
            let dependency = self.dependency.getSearchDiaryDependency()
            let navigator = SearchDiariesNavigator(dependency: self.dependency)
            let viewModel = SearchDiariesViewModel(dependency: dependency,
                                                   navigator: navigator)
            let viewController = SearchDiariesViewController(coder: $0, viewModel: viewModel)
            navigator.start(with: viewController)
            return viewController
        }
        
        viewController?.navigationController?.pushAndHideTabbar(searchDiaryVC)
    }
    
}
