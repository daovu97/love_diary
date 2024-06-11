//
//  DiaryDetailViewModel.swift
//  lovediary
//
//  Created by daovu on 17/03/2021.
//

import Foundation
import UIKit
import Combine

enum DiaryViewMode {
    case edit
    case preview
}

enum DiaryDetailOptionAction {
    case shareImage
    case sharePDF
    case delete
}

class DiaryDetailViewModel: ViewModelType {
    
    private let dependency: Dependency
    private var diaryModel: DiaryModel?
    private var lastAttributeString: NSAttributedString?
    private var createDate: Date?
    var viewMode: DiaryViewMode
    private var navigator: DiaryDetailNavigatorType
    private var isSaving = false
    
    var isDraggingTextView = false
    
    var didChangeTextView = false
    
    init(dependency: Dependency,
         navigator: DiaryDetailNavigatorType,
         diaryModel: DiaryModel? = nil,
         createDate: Date?,
         viewMode: DiaryViewMode = .edit) {
        self.dependency = dependency
        self.navigator = navigator
        self.diaryModel = diaryModel
        self.lastAttributeString = diaryModel?.getContent()
        self.createDate = createDate
        self.viewMode = viewMode
    }
    
    struct Dependency {
        let manager: DiaryManagerType
    }
    
    struct Input {
        var saveTrigger: AnyPublisher<NSAttributedString, Never>
        var optionActionTrigger: AnyPublisher<(DiaryDetailOptionAction, AttachmentTextView), Never>
        var dateChangeTrigger: AnyPublisher<Date, Never>
        var contentAttributedString: AnyPublisher<NSAttributedString, Never>
        var showImagePreview: AnyPublisher<([UIImage], Int), Never>
    }
    
    struct Output {
        var textCount: AnyPublisher<Int, Never>
        var text: AnyPublisher<NSAttributedString, Never>
        var actionVoid: AnyPublisher<Void, Never>
        var shouldEdit: AnyPublisher<Void, Never>
        var date: AnyPublisher<Date, Never>
        var viewMode: AnyPublisher<DiaryViewMode, Never>
    }
    
    func transform(_ input: Input) -> Output {
    
        let save = input.saveTrigger
            .flatMap {[weak self] newAttribute  -> AnyPublisher<Void, Never> in
                guard let self = self, newAttribute.length != 0, !self.isSaving,
                      newAttribute != self.lastAttributeString else { return .empty() }
                self.isSaving = true
                if let diaryModel = self.diaryModel, let lastAttributeString = self.lastAttributeString {
                    return self.updateDiaryAction(diaryModel: diaryModel,
                                                  lastAttributeString: lastAttributeString,
                                                  newAttribute: newAttribute)
                } else {
                    return self.createDiaryAction(newAttribute: newAttribute)
                }
            }.eraseToVoidAnyPublisher()
        
        let optionPublisher = input.optionActionTrigger.share()
        
        let shareImageAction = optionPublisher.filter { $0.0 == .shareImage }
            .flatMap {[weak self] _, textView -> AnyPublisher<Void, Never> in
                guard let self = self else { return .empty()}
                return self.navigator.shareImage(from: textView)
            }.eraseToVoidAnyPublisher()
        
        let sharePdfAction = optionPublisher.filter { $0.0 == .sharePDF }
            .flatMap {[weak self] _, textView -> AnyPublisher<Void, Never> in
                guard let self = self else { return .empty()}
                return self.sharePDFAction(from: textView.attributedText)
            }.eraseToVoidAnyPublisher()
        
        let deleteAction = optionPublisher.filter { $0.0 == .delete }
            .flatMap {[weak self] _ -> AnyPublisher<Void, Never> in
                guard let self = self, let diaryModel = self.diaryModel else { return .empty() }
                return self.deleteAction(diaryModel: diaryModel)
            }
        
        let textcount = Publishers.Merge(Just(lastAttributeString?.length ?? 0),
                                         input.contentAttributedString.map { $0.length }).eraseToAnyPublisher()
        
        let dateTrigger = input.dateChangeTrigger
            .flatMap {[weak self] date -> AnyPublisher<DiaryModel, Never> in
                guard let self = self else { return .empty() }
                self.createDate = date
                return self.dependency.manager.updateDiaryDate(at: self.diaryModel, date: date)
                    .receiveOutput { diaryModel in
                        self.diaryModel = diaryModel
                    }
            }.eraseToVoidAnyPublisher()
        
        let diaryDate = Just((diaryModel?.displayDate ?? createDate) ?? Date())
        let dateValue = Publishers.Merge(input.dateChangeTrigger, diaryDate).eraseToAnyPublisher()
        
        let openImagePreview = input.showImagePreview.receiveOutput {[weak self] allImage, selectedIndex in
            self?.navigator.toImagePreview(images: allImage, selectedIndex: selectedIndex)
        }.eraseToVoidAnyPublisher()
        
        return Output(textCount: textcount,
                      text: Just(lastAttributeString)
                        .compactMap { $0 }.eraseToAnyPublisher(),
                      actionVoid: Publishers.Merge6(save, shareImageAction,
                                                    sharePdfAction,
                                                    deleteAction, dateTrigger,
                                                    openImagePreview).eraseToVoidAnyPublisher(),
                      shouldEdit: Just(diaryModel).filter { $0 == nil }.eraseToVoidAnyPublisher(),
                      date: dateValue,
                      viewMode: .just(viewMode))
    }
    
    private func updateDiaryAction(diaryModel: DiaryModel, lastAttributeString: NSAttributedString, newAttribute: NSAttributedString) -> AnyPublisher<Void, Never> {
        return self.dependency.manager.updateDiary(oldDiary: diaryModel,
                                                   oldAttribute: lastAttributeString,
                                                   newAtrribute: newAttribute,
                                                   at: (self.diaryModel?.displayDate ?? self.createDate) ?? Date())
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: {[weak self] diaryModel in
                self?.isSaving = false
                ProgressHelper.shared.hide()
                self?.lastAttributeString = newAttribute
                self?.diaryModel = diaryModel
            }).eraseToVoidAnyPublisher()
    }
    
    private func createDiaryAction(newAttribute: NSAttributedString) -> AnyPublisher<Void, Never> {
        return self.dependency.manager.createNewDiary(newAttribute: newAttribute,
                                                      at: self.createDate ?? Date())
            .receive(on: DispatchQueue.main)
            .handleEvents (receiveOutput: { [weak self] diaryModel in
                self?.isSaving = false
                ProgressHelper.shared.hide()
                self?.diaryModel = diaryModel
                self?.lastAttributeString = newAttribute
            }).eraseToVoidAnyPublisher()
    }
    
    private func deleteAction(diaryModel: DiaryModel) -> AnyPublisher<Void, Never> {
        return AlertManager.shared.showConfirmMessage(message: LocalizedString.deleteDiaryConfirm,
                                                      confirm: LocalizedString.delete, cancel: LocalizedString.cancel,
                                                      isDelete: true)
            .flatMap {[weak self] select -> AnyPublisher<Void, Never>  in
                guard let self = self, select == .confirm else { return .empty() }
                return self.dependency.manager.deleteDiary(diaryModel: diaryModel)
            }.receive(on: DispatchQueue.main)
            .receiveOutput {[weak self] _  in
                NotificationCenter.default.post(name: .didDeleteDiaryNotification, object: nil, userInfo: [Notification.Name.didDeleteDiaryNotification: diaryModel.id])
                self?.navigator.pop()
            }.eraseToVoidAnyPublisher()
        
    }
    
    private func sharePDFAction(from attributedText: NSAttributedString) -> AnyPublisher<Void, Never> {
        ProgressHelper.shared.show()
        return Just(())
            .receive(on: DispatchQueue.main)
            .flatMap { _ -> AnyPublisher<URL?, Never> in
                let url = PDFHelper.anotherExportPdf(from: attributedText.fitImageToWindow(with: PDFHelper.printableRect.width))
                ProgressHelper.shared.hide()
                return .just(url)
            }.compactMap { $0 }
            .flatMap {[weak self] url -> AnyPublisher<Bool, Never> in
                guard let self = self else { return .empty()}
                return self.navigator.sharePDF(url: url)
            }.receiveOutput(outPut: { complete in
                if complete { FileManager.default.clearTempDirectory() }
            })
            .eraseToVoidAnyPublisher()
    }
}
