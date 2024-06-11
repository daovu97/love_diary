//
//  BaseViewController.swift
//  QikNote
//
//  Created by daovu on 01/03/2021.
//

import UIKit
import Combine

class BaseViewModel: ViewModelType {
    struct Input {}
    struct Output {}
    func transform(_ input: Input) -> Output {
        return Output()
    }
}

class BaseViewController<ViewModel: ViewModelType>: UIViewController {
    var anyCancelables = Set<AnyCancellable>()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("DE-INIT \(self.className)")
    }
    
    var viewModel: ViewModel
    
    init?(coder: NSCoder, viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bindViewModel()
        setupNavigationView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshView(animated)
    }
    
    func setupView() {
//        navigationItem.backBarButtonItem = BackBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    func refreshView(_ animated: Bool) {}
    func setupNavigationView() {}
    func bindViewModel() {}
    
    func transparentNavi() {
        if let navigationController = navigationController as? BaseNavigationController {
            navigationController.transparent()
        }
    }
    
    func defautlNavi(hidenShadow: Bool = false, backgroundColor: UIColor = Themes.current.navigationColor.background) {
        if let navigationController = navigationController as? BaseNavigationController {
            navigationController.makeDefautl(hidenShadow: hidenShadow, backgroundColor: backgroundColor)
        }
    }
    
    func checkPhotoPermissionAndAction() -> AnyPublisher<Void, Never> {
        return Deferred {
            Future { promise in
                if #available(iOS 14.0, *) {
                    self.checkPhotoPermission(completion: { complete in
                        if complete { promise(.success(())) }
                    })
                } else {
                    promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    @available(iOS 14.0, *)
    func checkPhotoPermission(completion: @escaping (Bool) -> Void) {
        SettingsHelper.checkPhotoPermission { [weak self] isGranted in
            guard let self = self else { return }
            if isGranted {
                completion(true)
            } else {
                completion(false)
                AlertManager.shared
                    .showConfirmMessage(message: LocalizedString.askPhotoPermission,
                                        confirm: LocalizedString.openSettingApp,
                                        cancel: LocalizedString.cancel)
                    .sink { state in
                        if state == .confirm {
                            SettingsHelper.go(to: URL(string: UIApplication.openSettingsURLString)!)
                        }
                    }.store(in: &self.anyCancelables)
            }
        }
    }
}
