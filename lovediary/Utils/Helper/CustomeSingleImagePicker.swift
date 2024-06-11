//
//  CustomeSingleImagePicker.swift
//  lovediary
//
//  Created by vu dao on 11/03/2021.
//

import DKImagePickerController
import Combine
import CropViewController

class CustomeSingleImagePickerController: DKImagePickerController {
    var didSelectImage: ((UIImage) -> Void)?
    var customAspectRatio: CGSize = UIScreen.main.ratio
    private lazy var didSelectAsset = PassthroughSubject<[DKAsset], Never>()
    private var anycancelables = Set<AnyCancellable>()
    override func done() {
        didSelectAsset.send(self.selectedAssets)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        didSelectAsset
            .debounce(for: .milliseconds(200), scheduler: DispatchQueue.main)
            .compactMap { return $0.first }.filter { $0.type == .photo }
            .sink { [weak self] asset in
                asset.fetchOriginalImage {[weak self] (image, _) in
                    guard let self = self else { return }
                    if let image = image {
                        let cropViewController = CropViewController(croppingStyle: .default,
                                                                    image: image)
                        cropViewController.delegate = self
                        cropViewController.customAspectRatio = self.customAspectRatio
                        cropViewController.aspectRatioLockEnabled = true
                        self.pushViewController(cropViewController, animated: true)
                    }
                }
            }.store(in: &anycancelables)
    }
    
    deinit {
        anycancelables.forEach { $0.cancel() }
        anycancelables.removeAll()
    }
    
}

extension CustomeSingleImagePickerController: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController,
                            didCropToImage image: UIImage,
                            withRect cropRect: CGRect, angle: Int) {
        didSelectImage?(image)
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

extension UIViewController {
    func showSingleImagePicker(size: CGSize = UIScreen.main.ratio) -> AnyPublisher<UIImage, Never> {
        return Deferred {
            Future { [weak self] promise in
                let pickerController = CustomeSingleImagePickerController()
                pickerController.singleSelect = true
                pickerController.sourceType = .photo
                pickerController.assetType = .allPhotos
                pickerController.showsCancelButton = true
                pickerController.autoCloseOnSingleSelect = true
                pickerController.customAspectRatio = size
                pickerController.UIDelegate = PickerUIDelegate()
                pickerController.didSelectImage = { image in
                    promise(.success(image))
                }
                self?.present(pickerController, animated: true, completion: nil)
            }
        }.eraseToAnyPublisher()
    }
}
