//
//  BasetableViewController.swift
//  QikNote
//
//  Created by daovu on 01/03/2021.
//

import UIKit
import Combine

class BasetableViewController<ViewModel: ViewModelType>: UITableViewController {
    var anyCancelables = Set<AnyCancellable>()
    var viewModel: ViewModel
    deinit {
        anyCancelables.cancel()
        NotificationCenter.default.removeObserver(self)
        print("DE-INIT \(self.className)")
    }
    
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
    
    func defautlNavi() {
        if let navigationController = navigationController as? BaseNavigationController {
            navigationController.makeDefautl()
        }
    }
}
