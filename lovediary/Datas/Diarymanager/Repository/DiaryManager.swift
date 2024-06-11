//
//  DiaryManager.swift
//  DiaryManager
//
//  Created by daovu on 19/03/2021.
//

import Combine
import UIKit

protocol DiaryManagerType {
    
    func updateDiary(oldDiary: DiaryModel, oldAttribute: NSAttributedString, newAtrribute: NSAttributedString, at date: Date) -> AnyPublisher<DiaryModel, Never>
    
    func createNewDiary(newAttribute: NSAttributedString, at date: Date) -> AnyPublisher<DiaryModel, Never>
    
    func deleteDiary(diaryModel: DiaryModel) -> AnyPublisher<Void, Never>
    func deleteAllDiary() -> AnyPublisher<Void, Error>
    func getAllDiary(startDate: Date, toDate: Date) -> AnyPublisher<[DiaryModel], Never>
    func getAllDiary() -> AnyPublisher<[DiaryModel], Error>
    func getAllImage(reverse: Bool) -> AnyPublisher<[ImageAttachment], Never>
    func getDiary(by id: String) -> AnyPublisher<DiaryModel?, Never>
    
    func saveMany(diaryModels : [DiaryModel]) -> AnyPublisher<Void, Error>
   
    func getSearchResult(searchStrings: [String]) -> AnyPublisher<[DiaryModel], Never>
    
    func updateDiaryDate(at diaryModel: DiaryModel?, date: Date) -> AnyPublisher<DiaryModel, Never>
    
    func getDiaryByDateCalendar(from startDate: Date, to endDate: Date) -> AnyPublisher<Set<Date>, Never>
    
    func getEventDateNext(from date: Date) -> AnyPublisher<Date, Never>
    func getEventDatePrevious(from date: Date) -> AnyPublisher<Date, Never>
}

class DiaryManager: DiaryManagerType {
    func saveMany(diaryModels: [DiaryModel]) -> AnyPublisher<Void, Error> {
        return repository.addNewDiary(diaries: diaryModels).eraseToAnyPublisher()
    }
    
    func deleteAllDiary() -> AnyPublisher<Void, Error> {
        let deleteAllImage = imageManager.deleteAll()
        let deleteDiary = repository.deleteAll()
        return Publishers.CombineLatest(deleteDiary, deleteAllImage).map{_ in return () }.eraseToAnyPublisher()
    }
    
    func getAllDiary() -> AnyPublisher<[DiaryModel], Error> {
        return repository.getAllDiary()
    }
    
    func getEventDateNext(from date: Date) -> AnyPublisher<Date, Never> {
        let fillter = NSPredicate(format: "\(DiaryEntityField.displayDate.rawValue) > %@", argumentArray: [date.endOfDay])
        let sort = NSSortDescriptor(key: DiaryEntityField.displayDate.rawValue, ascending: true)
        return repository.getAllDiaryDate(with: [fillter], sortDescriptors: [sort]).map { dates -> Date in
            return dates.first ?? date.tomorrow
        }.eraseToAnyPublisher()
    }
    
    func getEventDatePrevious(from date: Date) -> AnyPublisher<Date, Never> {
        let fillter = NSPredicate(format: "\(DiaryEntityField.displayDate.rawValue) < %@", argumentArray: [date.startOfDay])
        let sort = NSSortDescriptor(key: DiaryEntityField.displayDate.rawValue, ascending: true)
        return repository.getAllDiaryDate(with: [fillter], sortDescriptors: [sort]).map { dates -> Date in
            return dates.last ?? date.yesterday
        }.eraseToAnyPublisher()
    }
    
    
    func getDiaryByDateCalendar(from startDate: Date, to endDate: Date) -> AnyPublisher<Set<Date>, Never> {
        let fillter = NSPredicate(format: "\(DiaryEntityField.displayDate.rawValue) >= %@ && \(DiaryEntityField.displayDate.rawValue) <= %@"  ,
                                  argumentArray: [startDate, endDate])
        return repository.getAllDiaryDate(with: [fillter], sortDescriptors: []).map { dates -> Set<Date> in
            var result = Set<Date>()
            dates.forEach { result.insert($0.midnight) }
            return result
        }.eraseToAnyPublisher()
    }
    
   
    private let repository: DiaryRepositoryType
    private let imageManager: ImageManagerType
    
    init(repository: DiaryRepositoryType,  imageManager: ImageManagerType) {
        self.repository = repository
        self.imageManager = imageManager
    }
    
    struct UpdateImage {
        var image: UIImage
        var range: NSRange
        var nameUrl: String?
        var id: String?
        var createDate: Date?
    }
    
    private func image(from diary: DiaryModel, attribute: NSAttributedString) -> [UpdateImage] {
        var oldImage = [UpdateImage]()
        let oldAtributeData = attribute.replaceImageWithWhitespace()
        
        for (index, info) in oldAtributeData.imageInfos.enumerated() {
            if index < diary.attachments.count {
                oldImage.append(UpdateImage(image: info.image,
                                            range: info.range,
                                            nameUrl: diary.attachments[index].nameUrl,
                                            id: diary.attachments[index].id,
                                            createDate: diary.attachments[index].createDate))
            }
        }
        
        return oldImage
    }
    
    private func image(from attribute: NSAttributedString) -> (NSAttributedString, [UpdateImage]) {
        let newAtributeData = attribute.replaceImageWithWhitespace()
        
        var newImage = [UpdateImage]()
        
        for info in newAtributeData.imageInfos {
            newImage.append(UpdateImage(image: info.image,
                                        range: info.range,
                                        nameUrl: nil))
        }
        
        return (newAtributeData.0, newImage)
    }
    
    private func handleImage(from oldDiary: DiaryModel,
                             oldAttribute: NSAttributedString,
                             newAttribute: NSAttributedString) -> AnyPublisher<(NSAttributedString, [ImageAttachment]), Never> {
        let oldImage = image(from: oldDiary, attribute: oldAttribute)
        let newImageData = image(from: newAttribute)
        
        var notChangeImages = [UpdateImage]()
        
        newImageData.1.forEach { infor in
            if var attachImage = oldImage.first(where: { $0.image == infor.image }) {
                attachImage.range = infor.range
                notChangeImages.append(attachImage)
            }
        }
        
        var removeItem = [UpdateImage]()
        var newItemInfo = [UpdateImage]()
        
        let different = newImageData.1.difference(from: oldImage) { $0.image == $1.image }
        
        different.forEach { change in
            switch change {
            case .insert(_, let newItem, _):
                newItemInfo.append(newItem)
            case .remove(_, let deleteItem, _):
                removeItem.append(deleteItem)
            }
        }
        
        let deleteImage = self.imageManager.deleteImage(by: removeItem.compactMap { $0.nameUrl })
        let addNewImage = self.imageManager.saveImage(images: newItemInfo.map { return ($0.range, $0.image) })
        let deleteImageDB = self.repository.deleteImage(ids: removeItem.compactMap { $0.id })
        
        return Publishers.CombineLatest3(deleteImage, addNewImage, deleteImageDB)
            .flatMap { _, newImages, _ -> AnyPublisher<(NSAttributedString, [ImageAttachment]), Never> in
                
                var result = notChangeImages.map { updateImage -> ImageAttachment? in
                    if let id = updateImage.id, let nameUrl = updateImage.nameUrl {
                        return ImageAttachment(id: id, nameUrl: nameUrl,
                                               position: updateImage.range.location,
                                               length: updateImage.range.length,
                                               width: Int(updateImage.image.size.width),
                                               height: Int(updateImage.image.size.width),
                                               diaryId: "",
                                               createDate: updateImage.createDate ?? Date())
                    }
                    return nil
                }.compactMap { $0 }
                
                result.append(contentsOf: newImages)
                for index in result.indices {
                    result[index].diaryId = oldDiary.id
                }
                return .just((newImageData.0, result))
            }.eraseToAnyPublisher()
    }
    
    private func handleUpdate(from oldDiary: DiaryModel,
                              oldAttribute: NSAttributedString,
                              newAttribute: NSAttributedString, date: Date) -> AnyPublisher<DiaryModel, Never> {
        guard oldAttribute != newAttribute else { return .just(oldDiary) }
        return self.handleImage(from: oldDiary, oldAttribute: oldAttribute, newAttribute: newAttribute)
            .flatMap { newAtrribute, newImages -> AnyPublisher<DiaryModel, Never> in
                var tempDiary = oldDiary
                tempDiary.attachments = newImages
                tempDiary.text = newAtrribute.string
                tempDiary.updatedDate = date
                tempDiary.displayDate = date
                return .just(tempDiary)
            }.eraseToAnyPublisher()
    }
    
    func updateDiary(oldDiary: DiaryModel, oldAttribute: NSAttributedString, newAtrribute: NSAttributedString, at date: Date) -> AnyPublisher<DiaryModel, Never> {
        return Just(())
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .flatMap { [weak self] _ -> AnyPublisher<DiaryModel, Never> in
                guard let self = self else { return .empty() }
                return self.handleUpdate(from: oldDiary,
                                         oldAttribute: oldAttribute,
                                         newAttribute: newAtrribute, date: date)
            }
            .flatMap({[weak self] diaryModel -> AnyPublisher<DiaryModel, Never> in
                guard let self = self else { return .empty() }
                return self.repository.addNewDiary(diary: diaryModel)
                    .receiveOutput(outPut: {[weak self] diaryModel in
                    self?.sendReloadAtDate(date: diaryModel.displayDate)
                })
            })
            .eraseToAnyPublisher()
    }
    
    func sendReloadAtDate(date: Date) {
        NotificationCenter.default.post(name: .shouldReloadDiaryNotification, object: nil, userInfo: [Notification.Name.shouldReloadDiaryNotification: date])
    }
    
    func createNewDiary(newAttribute: NSAttributedString, at date: Date) -> AnyPublisher<DiaryModel, Never> {
        let result: (newAttributedString: NSAttributedString, imageInfos: [(range: NSRange, image: UIImage)]) = newAttribute.replaceImageWithWhitespace()
        
        return Just(result.imageInfos)
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .flatMap { [weak self] imageInfos -> AnyPublisher<[ImageAttachment], Never> in
                if imageInfos.isEmpty { return .just([]) }
                guard let self = self else {  return .empty() }
                return self.imageManager.saveImage(images: imageInfos)
            }
            .map { attachments -> DiaryModel in
                var newDiary = DiaryModel()
                var tempAttachments = attachments
                for index in tempAttachments.indices { tempAttachments[index].diaryId = newDiary.id }
                newDiary.text = result.newAttributedString.string
                newDiary.attachments = tempAttachments
                newDiary.displayDate = date
                newDiary.updatedDate = Date()
                return newDiary
            }
            .flatMap({[weak self] diaryModel -> AnyPublisher<DiaryModel, Never> in
                guard let self = self else { return .empty() }
                return self.repository.addNewDiary(diary: diaryModel)
                    .receiveOutput(outPut: {[weak self] diaryModel in
                        self?.sendReloadAtDate(date: diaryModel.displayDate)
                    })
            })
           
            .eraseToAnyPublisher()
    }
    
    
    func deleteDiary(diaryModel: DiaryModel) -> AnyPublisher<Void, Never> {
        let deleteImage = imageManager.deleteImage(by: diaryModel.attachments.map { $0.nameUrl })
        let deleteDiary = repository.deleteDiary(diary: diaryModel)
        return Publishers.CombineLatest(deleteDiary, deleteImage)
            .receiveOutput(outPut: {[weak self] _ in
                self?.sendReloadAtDate(date: diaryModel.displayDate)
            })
            .eraseToVoidAnyPublisher()
    }
    
    func getAllDiary(startDate: Date, toDate: Date) -> AnyPublisher<[DiaryModel], Never> {
        return repository.getDiary(from: startDate, to: toDate)
    }
    
    func getDiary(by id: String) -> AnyPublisher<DiaryModel?, Never> {
        return repository.getDiary(by: id)
    }
    
    func getAllImage(reverse: Bool) -> AnyPublisher<[ImageAttachment], Never> {
        return self.repository.getAllImage(reverse: reverse)
    }
    
    
    func getSearchResult(searchStrings: [String]) -> AnyPublisher<[DiaryModel], Never> {
        let sortDescriptor = NSSortDescriptor(key: DiaryEntityField.displayDate.rawValue, ascending: false)
        
        return self.repository.getDiaries(with: [], sortDescriptors: [sortDescriptor])
            .map { [weak self] notes in
                guard let self = self else { return [] }
                return self.searchBy(keys: searchStrings, in: notes)
            }.eraseToAnyPublisher()
    }
    
    private func searchBy(keys: [String], in diaries: [DiaryModel]) -> [DiaryModel] {
        if keys.isEmpty {
            return []
        }
        let lowerKeys = keys.map({$0.lowercased()})
        return diaries.filter { diary in
            let diaryContent = diary.text.lowercased()
            return lowerKeys.allSatisfy { diaryContent.contains($0) }
        }
    }
    
    func updateDiaryDate(at diaryModel: DiaryModel?, date: Date) -> AnyPublisher<DiaryModel, Never> {
        guard var diaryModelTemp = diaryModel else { return .empty() }
        diaryModelTemp.displayDate = date
        diaryModelTemp.updatedDate = Date()
        return repository.updateDate(diary: diaryModelTemp).receiveOutput(outPut: {[weak self] _ in
            self?.sendReloadAtDate(date: diaryModel!.displayDate)
        })
    }
}
