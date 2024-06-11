//
//  SearchDiariesViewController.swift
//  lovediary
//
//  Created by vu dao on 28/03/2021.
//

import UIKit
import Combine

class SearchDiariesViewController: BaseViewController<SearchDiariesViewModel>, DeleteDiaryNotification {
    @IBOutlet weak var resultTableView: UITableView!
    
    typealias DataSource = UITableViewDiffableDataSource<Int, SearchDiariesViewModel.CellModel>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, SearchDiariesViewModel.CellModel>
    
    private lazy var shouldReloadData = PassthroughSubject<String, Never>()
    
    private lazy var dataSource = DataSource(tableView: self.resultTableView) { (tableView, indexPath, cellModel) -> UITableViewCell? in
        let cell = tableView.dequeueReusableCell(SearchDiaryTableViewCell.self, for: indexPath)
        cell.bind(model: cellModel.item)
        cell.highlight(texts: cellModel.keys, color: Colors.toneColor)
        return cell
    }
    
   private lazy var noResultLabel: UILabel = {
        let label = IncreaseHeightLabel(frame: CGRect(x: 0, y: 0, width: UIApplication.windowBound.width, height: 0))
        label.textAlignment = .center
        label.text = LocalizedString.searchNoItemFound
        label.font = Fonts.getHiraginoSansFont(fontSize: 16, fontWeight: .bold)
        return label
    }()
    
    private lazy var itemCountLabel: IncreaseHeightLabel = {
         let label = IncreaseHeightLabel(frame: CGRect(x: 0, y: 0, width: UIApplication.windowBound.width, height: 50))
         label.textAlignment = .center
         label.textColor = .lightGray
         label.font = Fonts.getHiraginoSansFont(fontSize: 14, fontWeight: .regular)
         return label
     }()
    
   private lazy var searchBar: SearchBarView = {
        let searchBar  = SearchBarView(frame: CGRect(x: 0, y: 0, width: searchBarViewWidth, height: searchBarViewHeight))
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    private lazy var didSelectCell = PassthroughSubject<IndexPath, Never>()
    
    private var searchBarViewWidth: CGFloat {
        return UIApplication.windowBound.width - 80
    }

    private var searchBarViewHeight: CGFloat {
        36
    }
    
    override func refreshView(_ animated: Bool) {
        super.refreshView(animated)
        defautlNavi()
        if let searchKey = searchBar.textField.text, !searchKey.isEmpty {
            shouldReloadData.send(searchKey)
        }
    }
    
    override func setupView() {
        super.setupView()
        setupSearchBar()
        setupTableView()
        
        keyboardPublisher.sink { [weak self] height in
            guard let self = self else { return }
            self.resultTableView.contentInset.bottom = self.tableBottomInset + height
        }.store(in: &anyCancelables)
        
        deleteDiaryNotification
            .sink {[weak self] diaryId in
                self?.deleteImage(with: diaryId)
            }.store(in: &anyCancelables)
    }
    
    private func deleteImage(with diaryId: String) {
        var snapshot = dataSource.snapshot()
        snapshot.deleteItems(snapshot.itemIdentifiers.filter { return $0.item.id == diaryId })
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func applyData(data: [SearchDiariesViewModel.CellModel]) {
        var snapShot = Snapshot()
        snapShot.appendSections([0])
        snapShot.appendItems(data, toSection: 0)
        dataSource.apply(snapShot, animatingDifferences: true)
    }
    
    private func setupSearchBar() {
        NSLayoutConstraint.activate([
            searchBar.heightAnchor.constraint(equalToConstant: searchBarViewHeight),
            searchBar.widthAnchor.constraint(equalToConstant: searchBarViewWidth)])
        navigationItem.titleView = searchBar
    }
    
    private let tableBottomInset: CGFloat = 110
    
    override func bindViewModel() {
        super.bindViewModel()
        
        let didSelectDiaryMode = didSelectCell
            .flatMap {[weak self] indexPath -> AnyPublisher<DiaryModel, Never> in
                guard let self = self else { return .empty() }
                return .just(self.dataSource.snapshot()[indexPath.row].item)
            }.eraseToAnyPublisher()
        
        let input = SearchDiariesViewModel.Input(searchTrigger: searchBar.textField.textPublisher,
                                                 didSelectCell: didSelectDiaryMode,
                                                 shouldReload: shouldReloadData.eraseToAnyPublisher())
        let output = viewModel.transform(input)
        output.searchResult
            .sink {[weak self] models in
                self?.applyData(data: models)
            }.store(in: &anyCancelables)
        
        output.itemCount.sink {[weak self] count in
            self?.itemCountLabel.text = String(format: LocalizedString.numberOfResults, "\(count)")
        }.store(in: &anyCancelables)
        
        output.noResult.sink {[weak self]  in
            let noRessult = ($0 && self?.searchBar.textField.text?.isEmpty == false)
            self?.resultTableView.backgroundView = noRessult ? self?.noResultLabel : nil
            self?.itemCountLabel.isHidden = noRessult ? true : false
        }.store(in: &anyCancelables)
        
        output.actionVoid.sink {}.store(in: &anyCancelables)
    }
    
    
    private func setupTableView() {
        resultTableView.dataSource = dataSource
        resultTableView.delegate = self
        resultTableView.rowHeight  = 120
        resultTableView.tableFooterView = UIView()
        resultTableView.contentInset.bottom = tableBottomInset
        resultTableView.tableHeaderView = itemCountLabel
    }
}

extension SearchDiariesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        didSelectCell.send(indexPath)
    }
}

struct StringHelper {
    static func getKeyWords(key: String) -> [String] {
        let inputString = key.replacingOccurrences(of: "\u{3000}", with: " ")
        var keys: [String] = []
        let seperator = CharacterSet(charactersIn: " ")
        keys = inputString.components(separatedBy: seperator).filter({$0 != ""})
        return keys
    }
}
