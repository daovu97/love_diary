//
//  DiaryDetailViewController.swift
//  lovediary
//
//  Created by daovu on 17/03/2021.
//

import UIKit
import Combine
import DKImagePickerController
import Configuration

class DiaryDetailViewController: BaseViewController<DiaryDetailViewModel>, DiaryImagePickerType {
    
    @IBOutlet weak var contentTextView: AttachmentTextView!
    private lazy var keyboardToolbar = DiaryKeyboardToolbar()
    private let paddingTextViewSpace: CGFloat = 15
    private var isDeleteTap = false
    @IBOutlet weak var bannerViewContainer: UIView!
    @IBOutlet weak var bannerViewHeight: NSLayoutConstraint!
    
    private lazy var doneButton = UIBarButtonItem(title: LocalizedString.done, style: .done, target: self, action: nil)
    private lazy var optionButton = UIBarButtonItem(image: Images.Icon.detail, style: .plain, target: self, action: nil)
  
    
    lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .dateAndTime
        datePicker.locale = .currentLocale
        return datePicker
    }()
    
    private lazy var datelabel: DiaryDateTitle = {
        let label = DiaryDateTitle()
        label.font = Fonts.getHiraginoSansFont(fontSize: 16, fontWeight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var saveTrigger = PassthroughSubject<NSAttributedString, Never>()
    private lazy var showImagePreview = PassthroughSubject<([UIImage], Int), Never>()
    private var imagePickerViewController: UIImagePickerController?
    
    override func setupView() {
        super.setupView()
        setupTextView()
        formatTextView()
        setupKeyboardToolbar()
        setupTextViewObserve()
        registerForKeyboardNotifications()
    }
    
    private func setupTextViewObserve() {
        Publishers.Merge(contentTextView.textBeginEditingPublisher.map { return true },
                         contentTextView.textEndEditingPublisher.map { return false })
            .sink { [weak self] isBegin in
                self?.navigationItem.rightBarButtonItem = isBegin ? nil : self?.optionButton
            }.store(in: &anyCancelables)
    }
    
    private func setupDate(date: Date) {
        datePicker.date = date
        datelabel.text = date.format(partern: .fullDateTime)
    }
    
    override func refreshView(_ animated: Bool) {
        super.refreshView(animated)
        defautlNavi()
        setBannerView(with: bannerViewContainer, heightConstraint: bannerViewHeight)
    }
    
    private func getOftionTapPublisher() -> AnyPublisher<(DiaryDetailOptionAction, AttachmentTextView), Never> {
        return optionButton.tapPublisher.flatMap { [weak self] _ -> AnyPublisher<DiaryDetailOptionAction, Never> in
            guard let self = self else { return .empty() }
            return self.optionTrigger()
        }.flatMap {[weak self] action -> AnyPublisher<(DiaryDetailOptionAction, AttachmentTextView), Never> in
            guard let self = self else { return .empty() }
            return .just((action, self.contentTextView))
        }.eraseToAnyPublisher()
    }
    
    private func dateChangePublisher() -> AnyPublisher<Date, Never> {
        return datePicker.publisher(for: .editingDidEnd).flatMap {[weak self] _ -> AnyPublisher<Date, Never> in
            guard let self = self else { return .empty() }
            return .just(self.datePicker.date)
        }.eraseToAnyPublisher()
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        let textChangePublisher = contentTextView.textDidChangePublisher
            .compactMap { $0 }
            .removeDuplicates()

        let input = DiaryDetailViewModel.Input(saveTrigger: saveTrigger.eraseToAnyPublisher(),
                                               optionActionTrigger: getOftionTapPublisher(),
                                               dateChangeTrigger: dateChangePublisher(),
                                               contentAttributedString: textChangePublisher.eraseToAnyPublisher(),
                                               showImagePreview: showImagePreview.eraseToAnyPublisher())

        let output = viewModel.transform(input)

        output.actionVoid.sink { }.store(in: &anyCancelables)

        output.text.sink {[weak self] attribute in
            self?.contentTextView.attributedText = attribute
            self?.formatTextView()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self?.textViewScrollToTop()
            }
        }.store(in: &anyCancelables)

        output.viewMode.sink {[weak self] in
            self?.setupViewMode(viewMode: $0)
        }.store(in: &anyCancelables)
        
        output.shouldEdit.sink {[weak self] _ in
            self?.contentTextView.becomeFirstResponder()
        }.store(in: &anyCancelables)

        output.date.sink {[weak self] in
            self?.setupDate(date: $0)
        }.store(in: &anyCancelables)

        output.textCount.sink {[weak self] count in
            self?.setTextCount(count: count)
        }.store(in: &anyCancelables)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if !self.isDeleteTap {
            self.isDeleteTap = false
            self.saveTrigger.send(self.contentTextView.attributedText)
        }
        super.viewWillDisappear(animated)
    }
    
    override func setupNavigationView() {
        super.setupNavigationView()
        
        if #available(iOS 14.0, *) {
            if #available(iOS 15.0, *) {
                setUpDatePickerForIos13()
                return
            }
            
            datePicker.addSubview(datelabel)
            NSLayoutConstraint.activate([
                datelabel.leadingAnchor.constraint(equalTo: datePicker.leadingAnchor),
                datelabel.trailingAnchor.constraint(equalTo: datePicker.trailingAnchor),
                datelabel.centerYAnchor.constraint(equalTo: datePicker.centerYAnchor)
            ])
            datePicker.bringSubviewToFront(datelabel)
            datePicker.subviews.first?.subviews.forEach { $0.isHidden = true }
            
            datelabel.backgroundColor = Colors.toneColor.withAlphaComponent(0.5)
            datelabel.layer.cornerRadius = 12
            datelabel.layer.masksToBounds = true
            navigationItem.titleView = datePicker
        } else {
            setUpDatePickerForIos13()
        }
        
        navigationItem.rightBarButtonItem = optionButton
    }
    
    private func setUpDatePickerForIos13() {
        datelabel.backgroundColor = Colors.toneColor.withAlphaComponent(0.5)
        navigationItem.titleView = datelabel
        datelabel.layer.cornerRadius = 12
        datelabel.layer.masksToBounds = true
        if viewModel.viewMode == .preview { return }
        datelabel.viewTapPublisher().sink {[weak self] _ in
            guard let self = self else { return }
            self.showDatePicker(datePicker: self.datePicker)
        }.store(in: &anyCancelables)
    }
    
    private func formatTextView() {
        let selectedTextRange = contentTextView.selectedTextRange
        let contentOffset = contentTextView.contentOffset
        setAttributesTextView()
        contentTextView.selectedTextRange = selectedTextRange
        contentTextView.setContentOffset(contentOffset, animated: false)
    }
    
    private func setAttributesTextView() {
        contentTextView.setAttributes(SettingsHelper.textViewAttributes)
        let linkColor = SettingsHelper.textViewLinkColor
        let underlineStyle = NSUnderlineStyle.single.rawValue
        let firstLineFont = SettingsHelper.firstLineFont
        contentTextView.setLinkAttributes(color: linkColor, underlineStyleRawValue: underlineStyle)
        contentTextView.setFirstLineFont(firstLineFont)
    }
    
    private func setTextCount(count: Int) {
        keyboardToolbar.textCountLabel.title = "\(count)"
    }
}

extension DiaryDetailViewController {
    private func setupKeyboardToolbar() {
        keyboardToolbar.photoButton.tapPublisher
            .flatMap { [weak self] _ -> AnyPublisher<Void, Never> in
                guard let self = self else { return .empty() }
                return  self.checkPhotoPermissionAndAction()
            }.flatMap {[weak self] _ -> AnyPublisher<[DKAsset]?, Never> in
                guard let self = self else { return .empty() }
                guard self.contentTextView.attributedText.images.count < AppConfigs.maxNumberOfImages else {
                    self.showErrorMessage(message: LocalizedString.reachLimitImageError).sink {}.cancel()
                    return .empty()
                }
                
                let maxSelect = AppConfigs.maxNumberOfImages - self.contentTextView.attributedText.images.count
                
                return self.showImagePicker(maxSelectableCount: maxSelect)
            }.sink {[weak self] assets in
                guard let self = self else { return }
                guard let assets = assets else {
                    self.contentTextView.resignFirstResponder()
                    return
                }
                
                self.updateSelectedPhotos(assets: assets)
            }.store(in: &anyCancelables)
        
        keyboardToolbar.cameraButton.tapPublisher
            .flatMap {[weak self] _ -> AnyPublisher<Bool, Never> in
            guard let self = self else { return .empty() }
            return self.checkCameraPermission()
        }.sink {[weak self] authorized in
            guard let self = self else { return }
            print(authorized)
            if authorized {
                self.didTapCameraBarButtonHandler()
            } else {
                self.cameraDenied()
            }
        }.store(in: &anyCancelables)
        
        keyboardToolbar.doneButton.tapPublisher.sink {[weak self] _ in
            self?.contentTextView.resignFirstResponder()
            self?.formatTextView()
            if let attribute = self?.contentTextView.attributedText {
                self?.saveTrigger.send(attribute)
            }
        }.store(in: &anyCancelables)
    }
    
    private func getCurrentCursorPosition() {
        let plusTopLeftY = contentTextView.contentOffset == .zero ? 0 : (contentTextView.font?.lineHeight ?? 0)
        let topLeft = CGPoint(x: contentTextView.bounds.minX, y: contentTextView.bounds.minY + plusTopLeftY)
        guard let newPosition = contentTextView.closestPosition(to: topLeft) else {
            return
        }
        
        contentTextView.selectedTextRange = contentTextView.textRange(from: newPosition, to: newPosition)
    }
    
    private func cameraDenied() {
        showErrorMessage(message: LocalizedString.askCameraPermission)
            .sink {
                SettingsHelper.goToSettingApp()
            }.store(in: &anyCancelables)
    }
    
    private func didTapCameraBarButtonHandler() {
        self.didTapBarButtonHandler(.camera, barButtonItem: self.keyboardToolbar.cameraButton)
    }
    
    private func didTapBarButtonHandler(_ sourceType: UIImagePickerController.SourceType, barButtonItem: UIBarButtonItem) {
        guard self.contentTextView.attributedText.images.count < AppConfigs.maxNumberOfImages else {
            AlertManager.shared.showErrorMessage(message: LocalizedString.reachLimitImageError).sink {}.store(in: &anyCancelables)
            return
        }
        
        if let imagePickerController = getImagePickerViewController(sourceType: sourceType, barButtonItem: barButtonItem) {
            self.imagePickerViewController = imagePickerController
            self.imagePickerViewController?.delegate = self
            self.present(self.imagePickerViewController!, animated: true, completion: nil)
        }
    }
    
    func getImagePickerViewController(sourceType: UIImagePickerController.SourceType, barButtonItem: UIBarButtonItem) -> UIImagePickerController? {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
            return nil
        }
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = sourceType
        imagePickerController.modalPresentationStyle = .popover
        let popoverPresentationController = imagePickerController.popoverPresentationController
        if traitCollection.horizontalSizeClass == .regular {
            popoverPresentationController?.barButtonItem = barButtonItem
        } else {
            popoverPresentationController?.sourceView = self.view
        }
        return imagePickerController
    }
    
    private func updateSelectedPhotos(assets: [DKAsset]) {
        ProgressHelper.shared.show()
        var isImagesLoaded = Array(repeating: false, count: assets.count)
        var selectedImages: [UIImage] = []
        for (index, asset) in assets.enumerated() {
            asset.fetchOriginalImage { [weak self] (image, _) in
                guard let self = self else { return }
                if let selectedImage = image {
                    selectedImages.append(selectedImage)
                }
                
                isImagesLoaded[index] = true
                
                if (isImagesLoaded.filter { $0 == true }).count == assets.count {
                    self.textViewInsertImage(selectedImages)
                    FileManager.default.clearTempDirectory()
                }
            }
        }
    }
    
    private func textViewInsertImage(_ images: [UIImage]) {
        contentTextView.insertImageToTextField(images)
        formatTextView()
        contentTextView.becomeFirstResponder()
        saveTrigger.send(contentTextView.attributedText)
    }
    
}

// MARK: - ImagePickerDelegate
extension DiaryDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let chosenImage = info[.originalImage] as? UIImage, let _ = contentTextView.selectedTextRange else {
            dismissImagePicker(picker)
            return
        }
        if picker.sourceType == .camera {
            UIImageWriteToSavedPhotosAlbum(chosenImage, self, nil, nil)
        }
        textViewInsertImage([chosenImage])
        FileManager.default.clearTempDirectory()
        dismissImagePicker(picker)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismissImagePicker(picker)
    }
    
    private func dismissImagePicker(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {
            self.contentTextView.becomeFirstResponder()
            self.imagePickerViewController = nil
        }
    }
}

extension DiaryDetailViewController {
    
    func optionTrigger() -> AnyPublisher<DiaryDetailOptionAction, Never> {
        return Deferred {
            Future { promise in
                let shareImageAction = UIAlertAction(title: LocalizedString.shareAsImageTitle, style: .default) { action in
                    promise(.success(.shareImage))
                }
                
                let sharPdfAction = UIAlertAction(title: LocalizedString.sharePDFTitle, style: .default) { action in
                    promise(.success(.sharePDF))
                }
                
                let deleteAction = UIAlertAction(title: LocalizedString.delete, style: .destructive) { action in
                    self.isDeleteTap = true
                    promise(.success(.delete))
                }
                
                let cancel = UIAlertAction(title: LocalizedString.cancel, style: .cancel, handler: nil)
                
                AlertManager.shared.showActionSheet(actions: [shareImageAction, sharPdfAction, deleteAction, cancel])
            }
        }.eraseToAnyPublisher()
    }
    
    private func setupViewMode(viewMode: DiaryViewMode) {
        if viewMode == .preview {
            self.contentTextView.isEditable = false
            self.contentTextView.isSelectable = false
            self.datelabel.isUserInteractionEnabled = false
            self.datePicker.isUserInteractionEnabled = false
            self.navigationItem.rightBarButtonItem = self.doneButton
            doneButton.tapPublisher.sink {[weak self] _ in
                self?.dismiss(animated: true, completion: nil)
            }.store(in: &anyCancelables)
        } else {
            self.datelabel.isUserInteractionEnabled = true
            self.datePicker.isUserInteractionEnabled = true
            self.contentTextView.isEditable = true
            self.contentTextView.isSelectable = true
            self.navigationItem.rightBarButtonItem = optionButton
        }
    }
    
    private func setupTextView() {
        contentTextView.delegate = self
        contentTextView.attachmentDelegate = self
        contentTextView.linkTextAttributes = [:]
        contentTextView.font = SettingsHelper.boldFont
        contentTextView.tintColor = Colors.toneColor
        contentTextView.keyboardAppearance = Themes.current.keyboardAppearance
        contentTextView.textDragInteraction?.isEnabled = false
        self.contentTextView.textContainerInset = UIEdgeInsets(top: paddingTextViewSpace,
                                                               left: paddingTextViewSpace,
                                                               bottom: paddingTextViewSpace,
                                                               right: paddingTextViewSpace)
        self.contentTextView.textContainer.lineFragmentPadding = 0
        contentTextView.alwaysBounceHorizontal = false
        contentTextView.isEditable = true
        contentTextView.inputAccessoryView = keyboardToolbar
        contentTextView.selectedTextRange = contentTextView.textRange(from: contentTextView.endOfDocument, to: contentTextView.endOfDocument)
        contentTextView.scrollsToTop = true
    }
    
    private func registerForKeyboardNotifications() {
        keyboardPublisher.sink { [weak self] inset in
            guard let self = self else { return }
            let bottomInset = inset == 0 ? self.bannerViewHeight.constant : inset
            self.contentTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset + self.paddingTextViewSpace, right: 0)
            self.contentTextView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
        }.store(in: &anyCancelables)
    }
    
    private func scrollToCaretPosition() {
        DispatchQueue.main.async {
            let caret = self.contentTextView.caretRect(for: self.contentTextView.selectedTextRange?.start ?? self.contentTextView.endOfDocument)
            UIView.performWithoutAnimation {
                self.contentTextView.scrollRectToVisible(caret, animated: false)
                // Fix LTT no 44 scroll view not scroll THANHLD
                self.contentTextView.isScrollEnabled = false
                self.contentTextView.isScrollEnabled = true
            }
        }
    }
    
}

extension DiaryDetailViewController: AdsPresented {
    func bannerViewDidShow(bannerView: UIView, height: CGFloat) {
        self.contentTextView.contentInset.bottom = self.contentTextView.contentInset.bottom + height
    }
    
    func removeAdsIfNeeded(bannerView: UIView) {
        self.contentTextView.contentInset.bottom = self.paddingTextViewSpace
    }
}

extension DiaryDetailViewController: UITextViewDelegate, AttachmentTextViewDelegate {
    func tappedAttachment(_ attachemnt: NSTextAttachment) {
       _ = showImageView(with : attachemnt, allImage: contentTextView.attributedText.images)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        textView.typingAttributes = SettingsHelper.textViewAttributes
        var isInsertingInFrontOfImage = false
        if range.length == 0 && range.location < textView.text.utf16.count && !text.isEmpty && text != "\n" {
            let newRange = NSRange(location: range.location, length: range.length + 1)
            textView.attributedText.enumerateAttribute(.attachment, in: newRange, options: []) { (value, range, stop) in
                if let attachment = value as? NSTextAttachment, attachment.image != nil, let selectedTextRange = textView.selectedTextRange {
                    isInsertingInFrontOfImage = true
                    textView.replace(selectedTextRange, withText: "\n")
                    textView.selectedTextRange = selectedTextRange
                }
            }
        }
        
        if isInsertingInFrontOfImage {
            return true
        }
        return true
    }
    
    func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        guard interaction == .invokeDefaultAction else { return false }
        if #available(iOS 13.0, *) {
            return false
        }
        return showImageView(with: textAttachment, allImage: textView.attributedText.images)
    }
    
    func showImageView(with textAttachment: NSTextAttachment, allImage: [UIImage]) -> Bool {
        if let image = textAttachment.image, let selectedIndex = allImage.firstIndex(of: image) {
            showImagePreview.send((allImage, selectedIndex))
        }
        return false
    }
    
    func textViewScrollToTop() {
        contentTextView.setContentOffset(.zero, animated: false)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if self.contentTextView.isPastingText {
            self.contentTextView.isPastingText = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
                guard let self = self else { return }
                self.formatTextView()
            }
        }
    }
}

// MARK: - ScrollView delegate
extension DiaryDetailViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        viewModel.isDraggingTextView = true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !viewModel.isDraggingTextView && viewModel.didChangeTextView else { return }
        viewModel.didChangeTextView = false
        scrollToCaretPosition()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        viewModel.isDraggingTextView = false
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        viewModel.isDraggingTextView = false
    }
}
