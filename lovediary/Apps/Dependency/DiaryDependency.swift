//
//  DiaryDependency.swift
//  lovediary
//
//  Created by daovu on 17/03/2021.
//

import Foundation

class DiariesDependency {
    private let appDependency: ApplicationDependency
    
    private lazy var imageDao = ImageAttachmentDao()
    private lazy var diaryDao = DiaryDao()
    private lazy var repository = DiaryRepository(diaryDao: diaryDao, imageDao: imageDao)
    private lazy var imageManager = ImageManager()
    lazy var diaryManager: DiaryManagerType = DiaryManager(repository: repository, imageManager: imageManager)

    init(appDependency: ApplicationDependency) {
        self.appDependency = appDependency
    }

    func getDiaryDependency() -> DiariesViewModel.Dependency {
        return .init(repo: diaryManager)
    }

    func getDiaryDetailDependency() -> DiaryDetailViewModel.Dependency {
        return .init(manager: diaryManager)
    }
    
    func getSearchDiaryDependency() -> SearchDiariesViewModel.Dependency {
        return .init(repo: diaryManager)
    }

    func getGaleryDependency() -> GaleriesViewModel.Dependency {
        return .init(manager: diaryManager)
    }
}
