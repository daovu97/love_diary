//
//  ReminderTypeViewController.swift
//  lovediary
//
//  Created by daovu on 06/04/2021.
//

import UIKit
import Combine

class ReminderTypeViewController: UIViewController {
    private var anycancelables = Set<AnyCancellable>()
    
    func themeChange() {
        tableView.backgroundColor = Themes.current.settingTableViewColor.background
    }
    
    typealias DataSource = UITableViewDiffableDataSource<Int, SelectTableModel>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, SelectTableModel>
    
    private lazy var dataSource = DataSource(tableView: tableView) { (tableView, indexPath, data) -> UITableViewCell? in
        let cell = tableView.dequeueReusableCell(SelectTableCell.self, for: indexPath)
        cell.bind(data: data)
        cell.isSelectedCell = self.selectedIndexPath.contains(indexPath)
        return cell
    }
    
    @IBOutlet weak var tableView: UITableView!
    private var datas: [SelectTableModel] = []
    private var numberOfSelection: Int = 1
    var didSelectComplete: (([Int]) -> Void)?
    
    private var selectedIndexPath = Set<IndexPath>()
    
    var selectMaxErrorMessage = LocalizedString.reachChoseLimitError
    
    var navigationTitle: String = "" {
        didSet {
            navigationItem.title = navigationTitle
        }
    }
    
    private lazy var cancelButton = UIBarButtonItem(title: LocalizedString.cancel, style: .done, target: self, action: nil)
    private lazy var doneButton = UIBarButtonItem(title: LocalizedString.done, style: .done, target: self, action: nil)
    
    init?(coder: NSCoder,
          datas: [SelectTableModel],
          selectedPosition: [Int],
          numberOfSelection: Int = 1) {
        self.datas = datas
        self.numberOfSelection = numberOfSelection
        super.init(coder: coder)
        selectedPosition.forEach { row in
            self.selectedIndexPath.insert(IndexPath(row: row, section: 0))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        themeChange()
        tableView.delegate = self
        applyData(datas: datas)
        setNavigation()
    }
    
    private func setNavigation() {
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = doneButton
        cancelButton.tapPublisher.sink { [weak self] in self?.dismiss(animated: true, completion: nil) }.store(in: &anycancelables)
        doneButton.tapPublisher.sink {[weak self]  in
            guard let self = self else { return }
            self.didSelectComplete?(self.selectedIndexPath.map { $0.row })
            self.dismiss(animated: true, completion: nil)
        }.store(in: &anycancelables)
    }
    
    private func applyData(datas: [SelectTableModel]) {
        var snapShot = Snapshot()
        snapShot.appendSections([0])
        snapShot.appendItems(datas, toSection: 0)
        dataSource.apply(snapShot, animatingDifferences: false)
    }
    
    func updateNavigationBar() {
        doneButton.isEnabled = selectedIndexPath.count == numberOfSelection
    }
}

extension ReminderTypeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if selectedIndexPath.contains(indexPath) {
            //remove
            selectedIndexPath.remove(indexPath)
            tableView.reloadData()
        } else {
            //add
            if numberOfSelection == 1 {
                selectedIndexPath.removeAll()
                selectedIndexPath.insert(indexPath)
                tableView.reloadData()
            } else {
                if selectedIndexPath.count < numberOfSelection {
                    // add
                    selectedIndexPath.insert(indexPath)
                    tableView.reloadData()
                } else {
                    // prome max
                    AlertManager.shared.showErrorMessage(message: selectMaxErrorMessage).sink{}.cancel()
                }
            }
        }
        updateNavigationBar()
    }
}

extension ReminderTypeViewController {
    static func show(datas: [SelectTableModel],
                     selectedPosition: [Int] = [],
                     numberOfSelection: Int,
                     completion: ((ReminderTypeViewController) -> Void)?) -> UIViewController {
        let selectViewController = ReminderTypeViewController.instantiate {
            let vc = ReminderTypeViewController(coder: $0, datas: datas,
                                                selectedPosition: selectedPosition,
                                                numberOfSelection: numberOfSelection)
            return vc
        }
        completion?(selectViewController)
        let baseNavi = BaseNavigationController(rootViewController: selectViewController)
        return baseNavi
    }
}
