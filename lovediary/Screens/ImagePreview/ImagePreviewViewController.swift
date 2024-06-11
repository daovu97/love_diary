//
//  ImagePreviewViewController.swift
//  lovediary
//
//  Created by vu dao on 21/03/2021.
//

import UIKit
import Combine
import LinkPresentation

class ImagePreviewViewController: BaseViewController<BaseViewModel>, DeleteDiaryNotification {
    
    @IBOutlet weak var collectionContainerView: UIView!
    @IBOutlet weak var actionToolbar: UIToolbar!
    @IBOutlet weak var shareBarButton: UIBarButtonItem!
    @IBOutlet weak var showDiaryBarButton: UIBarButtonItem!
    
    typealias Datasource = UICollectionViewDiffableDataSource<Int, ImageAttachment>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, ImageAttachment>
    
    private lazy var isDarkTheme = Themes.getCurrent().isDarkTheme
    
    private lazy var collectionView: UICollectionView =  {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = .zero
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.insetsLayoutMarginsFromSafeArea = false
        collectionView.contentInset = .zero
        collectionView.isPagingEnabled = true
        collectionView.alwaysBounceVertical = false
        collectionView.bouncesZoom = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.automaticallyAdjustsScrollIndicatorInsets = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.backgroundColor = Themes.getCurrent().isDarkTheme ? .black : .white
        return collectionView
    }()
    
    private lazy var dataSource = Datasource(collectionView: self.collectionView) { (collectionView, indexPath, image) -> UICollectionViewCell? in
        let cell = collectionView.dequeueReusableCell(ImagePreviewViewCell.self, for: indexPath)
        cell.bind(url: image.getImageUrl(), image: image.image, tap: self.singleTap)
        return cell
    }
    
    private lazy var didScrollToIndex = CurrentValueSubject<Int, Never>(selectedIndext)
    private lazy var isPresentMode = CurrentValueSubject<Bool, Never>(false)
    var showDiaryTrigger: ((String) -> Void)?
    private lazy var doneBarButton = UIBarButtonItem(title: LocalizedString.done, style: .done, target: self, action: nil)
    
    private var imageAttachments: [ImageAttachment] = []
    
    private var isImageInDetail = false
    
    var selectedIndext: Int = 0
    
    private var sharedImage: ImageAttachment?
    
    init?(coder: NSCoder, imageAttachments: [ImageAttachment] = [], images: [UIImage] = [], selectedIndex: Int) {
        self.imageAttachments = imageAttachments
        if !images.isEmpty {
            self.imageAttachments = images.map({ image -> ImageAttachment in
                return ImageAttachment(image: image)
            })
        }
    
        self.isImageInDetail = !images.isEmpty && imageAttachments.isEmpty
        self.selectedIndext = selectedIndex
        super.init(coder: coder, viewModel: BaseViewModel())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showDiaryBarButton.isEnabled = !isImageInDetail
        if isImageInDetail {
            showDiaryBarButton.tintColor = .clear
        }
    }
    
   private lazy var singleTap = SingleTapGestureRecognizer(target: self, action: nil)
    
    private func setupObserve() {
        didScrollToIndex.removeDuplicates()
            .sink {[weak self] index in
                guard let self = self else { return }
                self.selectedIndext = index
                if !self.isImageInDetail {
                    self.navigationItem.title = self.imageAttachments[index].createDate
                        .format(partern: .fullDateTime)
                }
            }.store(in: &anyCancelables)
        didScrollToIndex.send(selectedIndext)
        
        Publishers.Merge(doneBarButton.tapPublisher.eraseToVoidAnyPublisher(),
                         view.addSwipeGesturePublisher(direction: .down).eraseToVoidAnyPublisher())
            .sink {[weak self] _ in
                self?.dismiss(animated: true, completion: nil)
            }.store(in: &anyCancelables)
        
        collectionView.isUserInteractionEnabled = true
        collectionView.addGestureRecognizer(singleTap)
        
        singleTap.publisher.sink {[weak self] _ in
            guard let self = self else { return }
            self.isPresentMode.send(!self.isPresentMode.value)
        }.store(in: &anyCancelables)
        
        isPresentMode.sink {[weak self] isPresent in
            self?.changePresentMode(isPresent: isPresent)
        }.store(in: &anyCancelables)
        
        showDiaryBarButton.tapPublisher.compactMap {[weak self] _ -> String? in
            guard let self = self, !self.isImageInDetail else { return nil }
            return self.imageAttachments[safe: self.didScrollToIndex.value]?.diaryId
        }.sink {[weak self] diaryId in
            self?.showDiaryTrigger?(diaryId)
        }.store(in: &anyCancelables)
        
        shareBarButton.tapPublisher.sink {[weak self]  in
            guard let self = self,
                  let selectedImage = self.imageAttachments[safe: self.didScrollToIndex.value] else { return }
            if let _ = selectedImage.getImage() {
                self.sharedImage = selectedImage
                let custom = CustomActivityViewController(self, activityItems: [self],
                                                          applicationActivities: nil)
                custom.customCompletionHandler = { _ in
                    self.sharedImage = nil
                }
                custom.show()
            }
            
        }.store(in: &anyCancelables)
        
        deleteDiaryNotification
            .sink {[weak self] diaryId in
                self?.deleteImage(with: diaryId)
            }.store(in: &anyCancelables)
    }
    
    private func deleteImage(with diaryId: String) {
        var snapshot = dataSource.snapshot()
        snapshot.deleteItems(snapshot.itemIdentifiers.filter({ image -> Bool in
            return image.diaryId == diaryId
        }))
        dataSource.apply(snapshot)
        if dataSource.snapshot().itemIdentifiers.isEmpty {
            DispatchQueue.main.async {
                self.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    override func setupView() {
        super.setupView()
        collectionContainerView.addSubview(collectionView)
        collectionView.fillSuperview()
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        
        collectionView.registerCell(ImagePreviewViewCell.self)
        collectionView.insetsLayoutMarginsFromSafeArea = false
        setupObserve()
        applyData(images: imageAttachments)
        DispatchQueue.main.async {
            self.collectionView.scrollToItem(at: IndexPath(row: self.selectedIndext, section: 0),
                                             at: [.centeredHorizontally], animated: false)
        }
    }
    
    private func applyData(images: [ImageAttachment]) {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(images, toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func changePresentMode(isPresent: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.actionToolbar.alpha = isPresent ? 0 : 1
            self.navigationController?.navigationBar.alpha = isPresent ? 0 : 1
            self.collectionView.backgroundColor = isPresent ? .black : self.isDarkTheme ? .black : .white
        }
    }
    
    override func setupNavigationView() {
        super.setupNavigationView()
        navigationItem.rightBarButtonItem = doneBarButton
    }
    
    override func refreshView(_ animated: Bool) {
        super.refreshView(animated)
        defautlNavi()
    }
}

extension ImagePreviewViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: self.view.frame.size.width, height: self.view.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
}

extension ImagePreviewViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let selectTedIndex = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        didScrollToIndex.send(selectTedIndex)
    }
}

protocol DeleteDiaryNotification {
    
}

extension DeleteDiaryNotification where Self: UIViewController {
    var deleteDiaryNotification: AnyPublisher<String, Never> {
        return NotificationCenter.default.publisher(for: .didDeleteDiaryNotification)
            .compactMap { notification -> String? in
                return notification.userInfo?[Notification.Name.didDeleteDiaryNotification] as? String
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

extension ImagePreviewViewController: UIActivityItemSource {
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return ""
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return nil
    }
    
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        if let image = sharedImage?.getImage() {
            let imageProvider = NSItemProvider(object: image)
            let metadata = LPLinkMetadata()
            metadata.imageProvider = imageProvider
            metadata.title = "\(LocalizedString.shareAppName)"
            let date = sharedImage?.createDate.format(partern: .fullDateTime) ?? ""
            metadata.originalURL = URL(fileURLWithPath: "\(image.getSizeIn(.megabyte))mb, \(date)")
            return metadata
        }
        
        return nil
    }
}

extension UIImage {

    public enum DataUnits: String {
        case byte, kilobyte, megabyte, gigabyte
    }

    func getSizeIn(_ type: DataUnits)-> String {

        guard let data = self.pngData() else {
            return ""
        }

        var size: Double = 0.0

        switch type {
        case .byte:
            size = Double(data.count)
        case .kilobyte:
            size = Double(data.count) / 1024
        case .megabyte:
            size = Double(data.count) / 1024 / 1024
        case .gigabyte:
            size = Double(data.count) / 1024 / 1024 / 1024
        }

        return String(format: "%.2f", size)
    }
}
