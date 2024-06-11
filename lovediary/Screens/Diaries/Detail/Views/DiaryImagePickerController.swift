//
//  DiaryImagePickerController.swift
//  lovediary
//
//  Created by daovu on 25/03/2021.
//

import Combine
import DKImagePickerController
import Photos

class DiaryImagePickerController: DKImagePickerController {
    
}

protocol DiaryImagePickerType {}

extension DiaryImagePickerType where Self: UIViewController {
    func showImagePicker(maxSelectableCount: Int) -> AnyPublisher<[DKAsset]?, Never> {
        return Deferred {
            Future { [weak self] promise in
                let pickerController = DiaryImagePickerController()
                pickerController.sourceType = .photo
                pickerController.assetType = .allPhotos
                pickerController.showsCancelButton = true
                pickerController.UIDelegate = PickerUIDelegate()
                pickerController.maxSelectableCount = maxSelectableCount
                
                pickerController.didCancel = { promise(.success(nil)) }
                
                pickerController.didSelectAssets = { (assets: [DKAsset]) in
                    guard assets.count > 0 else { return }
                    promise(.success(assets))
                }
                
                pickerController.modalPresentationStyle = .fullScreen
                self?.present(pickerController, animated: true, completion: nil)
            }
        }.eraseToAnyPublisher()
    }
    
    func checkCameraPermission() -> AnyPublisher<Bool, Never> {
        return Deferred {
            Future { promise in
                let status = AVCaptureDevice.authorizationStatus(for: .video)
                switch status {
                case .authorized:
                    promise(.success(true))
                case .notDetermined:
                    AVCaptureDevice.requestAccess(for: .video) { granted in
                        if granted {
                            promise(.success(true))
                        } else {
                            promise(.success(false))
                        }
                    }
                case .denied, .restricted:
                    promise(.success(false))
                default:
                    return
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}
