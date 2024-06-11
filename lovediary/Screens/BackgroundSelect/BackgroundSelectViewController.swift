//
//  BackgroundSelectViewController.swift
//  lovediary
//
//  Created by daovu on 12/03/2021.
//

import UIKit
import Combine
import Configuration

extension BackgroundPresentModel: Hashable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct BackgroundPresentModel {
    var id: String
    var image: UIImage?
}

class BackgroundSelectViewController: BaseViewController<BackgroundSelectViewModel> {
    
    func applyTheme() {
        view.backgroundColor = Colors.settingTableViewBackgroundColor
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var previewImageContainer: UIView!
    
    private var selectedPosition = 1
    
    typealias DataSource = UICollectionViewDiffableDataSource<Int, BackgroundPresentModel>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, BackgroundPresentModel>
    
    private lazy var didSelectRowAt = PassthroughSubject<IndexPath, Never>()
    
    private lazy var rightGesturePublisher = self.view.addSwipeGesturePublisher(direction: .right)
    private lazy var leftGesturePublisher = self.view.addSwipeGesturePublisher(direction: .left)
    
    private lazy var doneBarButton = UIBarButtonItem(title: LocalizedString.done, style: .done, target: self, action: nil)
    
    private lazy var dataSource = DataSource(collectionView: self.collectionView) { collectionView, indexPath, background -> UICollectionViewCell? in
        let cell = collectionView.dequeueReusableCell(ThumpBackgroundCell.self, for: indexPath)
        switch indexPath.row {
        case 0:
            cell.bindToPlus()
        case self.selectedPosition:
            cell.bind(to: background, selected: true)
        default:
            cell.bind(to: background)
        }
        
        return cell
    }
    
    private func applyData(_ backgrounds: [BackgroundPresentModel], animation: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems([BackgroundPresentModel(id: UUID().uuidString, image: nil)], toSection: 0)
        snapshot.appendItems(backgrounds, toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: animation)
    }
    
    override func setupView() {
        super.setupView()
        setupCollectionView()
        applyTheme()
        setupGuesture()
    }
    
    override func refreshView(_ animated: Bool) {
        super.refreshView(animated)
        defautlNavi()
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.registerCell(ThumpBackgroundCell.self)
        collectionView.dataSource = dataSource
    }
    
    private func setupGuesture() {
        leftGesturePublisher.sink {[weak self] _ in
            guard let self = self, self.selectedPosition < self.dataSource.snapshot().itemIdentifiers.count else { return }
            if self.selectedPosition < self.dataSource.snapshot().itemIdentifiers.count - 1  {
                self.didSelectRowAt.send(IndexPath(row: self.selectedPosition + 1, section: 0))
            }
        }.store(in: &anyCancelables)
        
        rightGesturePublisher.sink {[weak self] _ in
            guard let self = self else { return }
            if self.selectedPosition > 1  {
                self.didSelectRowAt.send(IndexPath(row: self.selectedPosition - 1, section: 0))
            }
        }.store(in: &anyCancelables)
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        let selectRowTrigger = didSelectRowAt.map { $0.row }
            .removeDuplicates()
            .filter {[weak self] in !($0 == 0 || $0 == self?.selectedPosition) }
            .eraseToAnyPublisher()
        
        let addImageTrigger = didSelectRowAt.map { $0.row }
            .debounce(for: .milliseconds(200), scheduler: DispatchQueue.main)
            .filter { $0 == 0 }
            .flatMap{[weak self] _ -> AnyPublisher<Void, Never> in
                guard let self = self else { return .empty() }
                return self.checkAddBackground(numberOfBackground: self.dataSource.snapshot().numberOfItems - 1)
            }
            .flatMap {[weak self] _ -> AnyPublisher<UIImage, Never> in
                guard let self = self else { return .empty() }
                return self.showSingleImagePicker()
            }
            .eraseToAnyPublisher()
        
        let doneTrigger = doneBarButton.tapPublisher.flatMap {[weak self] _ -> AnyPublisher<String, Never> in
            guard let self = self else { return .empty() }
            let selectedID = self.dataSource.snapshot()[self.selectedPosition].id
            return .just(selectedID)
        }.eraseToAnyPublisher()
        
        let input = BackgroundSelectViewModel.Input(selectedItemTrigger: selectRowTrigger,
                                                    addBackgroundTrigger: addImageTrigger,
                                                    doneTrigger: doneTrigger)
        
        let output = viewModel.transform(input)
        
        output.listBackground.sink {[weak self] backgrounds in
            guard let self = self else { return }
            self.applyData(backgrounds, animation: !self.dataSource.snapshot().itemIdentifiers.isEmpty)
        }.store(in: &anyCancelables)
        
        output.selectedBackground.sink {[weak self] index in
            self?.setSelectImage(at: index + 1)
        }.store(in: &anyCancelables)
        
        output.actionVoid.sink {}.store(in: &anyCancelables)
        
        output.addBackgroundComplete.sink {[weak self] background in
            self?.addBackground(background: background)
        }.store(in: &anyCancelables)
        
        output.doneAction.sink {[weak self] _ in
            if self?.isModal == true {
                self?.dismiss(animated: true, completion: nil)
            } else {
                self?.navigationController?.popViewController(animated: true)
            }
        }.store(in: &anyCancelables)
    }
    
    private func addBackground(background: BackgroundPresentModel) {
        var snapShot = dataSource.snapshot()
        snapShot.insertItems([background], beforeItem: snapShot[1])
        dataSource.apply(snapShot, animatingDifferences: true)
        selectedPosition += 1
        swapSelected(to: 1)
        previewImageView.image = background.image
        Settings.isAdditionImageWithShareFB.value = false
    }
    
    private func checkAddBackground(numberOfBackground: Int) -> AnyPublisher<Void, Never> {
        guard !Settings.isRemoveAds.value else { return .just(()) }
        
        if Settings.isAdditionImageWithShareFB.value || numberOfBackground - StockBackgrounds.stockBackgrounds.count < AppConfigs.maxBackgroundInput {
            return .just(())
        }
        
        let maybe = Settings.sharedWithFBRequest.value ? "" : "\(LocalizedString.sendToFriends) +1"
        
        return AlertManager.shared.showConfirmMessage(message: LocalizedString.maxInputBackgroundAsk,
                                                      confirm: LocalizedString.purchaseButtonTitle,
                                                      maybe: maybe,
                                                      cancel: LocalizedString.cancel)
            .flatMap { select -> AnyPublisher<Void, Never> in
                switch select {
                case .confirm:
                    PremiumViewController.show()
                case .maybe:
                    let shared = ReviewHelper.shareAppToFriend()
                    shared?.customCompletionHandler = { _ in
                        Settings.sharedWithFBRequest.value = true
                        Settings.isAdditionImageWithShareFB.value = true
                    }
                    shared?.show()
                case .cancel:
                    break
                }
                return .empty()
            }.eraseToAnyPublisher()
    }
    
    private func setSelectImage(at index: Int) {
        let snapShot = dataSource.snapshot()
        
        if index <= snapShot.numberOfItems - 1 {
            let background = snapShot[index]
            previewImageView.image = background.image
            swapSelected(to: index)
        }
    }
    
    private func swapSelected(to index: Int) {
        guard index != 0, index != selectedPosition else { return }
        let oldSelected = selectedPosition
        selectedPosition = index
        var snapshot = dataSource.snapshot()
        snapshot.reloadItems([snapshot[oldSelected], snapshot[selectedPosition]])
        dataSource.apply(snapshot)
        self.collectionView.scrollToItem(at: IndexPath(row: index, section: 0),
                                         at: .centeredHorizontally, animated: true)
    }
    
    override func setupNavigationView() {
        super.setupNavigationView()
        navigationItem.title = LocalizedString.backgroundImageScreenTitle
        navigationItem.rightBarButtonItem = doneBarButton
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewImageContainer.dropShadow(color: .lightGray, opacity: 0.5, offSet: .init(width: 2, height: 2), radius: 16, scale: true)
    }
    
}

extension BackgroundSelectViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.bounds.height * 8 / 10
        return .init(width: height / 3 * 2, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        didSelectRowAt.send(indexPath)
    }
}
