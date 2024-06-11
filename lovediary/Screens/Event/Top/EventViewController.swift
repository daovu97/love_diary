//
//  EventViewController.swift
//  lovediary
//
//  Created by vu dao on 04/04/2021.
//

import UIKit
import Combine

enum EventTVAction {
    case delete
    case pin
    case unpin
}

class EventViewController: BaseViewController<EventViewModel>, ThemeNotification {
    var subscription: AnyCancellable?
    
    func themeChange() {
        applyTheme()
    }
    
    private func applyTheme() {
        tableView.backgroundColor = Themes.current.eventTableViewColor.background
        tableView.reloadData()
    }
    
    deinit {
        removeThemeObserver()
    }
    
    typealias DataSource = EventDataSource
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, EventModel>
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addNewButton: UIButton!
    @IBOutlet weak var addNewButtonContainer: UIView!
    
    @IBOutlet weak var adsContainerView: UIView!
    @IBOutlet weak var adsHeightConstraint: NSLayoutConstraint!
    
    private lazy var loadData = PassthroughSubject<String, Never>()
    
    private lazy var outDateEventBarButton = UIBarButtonItem(image: Images.Icon.outDate,
                                                             style: .done, target: self, action: nil)
    
    private var tableViewInsetTop = CGFloat(20)
    
    private lazy var didSelectRowAt = PassthroughSubject<IndexPath, Never>()
    private lazy var didActionRowAt = PassthroughSubject<(indexPath: IndexPath, action: EventTVAction), Never>()
    private lazy var dismissTrigger = PassthroughSubject<Void, Never>()
    private lazy var didSearchTrigger = PassthroughSubject<String, Never>()
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = LocalizedString.searchEventPlaceHolder
        return searchController
    }()
    
    private lazy var dataSource = DataSource(tableView: self.tableView) { (tableView, indexPath, event) -> UITableViewCell? in
        let cell = tableView.dequeueReusableCell(EventViewCell.self, for: indexPath)
        cell.bind(event: event)
        return cell
    }
    
    private var isSearchMode = false
    
    private func setupSearchController() {
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = true
        navigationItem.searchController = searchController
    }
    
    private func setupTableView() {
        tableView.contentInset = .init(top: tableViewInsetTop, left: 0, bottom: tableViewInsetTop, right: 0)
    }
    
    override func setupView() {
        super.setupView()
        dataSource.defaultRowAnimation = .fade
        applyTheme()
        addThemeObserver()
        setupTableView()
        setupSearchController()
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        let toEventDetail = didSelectRowAt
            .flatMap {[weak self] indexPath -> AnyPublisher<EventModel?, Never> in
                return .just(self?.dataSource.snapshot().itemIdentifiers[safe: indexPath.row])
            }.eraseToAnyPublisher()
        
        let toEvent = Publishers.Merge(addNewButton.tapPublisher.map { _ -> EventModel? in return nil },
                                       toEventDetail)
        
        let action = didActionRowAt.flatMap {[weak self] indexPath, action -> AnyPublisher<(EventModel, EventTVAction), Never> in
            guard let self = self, let event = self.dataSource.snapshot().itemIdentifiers[safe: indexPath.row] else { return .empty() }
            return .just((event, action))
        }.eraseToAnyPublisher()
        
        let input = EventViewModel.Input(loadData: loadData.eraseToAnyPublisher(),
                                         action: action,
                                         toEventDetail: toEvent.eraseToAnyPublisher(),
                                         searchText: didSearchTrigger.eraseToAnyPublisher(),
                                         toOutDateEvent: outDateEventBarButton.tapPublisher)
        
        let output = viewModel.transform(input)
        
        output.events.sink { [weak self] events in
            self?.applyData(events: events)
        }.store(in: &anyCancelables)
        
        output.actionVoid.sink {}.store(in: &anyCancelables)
    }
    
    private func applyData(events: [EventModel]) {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(events, toSection: 0)
        snapshot.reloadItems(snapshot.itemIdentifiers)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    override func setupNavigationView() {
        super.setupNavigationView()
        navigationItem.title = LocalizedString.tabBarItemEvents
        navigationItem.rightBarButtonItems = [outDateEventBarButton]
    }
    
    override func refreshView(_ animated: Bool) {
        super.refreshView(animated)
        defautlNavi()
        loadData.send(getSearchKey())
        setBannerView(with: adsContainerView, heightConstraint: adsHeightConstraint)
    }
    
    private func getSearchKey() -> String {
        return searchController.searchBar.text ?? ""
    }
}

extension EventViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        didSelectRowAt.send(indexPath)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard !isSearchMode else { return  UISwipeActionsConfiguration(actions: []) }
        if let currentEvent = dataSource.snapshot().itemIdentifiers[safe: indexPath.row], !currentEvent.isDefault {
            let deleteAction = UIContextualAction(style: .destructive, title: LocalizedString.delete) { (action, view, completion) in
                self.didActionRowAt.send((indexPath, .delete))
                completion(true)
            }
            let config = UISwipeActionsConfiguration(actions: [deleteAction])
            config.performsFirstActionWithFullSwipe = true
            return config
        }
        return UISwipeActionsConfiguration(actions: [])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard !isSearchMode else { return  UISwipeActionsConfiguration(actions: []) }
        let currentEvent = dataSource.snapshot().itemIdentifiers[safe: indexPath.row]
        let pinAction = UIContextualAction(style: .normal, title: "") { (action, view, completion) in
            self.didActionRowAt.send((indexPath, currentEvent?.pinned == true ? .unpin : .pin ))
            completion(true)
        }
        pinAction.backgroundColor = Colors.toneColor
        pinAction.image = currentEvent?.pinned == true ? Images.Icon.unpin : Images.Icon.pin
        let config = UISwipeActionsConfiguration(actions: [pinAction])
        config.performsFirstActionWithFullSwipe = true
        return config
    }
    
}

class EventDataSource: UITableViewDiffableDataSource<Int, EventModel> {
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

extension EventViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        didSearchTrigger.send(getSearchKey())
        addNewButtonContainer.isHidden = true
    }
}

extension EventViewController: UISearchControllerDelegate {
    
    func willDismissSearchController(_ searchController: UISearchController) {
        loadData.send("")
        DispatchQueue.main.async {[weak self] in
            self?.addNewButtonContainer.isHidden = false
        }
    }
}

extension EventViewController: AdsPresented {
    func bannerViewDidShow(bannerView: UIView, height: CGFloat) {
        tableView.contentInset = .init(top: tableViewInsetTop, left: 0, bottom: tableViewInsetTop + bannerView.bounds.height, right: 0)
    }

    func removeAdsIfNeeded(bannerView: UIView) {
        tableView.contentInset = UIEdgeInsets(top: tableViewInsetTop, left: 0, bottom: tableViewInsetTop, right: 0)
    }
}

