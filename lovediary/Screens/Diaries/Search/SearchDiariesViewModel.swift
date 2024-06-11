//
//  SearchDiariesViewModel.swift
//  lovediary
//
//  Created by vu dao on 28/03/2021.
//

import Combine
import Foundation

extension SearchDiariesViewModel.CellModel: Hashable {
    static func  == (lhs: SearchDiariesViewModel.CellModel, rhs: SearchDiariesViewModel.CellModel) -> Bool {
        return lhs.item.id == rhs.item.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(item.id)
    }
}

class SearchDiariesViewModel: ViewModelType {
    
    struct CellModel {
        var item: DiaryModel
        var keys: [String]
    }

    
    private var dependency: Dependency
    private var navigator: SearchDiariesNavigatorType
    
    init(dependency: Dependency, navigator: SearchDiariesNavigatorType) {
        self.dependency = dependency
        self.navigator = navigator
    }
    
    struct Dependency {
        var repo: DiaryManagerType
    }
    
    struct Input {
        var searchTrigger: AnyPublisher<String, Never>
        var didSelectCell: AnyPublisher<DiaryModel, Never>
        var shouldReload: AnyPublisher<String, Never>
    }
    struct Output {
        var searchResult: AnyPublisher<[CellModel], Never>
        var itemCount: AnyPublisher<Int, Never>
        var noResult: AnyPublisher<Bool, Never>
        var actionVoid: AnyPublisher<Void, Never>
    }
    
    func transform(_ input: Input) -> Output {
        
        let searchkeyTrigger = input.searchTrigger
            .removeDuplicates()
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
        
        let searchReload = input.shouldReload
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
        
        let searchResult = Publishers.Merge(searchkeyTrigger, searchReload)
            .map { return StringHelper.getKeyWords(key: $0) }
            .receive(on: DispatchQueue.global(qos: .background))
            .flatMap {[weak self] keys -> AnyPublisher<[CellModel], Never> in
                guard let self = self else { return .empty() }
                return self.dependency.repo.getSearchResult(searchStrings: keys)
                    .map { diaries -> [CellModel] in
                        return diaries.map { CellModel(item: $0, keys: keys) }
                    }.eraseToAnyPublisher()
            }.receive(on: DispatchQueue.main)
            .share()
        
        let selectDiaryModel = input.didSelectCell
            
            .receiveOutput {[weak self] diaryModel in
            self?.navigator.toDiaryDetail(diaryModel: diaryModel, createDate: nil)
        }.eraseToVoidAnyPublisher()
        
        let itemCount = searchResult.map { cellModel -> Int in
            return cellModel.count
        }.eraseToAnyPublisher()
        
        let noResult = searchResult.map { value in
            return value.isEmpty
        }.eraseToAnyPublisher()
        
        return .init(searchResult: searchResult.eraseToAnyPublisher(),
                     itemCount: itemCount,
                     noResult: noResult,
                     actionVoid: selectDiaryModel)
    }
}
