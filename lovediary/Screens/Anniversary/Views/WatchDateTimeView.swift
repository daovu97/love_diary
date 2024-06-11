//
//  WatchDateTimeView.swift
//  lovediary
//
//  Created by daovu on 10/03/2021.
//

import Foundation

import UIKit
import Combine

@IBDesignable
class WatchDateTimeView: BaseView, ThemeNotification {
    var subscription: AnyCancellable?
    
    func themeChange() {
        applyTheme()
    }
    
    private func applyTheme() {
        setImageColor(color: Colors.toneColor)
    }
    
    deinit {
        removeThemeObserver()
    }
    
    enum DateTime: Int, CaseIterable {
        case year
        case month
        case date
        case hour
        
        var name: String {
            switch self {
            case .year: return LocalizedString.year
            case .month: return LocalizedString.month
            case .date: return LocalizedString.day
            case .hour: return LocalizedString.hour
            }
        }
    }
    
    private var childViews: [DateTimeView]
    
    private func dividerView() -> UILabel {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.text = ":"
        label.textColor = .white
        label.contentMode = .center
        label.textAlignment = .center
        return label
    }
    
    private lazy var startLoveDateView: StartLoveDateView = {
        let view = StartLoveDateView()
        
        return view
    }()
    
    override init(frame: CGRect = .zero) {
        childViews = [DateTimeView]()
        for view in DateTime.allCases {
            childViews.append(DateTimeView(name: view.name))
        }
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        childViews = [DateTimeView]()
        for view in DateTime.allCases {
            childViews.append(DateTimeView(name: view.name))
        }
        super.init(coder: coder)
    }
    
    override func setupUI() {
        super.setupUI()
        var dividers = [UIView]()
        var subViews = [UIView]()
        
        for (index, view) in childViews.enumerated() {
            subViews.append(view)
            if index != childViews.count - 1 {
                let divider = dividerView()
                dividers.append(divider)
                subViews.append(divider)
            }
        }
        
        setupStackView(subViews, dividers)
        applyTheme()
        addThemeObserver()
    }
    
    private func setConsstrain (view: UIView, stack: UIStackView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        [view.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.15),
         view.heightAnchor.constraint(equalTo: self.heightAnchor)]
            .forEach { $0.isActive = true }
    }
    
    private func setupStackView(_ subViews: [UIView], _ dividers: [UIView]) {
        let stack = UIStackView(arrangedSubviews: subViews)
        
        addSubview(stack)
        stack.apply {
            $0.alignment = .top
            $0.spacing = 4
            $0.axis = .horizontal
            $0.distribution = .fill
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        childViews.forEach {
            setConsstrain(view: $0, stack: stack)
        }
        
        [stack.centerXAnchor.constraint(equalTo: centerXAnchor),
         stack.topAnchor.constraint(equalTo: topAnchor)]
            .forEach { $0.isActive = true }
        
        dividers.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            [$0.widthAnchor.constraint(equalToConstant: 6),
             $0.heightAnchor.constraint(equalToConstant: 55)
            ].forEach { $0.isActive = true }
        }
        
        addSubview(startLoveDateView)
        startLoveDateView.anchor(top: stack.bottomAnchor,
                                 leading: leadingAnchor,
                                 bottom: nil,
                                 trailing: trailingAnchor,
                                 size: .init(width: 0, height: 40))
    }
    
    func setData(from date: Date) {
        let offset = date.offsetFromNow()
        childViews[DateTime.year.rawValue].textLabel.text = "\(offset.yearInt)"
        childViews[DateTime.month.rawValue].textLabel.text = "\(offset.monthInt)"
        childViews[DateTime.date.rawValue].textLabel.text = "\(offset.dayInt)"
        childViews[DateTime.hour.rawValue].textLabel.text = "\(offset.hourInt)"
        
        startLoveDateView.setStartDate(date: date.format(partern: .fullDate))
    }
    
    func setImage(icon: UIImage) {
        childViews.forEach {
            $0.setImage(icon: icon)
        }
    }
    
    func setImageColor(color: UIColor) {
        childViews.forEach {
            $0.setImageColor(color: color)
        }
    }
    
    func setTextColor(color: UIColor) {
        childViews.forEach {
            $0.setTextColor(color: color)
        }
    }
    
    func setTextFont(font: UIFont) {
        childViews.forEach {
            $0.setTextFont(font: font)
        }
    }
    
    func setDetailTextColor(color: UIColor) {
        childViews.forEach {
            $0.setDetailTextColor(color: color)
        }
    }
    
    func setDateColor(_ color: UIColor) {
        self.startLoveDateView.setTextColor(color)
    }
    
    func showHideStartDate(isShow: Bool, withAnim: Bool = true) {
        if withAnim {
            self.startLoveDateView.isHidden = false
            startLoveDateView.alpha = isShow ? 0 : 1
            UIView.animate(withDuration: 0.4, animations: {
                self.startLoveDateView.alpha = isShow ? 1 : 0
            }, completion: { _ in self.startLoveDateView.isHidden = !isShow })
            return
        }
        self.startLoveDateView.isHidden = !isShow
    }
}
