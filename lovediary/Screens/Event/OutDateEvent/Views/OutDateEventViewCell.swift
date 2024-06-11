//
//  OutDateEventViewCell.swift
//  lovediary
//
//  Created by daovu on 08/04/2021.
//

import Foundation
import UIKit
import Combine

class OutDateEventViewCell: UITableViewCell, ThemeNotification {
    var subscription: AnyCancellable?
    
    func themeChange() {
        applyTheme()
    }
    
    @IBOutlet weak var evetTitleLabel: UILabel!
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var timelabel: UILabel!
    
    @IBOutlet weak var numberDayCountLabel: UILabel!
    @IBOutlet weak var daylabel: UILabel!
    @IBOutlet weak var tagView: UIView!
    
    func bind(event: EventModel) {
        evetTitleLabel.text = event.title
        eventDateLabel.text = event.date.format(partern: .dayShotDate)
        
        if let time = event.time {
            timelabel.isHidden = false
            timelabel.text = time.format(partern: .timeShort)
        } else {
            timelabel.text = ""
            timelabel.isHidden = true
        }
        
        numberDayCountLabel.text = dayCountConvert(startDate: event.date, dayLabel: daylabel)
        tagView.backgroundColor = .clear
    }
    
    private func dayCountConvert(startDate: Date, dayLabel: UILabel) -> String {
        let dayBetween = DateHelper.dayBetweenDates(start: Date().startOfDay, end: startDate) - 1
        switch dayBetween {
        case ..<0:
            dayLabel.text = LocalizedString.dayAgo
            return "\(-dayBetween)"
        default:
            dayLabel.text = ""
            return ""
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        applyTheme()
        addThemeObserver()
    }
    
    private func applyTheme() {
        let current = Themes.current.eventTableViewColor
        contentView.backgroundColor = current.cellBackground
        evetTitleLabel.textColor = current.cellEventText
        eventDateLabel.textColor = current.cellEventText.withAlphaComponent(0.7)
        timelabel.textColor = current.cellEventText.withAlphaComponent(0.7)
        numberDayCountLabel.textColor = current.cellEventTimeText
        daylabel.textColor = current.cellEventTimeText.withAlphaComponent(0.7)
    }
    
    deinit {
        removeThemeObserver()
    }
}

