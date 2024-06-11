//
//  SearchDiariesNavigator.swift
//  lovediary
//
//  Created by vu dao on 28/03/2021.
//

import UIKit

protocol SearchDiariesNavigatorType {
    func toDiaryDetail(diaryModel: DiaryModel?, createDate: Date?)
}

class SearchDiariesNavigator: SearchDiariesNavigatorType {
    
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
                                                 createDate: createDate,
                                                 viewMode: .edit)
            let diaryDetailViewController = DiaryDetailViewController(coder: $0, viewModel: viewModel)
            navigator.start(with: diaryDetailViewController)
            return diaryDetailViewController
        }
        
        viewController?.navigationController?.pushAndHideTabbar(diaryDetailViewController)
    }
    
}

