//
//  PickerUIDelegate.swift
//  lovediary
//
//  Created by vu dao on 18/03/2021.
//

import DKImagePickerController
import Configuration

class PickerUIDelegate: DKImagePickerControllerBaseUIDelegate {
    override func createDoneButtonIfNeeded() -> UIButton {
        let doneButton = super.createDoneButtonIfNeeded()
        let title = NSAttributedString(string: LocalizedString.done,
                                       attributes: [.font: UIFont.systemFont(ofSize: 18),
                                                    .foregroundColor: UIColor.systemPink])
        doneButton.setAttributedTitle(title, for: .normal)
        return doneButton
    }

    override func imagePickerControllerDidReachMaxLimit(_ imagePickerController: DKImagePickerController) {
        let limitExceededTitle = String(format: LocalizedString.reachLimitImageError, String(AppConfigs.maxNumberOfImages))
        AlertManager.shared.showErrorMessage(message: limitExceededTitle).sink {}.cancel()
    }

    override func imagePickerController(_ imagePickerController: DKImagePickerController, showsCancelButtonForVC vc: UIViewController) {
        super.imagePickerController(imagePickerController, showsCancelButtonForVC: vc)
        vc.navigationItem.rightBarButtonItem?.title = LocalizedString.cancel
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 18)]
        vc.navigationItem.rightBarButtonItem?.setTitleTextAttributes(attributes, for: .normal)
        vc.navigationItem.rightBarButtonItem?.setTitleTextAttributes(attributes, for: .disabled)
    }

    open override func imagePickerControllerCollectionImageCell() -> DKAssetGroupDetailBaseCell.Type {
        return PickerDetailImageCell.self
    }
}
