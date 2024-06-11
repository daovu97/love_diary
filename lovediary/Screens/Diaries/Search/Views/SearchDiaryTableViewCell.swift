//
//  SearchDiaryTableViewCell.swift
//  lovediary
//
//  Created by vu dao on 28/03/2021.
//

import UIKit
import Combine

class SearchDiaryTableViewCell: UITableViewCell, ThemeNotification {
    var subscription: AnyCancellable?
    
    func themeChange() {
        applyTheme()
    }
    
    private func applyTheme() {
        dayLabel.textColor = Themes.current.diaryTableViewColor.cellDateTimeText
        dayNumberLabel.textColor = Themes.current.diaryTableViewColor.cellDateTimeText
        timeLabel.textColor = Themes.current.diaryTableViewColor.cellDateTimeText
        
        titleLabel.textColor = Themes.current.diaryTableViewColor.cellDiaryText
        detailLabel.textColor = Themes.current.diaryTableViewColor.cellDiaryText.withAlphaComponent(0.6)
        contentView.backgroundColor = Themes.current.diaryTableViewColor.cellBackground
    }
  
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dayNumberLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var attachmentImage: UIImageView!
    
    @IBOutlet weak var imageContainer: UIView!
    
    func bind(model: DiaryModel) {
        let textSplit = model.text.splistFirstLine()
        titleLabel.text = textSplit.first
        detailLabel.text = textSplit.detail
        
        titleLabel.setLineSpacing(6)
        detailLabel.setLineSpacing(6)
        
        titleLabel.lineBreakMode = .byTruncatingTail
        detailLabel.lineBreakMode = .byTruncatingTail
        
        if let image = model.attachments.first?.getImage() {
            attachmentImage.image = image
            imageContainer.isHidden = false
        } else {
            attachmentImage.image = nil
            imageContainer.isHidden = true
        }
        
        dayLabel.text = model.displayDate.format(partern: .date).uppercased()
        dayNumberLabel.text = "\(model.displayDate.day)"
        timeLabel.text = model.displayDate.format(partern: .timeShort)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        attachmentImage.layer.cornerRadius = 12
        applyTheme()
        addThemeObserver()
    }
    
    func highlight(texts: [String], color: UIColor) {
        detailLabel.highlight(keys: texts, color: color)
        titleLabel.highlight(keys: texts, color: color)
    }
    
    deinit {
        removeThemeObserver()
    }
}

