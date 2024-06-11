//
//  SelectTableCell.swift
//  lovediary
//
//  Created by daovu on 06/04/2021.
//

import UIKit
import Combine

struct SelectTableModel {
    var id = UUID().uuidString
    var title: String = ""
}

extension SelectTableModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

class SelectTableCell: SettingTableViewCell, ThemeNotification {
    var subscription: AnyCancellable?
    
    func themeChange() {
        applyTheme()
    }
    
    override func setupView() {
        super.setupView()
        applyTheme()
        addThemeObserver()
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    
    func bind(data: SelectTableModel) {
        titleLabel.text = data.title
    }
    
    var isSelectedCell: Bool = false {
        didSet {
            accessoryType = isSelectedCell ? .checkmark : .none
        }
    }
    
    deinit {
        removeThemeObserver()
    }
}

