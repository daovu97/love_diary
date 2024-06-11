//
//  DiariesViewController.swift
//  lovediary
//
//  Created by daovu on 10/03/2021.
//

import UIKit
import Combine
import FSCalendar

class DiariesViewController: BaseViewController<DiariesViewModel>, ThemeNotification {
    var subscription: AnyCancellable?
    
    func themeChange() {
        applyTheme()
    }
    
    private func applyTheme() {
        let diaryTableViewColor = Themes.current.diaryTableViewColor
        let calendarColor = diaryTableViewColor.calendarColor
        tableView.backgroundColor = diaryTableViewColor.background
        calendar.collectionView.backgroundColor = calendarColor.background
        calendar.backgroundColor = calendarColor.background
        calendar.appearance.weekdayTextColor = calendarColor.weekdayTitleColor
        calendar.appearance.titleDefaultColor = calendarColor.titleDefaultColor
        calendar.appearance.eventDefaultColor = calendarColor.eventDefaultColor
        calendar.appearance.eventSelectionColor = calendarColor.eventDefaultColor
        calendar.appearance.todayColor = calendarColor.todayColor
        calendar.appearance.selectionColor = calendarColor.selectionColor
        calendar.appearance.titleTodayColor = calendarColor.titleTodayColor
        calendar.appearance.titlePlaceholderColor = calendarColor.titlePlaceholderColor
        calendar.appearance.titleWeekendColor = calendarColor.titleWeekendColor
        calendar.appearance.titleSelectionColor = calendarColor.titleSelectionColor
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var adsContainerView: UIView!
    @IBOutlet weak var adsHeightConstraint: NSLayoutConstraint!
    
    
    typealias DataSource = CustomeDiaryDataSource
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, DiaryModel>
    
    private var diaryDates = Set<Date>()
    
    private lazy var scopeGesture: UIPanGestureRecognizer = {
        let panGesture = UIPanGestureRecognizer(target: self.calendar, action: #selector(self.calendar.handleScopeGesture(_:)))
        panGesture.delegate = self
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 2
        return panGesture
    }()
    
    private lazy var reloadTrigger = PassthroughSubject<LoadAction, Never>()
    private lazy var didSelectRowAt = PassthroughSubject<IndexPath, Never>()
    
    private lazy var didDeleteRowAt = PassthroughSubject<IndexPath, Never>()
    private lazy var viewWillAppear = PassthroughSubject<Void, Never>()
    private lazy var selectDateAt = PassthroughSubject<Date, Never>()
    private lazy var loadCalendarDataTrigger = CurrentValueSubject<Date, Never>(Date())
    
    private lazy var rightGesture = self.view.addSwipeGesture(direction: .right)
    private lazy var leftGesture = self.view.addSwipeGesture(direction: .left)
    private lazy var searchButton = UIBarButtonItem(image: Images.Icon.search, style: .done, target: self, action: nil)
    
    private lazy var dataSource = DataSource(tableView: self.tableView) { (tableView, indexPath, diaryModel) -> UITableViewCell? in
        let cell = tableView.dequeueReusableCell(DiaryTableViewCell.self, for: indexPath)
        cell.bind(model: diaryModel)
        return cell
    }
    
    private func setupTableView() {
        dataSource.defaultRowAnimation = .fade
        tableView.rowHeight = 120
        tableView.delegate = self
        tableView.dataSource = dataSource
    }
    
    private func setupCalendarView() {
        calendar.select(Date())
        calendar.locale = .currentLocale
        calendar.headerHeight = 0
        calendar.firstWeekday = 1
        self.calendar.addGestureRecognizer(self.scopeGesture)
        self.tableView.panGestureRecognizer.require(toFail: rightGesture)
        self.tableView.panGestureRecognizer.require(toFail: leftGesture)
        self.calendar.scope = .week
    }
    
    override func setupView() {
        super.setupView()
        setupTableView()
        applyTheme()
        addThemeObserver()
        setupCalendarView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewWillAppear.send()
    }
    
    private func deleteRowAt(indexPath: IndexPath) -> AnyPublisher<IndexPath, Never> {
        return AlertManager.shared.showConfirmMessage(message: LocalizedString.deleteDiaryConfirm,
                                                      confirm: LocalizedString.delete, cancel: LocalizedString.cancel,
                                                      isDelete: true)
            .flatMap { select -> AnyPublisher<IndexPath?, Never>  in
                return .just(select == .confirm ? indexPath : nil)
            }.compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
    override func refreshView(_ animated: Bool) {
        super.refreshView(animated)
        defautlNavi(hidenShadow: true)
        setBannerView(with: adsContainerView, heightConstraint: adsHeightConstraint)
        loadCalendarDataTrigger.send(loadCalendarDataTrigger.value)
    }
    
    override func setupNavigationView() {
        super.setupNavigationView()
        setTitle(date: Date())
        navigationItem.rightBarButtonItems = [searchButton]
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        let diarySelected = didSelectRowAt.map {[weak self] indexPath -> DiaryModel? in
            self?.tableView.deselectRow(at: indexPath, animated: true)
            return self?.dataSource.snapshot()[indexPath.row]
        }
        
        let toNewDiary = addButton.tapPublisher.map {_ -> DiaryModel? in return nil }
        
        let todiaryDetail = Publishers.Merge(diarySelected,
                                             toNewDiary.map {_ -> DiaryModel? in nil  }
        ).eraseToAnyPublisher()
        
        let previousTrigger =  Publishers.Merge(rightGesture.publisher.eraseToVoidAnyPublisher(),
                                                Empty().eraseToAnyPublisher()).map {_ in return LoadAction.previous }
        
        let nextTrigger = Publishers.Merge(leftGesture.publisher.eraseToVoidAnyPublisher(),
                                           Empty().eraseToAnyPublisher()).map {_ in return LoadAction.next }
        
        let selectedDate = selectDateAt
            .map { return LoadAction.custome(date: $0) }
        
        let loadDiarysTrigger = Publishers.Merge4(previousTrigger,
                                                  nextTrigger,
                                                  reloadTrigger.eraseToAnyPublisher(),
                                                  selectedDate.eraseToAnyPublisher())
        
        let deleteAction = didDeleteRowAt
            .debounce(for: .microseconds(100), scheduler: DispatchQueue.main)
            .flatMap {[weak self] indext -> AnyPublisher<IndexPath, Never> in
                guard let self = self else { return .empty() }
                return self.deleteRowAt(indexPath: indext)
            }
            .compactMap {[weak self] indexPath -> DiaryModel? in
                return self?.dataSource.snapshot().itemIdentifiers[safe: indexPath.row]
            }.eraseToAnyPublisher()
        
        let input = DiariesViewModel.Input(loadDiarysTrigger: loadDiarysTrigger.eraseToAnyPublisher(),
                                           toDiaryDetail: todiaryDetail,
                                           deleteTrigger: deleteAction,
                                           toSearchDiary: searchButton.tapPublisher.eraseToVoidAnyPublisher(),
                                           viewWillAppear: viewWillAppear.eraseToAnyPublisher(),
                                           loadCalendarDataTrigger: loadCalendarDataTrigger.eraseToAnyPublisher())
        let output = viewModel.transform(input)
        output.actionVoid.sink {}.store(in: &anyCancelables)
        
        output.diarys
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.applyData(diaries: $0)
            }.store(in: &anyCancelables)
        
        reloadTrigger.send(.today)
        
        output.currentDate
            .receive(on: DispatchQueue.main)
            .sink {[weak self] date in
                self?.calendar.select(date, scrollToDate: true)
            }.store(in: &anyCancelables)
        
        output.calendarDateEvents
            .receive(on: DispatchQueue.main)
            .sink {[weak self] dates in
                self?.diaryDates = dates
                self?.calendar.reloadData()
            }.store(in: &anyCancelables)
    }
    
    private func applyData(diaries: [DiaryModel]) {
        var snapShot = Snapshot()
        snapShot.appendSections([0])
        snapShot.appendItems(diaries, toSection: 0)
        snapShot.reloadItems(snapShot.itemIdentifiers)
        dataSource.apply(snapShot, animatingDifferences: true)
    }
    
    func resetToToday() {
        reloadTrigger.send(.today)
    }
    
    deinit {
        removeThemeObserver()
    }
}

extension DiariesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectRowAt.send(indexPath)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: LocalizedString.delete) { (action, view, completion) in
            self.didDeleteRowAt.send(indexPath)
            completion(false)
        }
        
        let config = UISwipeActionsConfiguration(actions: [deleteAction])
        config.performsFirstActionWithFullSwipe = true
        return config
    }
}

class CustomeDiaryDataSource: UITableViewDiffableDataSource<Int, DiaryModel> {
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

extension DiariesViewController: AdsPresented {
    func bannerViewDidShow(bannerView: UIView, height: CGFloat) {
        tableView.contentInset = .init(top: 0, left: 0, bottom: bannerView.bounds.height, right: 0)
    }
    
    func removeAdsIfNeeded(bannerView: UIView) {
        //        let originContenInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}

extension UIView {
    func addSwipeGesture(direction: UISwipeGestureRecognizer.Direction) -> UISwipeGestureRecognizer {
        let gesture = UISwipeGestureRecognizer(target: self, action: nil)
        gesture.direction = direction
        self.addGestureRecognizer(gesture)
        return gesture
    }
    
    func addSwipeGesturePublisher(direction: UISwipeGestureRecognizer.Direction) -> UIGestureRecognizerPublisher<UISwipeGestureRecognizer> {
        return addSwipeGesture(direction: direction).publisher
    }
}

extension DiariesViewController: FSCalendarDataSource, FSCalendarDelegate, UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let velocity = self.scopeGesture.velocity(in: view)
        
        let shouldBegin = self.tableView.contentOffset.y <= -self.tableView.contentInset.top
        if shouldBegin {
            switch self.calendar.scope {
            case .month:
                return velocity.y < 0
            case .week:
                return velocity.y > 0
            @unknown default:
                break
            }
        }
        return shouldBegin
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendarHeightConstraint.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if let currentDate = date.setTime(from: Date()) {
            selectDateAt.send(currentDate)
        }
        
        if monthPosition == .next || monthPosition == .previous {
            calendar.setCurrentPage(date, animated: true)
        }
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return diaryDates.contains(date) ? 1 : 0
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        let currentPageDate = calendar.currentPage
        if !currentPageDate.isEqualMonthInYear(with: loadCalendarDataTrigger.value) {
            loadCalendarDataTrigger.send(currentPageDate.startOfMonth)
        }
        
        setTitle(date: currentPageDate)
    }
    
    func setTitle(date: Date) {
        navigationItem.title = date.format(partern: .monthYear).capitalized
    }
}
