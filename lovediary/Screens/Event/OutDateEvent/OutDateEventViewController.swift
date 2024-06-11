//
//  OutDateEventViewController.swift
//  lovediary
//
//  Created by daovu on 08/04/2021.
//

import UIKit
import Combine

class OutDateEventViewController: BaseViewController<OutDateEventViewModel> {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noDataView: UIView!
    @IBOutlet weak var noDataTitle: UILabel!
    
    @IBOutlet weak var adsContainerView: UIView!
    @IBOutlet weak var adsHeightConstraint: NSLayoutConstraint!
    
    typealias DataSource = OutDateEventDataSource
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, EventModel>
    
    private lazy var dataSource = DataSource(tableView: self.tableView) { (tableView, indexPath, event) -> UITableViewCell? in
        let cell = tableView.dequeueReusableCell(OutDateEventViewCell.self, for: indexPath)
        cell.bind(event: event)
        return cell
    }
    
    private lazy var loadData = PassthroughSubject<Void, Never>()
    private lazy var deleteData = PassthroughSubject<EventModel, Never>()
    private lazy var selectRowAt = PassthroughSubject<IndexPath, Never>()
    
    override func setupView() {
        super.setupView()
        dataSource.defaultRowAnimation = .fade
        noDataTitle.text = LocalizedString.noEventTitle
        applyTheme()
    }
    
    private func applyTheme() {
        tableView.backgroundColor = Themes.current.eventTableViewColor.background
        self.view.backgroundColor = Themes.current.eventTableViewColor.background
    }
    
    override func setupNavigationView() {
        super.setupNavigationView()
        navigationItem.title = LocalizedString.outDateEventScreenTitle
    }
    
    override func refreshView(_ animated: Bool) {
        super.refreshView(animated)
        defautlNavi()
        setBannerView(with: adsContainerView, heightConstraint: adsHeightConstraint)
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        let toEventDetail = selectRowAt.flatMap {[weak self] indexPath -> AnyPublisher<EventModel?, Never> in
            return .just(self?.dataSource.snapshot().itemIdentifiers[safe: indexPath.row])
        }.compactMap { $0 }.eraseToAnyPublisher()
        
        let input = OutDateEventViewModel.Input(loadData: loadData.eraseToAnyPublisher(),
                                                delete: deleteData.eraseToAnyPublisher(),
                                                toEventDetail: toEventDetail)
        
        let output = viewModel.transform(input)
        output.events
            .sink { [weak self] events in
                self?.noDataView.isHidden = !events.isEmpty
                self?.tableView.isHidden = events.isEmpty
                self?.applyData(events: events)
            }.store(in: &anyCancelables)
        
        loadData.send()
        
        output.actionVoid.sink {}.store(in: &anyCancelables)
    }
    
    private func applyData(events: [EventModel]) {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(events, toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: !dataSource.snapshot().itemIdentifiers.isEmpty)
    }
}

class OutDateEventDataSource: UITableViewDiffableDataSource<Int, EventModel> {
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
}

extension OutDateEventViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectRowAt.send(indexPath)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if let currentEvent = dataSource.snapshot().itemIdentifiers[safe: indexPath.row], !currentEvent.isDefault {
            let deleteAction = UIContextualAction(style: .destructive, title: LocalizedString.delete) { (action, view, completion) in
                self.deleteData.send(currentEvent)
                completion(true)
            }
            
            let config = UISwipeActionsConfiguration(actions: [deleteAction])
            config.performsFirstActionWithFullSwipe = true
            return config
        }
        return UISwipeActionsConfiguration(actions: [])
    }
}

extension OutDateEventViewController: AdsPresented {
    func bannerViewDidShow(bannerView: UIView, height: CGFloat) {
        tableView.contentInset = .init(top: 0, left: 0, bottom: bannerView.bounds.height, right: 0)
    }

    func removeAdsIfNeeded(bannerView: UIView) {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}
