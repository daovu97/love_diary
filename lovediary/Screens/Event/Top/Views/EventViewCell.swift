//
//  EventViewCell.swift
//  lovediary
//
//  Created by vu dao on 04/04/2021.
//

import UIKit
import Combine

class EventViewCell: UITableViewCell, ThemeNotification {
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
        tagView.backgroundColor = event.pinned ? Colors.toneColor : .clear
    }
    
    private func dayCountConvert(startDate: Date, dayLabel: UILabel) -> String {
        let dayBetween = DateHelper.dayBetweenDates(start: Date().startOfDay, end: startDate)
        switch dayBetween {
        case 0:
            dayLabel.isHidden = true
            contentView.alpha = 1
            return LocalizedString.todayLabel
        case ..<0:
            dayLabel.isHidden = false
            contentView.alpha = 0.6
            dayLabel.text = LocalizedString.dayAgo
            return "\(-dayBetween)"
        default:
            contentView.alpha = 1
            dayLabel.isHidden = false
            dayLabel.text = LocalizedString.days
            return "\(dayBetween)"
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
