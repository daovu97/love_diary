//
//  PhotosViewController.swift
//  QikNote
//
//  Created by daovu on 02/03/2021.
//

import UIKit
import Combine

class PhotosViewController: BaseViewController<GaleriesViewModel>, ThemeNotification {
    var subscription: AnyCancellable?
    
    func themeChange() {
        createNewDiaryButton.setTitleColor(.white, for: .normal)
        createNewDiaryButton.backgroundColor = Colors.toneColor
        view.backgroundColor = Colors.settingTableViewBackgroundColor
    }
    
    typealias DataSource = UICollectionViewDiffableDataSource<Int, ImageAttachment>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, ImageAttachment>
    
    @IBOutlet weak var createNewDiaryButton: UIButton!
    @IBOutlet weak var noImageFountTitle: UILabel!
    @IBOutlet weak var noDataView: UIView!
    
    private var numberOfItemInRow = Settings.galeryViewPosition.value + 1
    private let spacingItem = CGFloat(4)
    
    private lazy var rightGesturePublisher = self.view.addSwipeGesturePublisher(direction: .right)
    private lazy var leftGesturePublisher = self.view.addSwipeGesturePublisher(direction: .left)
    private lazy var sortBarButton = UIBarButtonItem(image: Images.Icon.sort,
                                                     style: .done, target: self, action: nil)
    
    private lazy var loadImageTrigger = PassthroughSubject<Void, Never>()
    private lazy var didSelectRowAt = PassthroughSubject<IndexPath, Never>()
    
    private var firstLaunch = true
    
    private lazy var dataSource = DataSource(collectionView: self.collectionView) { (collectionView, indexPath, image) -> UICollectionViewCell? in
        let cell = collectionView.dequeueReusableCell(GaleryImageCollectionViewCell.self, for: indexPath)
        cell.bind(image: image)
        return cell
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var viewModeSegmented: UISegmentedControl!
    
    private func setupObserver() {
        rightGesturePublisher.sink {[weak self] _ in
            guard let self = self else { return }
            var selectIndext = self.viewModeSegmented.selectedSegmentIndex - 1
            selectIndext = selectIndext == 0 ? 0 : selectIndext
            self.viewModeSegmented.selectedSegmentIndex = selectIndext
            self.viewModeSegmented.sendActions(for: .valueChanged)
        }.store(in: &anyCancelables)
        
        leftGesturePublisher.sink {[weak self] _ in
            guard let self = self else { return }
            var selectIndext = self.viewModeSegmented.selectedSegmentIndex + 1
            selectIndext = selectIndext == (self.viewModeSegmented.numberOfSegments - 1) ? (self.viewModeSegmented.numberOfSegments - 1) : selectIndext
            self.viewModeSegmented.selectedSegmentIndex = selectIndext
            self.viewModeSegmented.sendActions(for: .valueChanged)
        }.store(in: &anyCancelables)
        
        viewModeSegmented.publisher(for: .valueChanged).sink {[weak self] _ in
            guard let self = self else { return }
            let numberOfItem = self.viewModeSegmented.selectedSegmentIndex + 1
            self.numberOfItemInRow = numberOfItem
            Settings.galeryViewPosition.value = self.viewModeSegmented.selectedSegmentIndex
            self.collectionView.collectionViewLayout.invalidateLayout()
            UIView.transition(with: self.collectionView, duration: 0.34, options: .beginFromCurrentState) {
                self.collectionView.layoutIfNeeded()
            } completion: { _ in }
        }.store(in: &anyCancelables)
    }
    
    override func setupView() {
        collectionView.dataSource = dataSource
        self.viewModeSegmented.selectedSegmentIndex = Settings.galeryViewPosition.value
        addThemeObserver()
        themeChange()
        setupObserver()
        
        createNewDiaryButton.setTitle(LocalizedString.createNewDiary, for: .normal)
        createNewDiaryButton.titleLabel?.sizeToFit()
        createNewDiaryButton.setTitleColor(.white, for: .normal)
        createNewDiaryButton.backgroundColor = Colors.toneColor
        
        noImageFountTitle.text = LocalizedString.noImageTitle
    }
    
    override func setupNavigationView() {
        super.setupNavigationView()
        navigationItem.title = LocalizedString.galeryScreenTitle
        navigationItem.rightBarButtonItem = sortBarButton
    }
    
    private func applyData(data: [ImageAttachment], anim: Bool = true) {
        var snapShot = Snapshot()
        snapShot.appendSections([0])
        snapShot.appendItems(data, toSection: 0)
        dataSource.apply(snapShot, animatingDifferences: anim)
    }
    
    override func refreshView(_ animated: Bool) {
        super.refreshView(animated)
        loadImageTrigger.send()
        defautlNavi()
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        let selectTrigger = didSelectRowAt.compactMap {[weak self] indexPath -> (images: [ImageAttachment], selected: Int)? in
            guard let self = self else { return nil }
            return (self.dataSource.snapshot().itemIdentifiers, indexPath.row)
        }
        
        let loadImage = Publishers.Merge(sortBarButton.tapPublisher.map { return true}, loadImageTrigger.map { return false })
        
        let input = GaleriesViewModel.Input(loadImage: loadImage.eraseToAnyPublisher(),
                                            didSelectRowAt: selectTrigger.eraseToAnyPublisher(),
                                            toCreateNewDiary: createNewDiaryButton.tapPublisher.eraseToVoidAnyPublisher())
        let output = viewModel.transform(input)
        output.images
            .receive(on: DispatchQueue.main)
            .sink {[weak self] images in
                guard let self = self else { return }
                
                self.noDataView.isHidden = !images.isEmpty
                self.collectionView.isHidden = images.isEmpty

                self.applyData(data: images, anim: !self.firstLaunch)
                self.firstLaunch = false
            }.store(in: &anyCancelables)
        
        output.actionVoid.sink {}.store(in: &anyCancelables)
        loadImageTrigger.send()
    }
    
    deinit {
        removeThemeObserver()
    }
}

extension PhotosViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (collectionView.bounds.width - CGFloat((numberOfItemInRow - 1)) * spacingItem ) / CGFloat(numberOfItemInRow)
        var height = width
        if numberOfItemInRow == 1 {
            let item = dataSource.snapshot()[indexPath.row]
            height = CGFloat(Int(width) / item.width * item.height)
        } else {
            height = width
        }
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacingItem
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacingItem
    }
}

extension PhotosViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelectRowAt.send(indexPath)
    }
}
