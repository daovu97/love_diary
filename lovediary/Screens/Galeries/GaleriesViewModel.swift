//
//  GaleriesViewModel.swift
//  lovediary
//
//  Created by vu dao on 21/03/2021.
//

import Foundation
import Combine

class GaleriesViewModel: ViewModelType {
    
    private var dependency: Dependency
    private let navigator: PhotosNavigatorType
    
    init(dependency: Dependency, navigator: PhotosNavigatorType) {
        self.dependency = dependency
        self.navigator = navigator
    }
    
    struct Dependency {
        var manager: DiaryManagerType
    }
    struct Input {
        var loadImage: AnyPublisher<Bool, Never>
        var didSelectRowAt: AnyPublisher<(images: [ImageAttachment], selected: Int), Never>
        var toCreateNewDiary: AnyPublisher<Void, Never>
    }
    struct Output {
        var images: AnyPublisher<[ImageAttachment], Never>
        var actionVoid: AnyPublisher<Void, Never>
    }
    
    func transform(_ input: Input) -> Output {
        
        let showDiaryPublisher = PassthroughSubject<String, Never>()
        
        let image = input.loadImage.flatMap {[weak self] isReverseChange -> AnyPublisher<[ImageAttachment], Never> in
            guard let self = self else { return .empty() }
            if isReverseChange {
                Settings.isReversePhoto.value = !Settings.isReversePhoto.value
            }
            return self.dependency.manager.getAllImage(reverse: Settings.isReversePhoto.value)
        }
        
        let selectRowAt = input.didSelectRowAt.receiveOutput {[weak self] images, selected in
            guard let self = self else { return }
            self.navigator.toImagePreview(images: images, selectedIndex: selected, showDiaryTrigger: { showDiaryPublisher.send($0) })
        }.eraseToVoidAnyPublisher()
        
        let toDiaryDetail = showDiaryPublisher.flatMap {[weak self] diaryId -> AnyPublisher<DiaryModel?, Never> in
            guard let self = self else { return .empty() }
            return self.dependency.manager.getDiary(by: diaryId)
        }.compactMap { $0 }
        .receiveOutput {[weak self] diary in
            self?.navigator.toDiaryDetail(diaryModel: diary, createDate: nil)
        }.eraseToVoidAnyPublisher()
        
        let toCreateNewDiary = input.toCreateNewDiary.receiveOutput {[weak self] _ in
            self?.navigator.createNewDiary()
        }.eraseToVoidAnyPublisher()
        
        return Output(images: image.eraseToAnyPublisher(),
                      actionVoid: Publishers.Merge3(toDiaryDetail,
                                                    selectRowAt,
                                                    toCreateNewDiary).eraseToVoidAnyPublisher())
    }
}
