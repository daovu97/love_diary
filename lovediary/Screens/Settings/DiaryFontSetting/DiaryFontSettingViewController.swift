//
//  DiaryFontSettingViewController.swift
//  lovediary
//
//  Created by daovu on 22/03/2021.
//

import UIKit
import Combine

class DiaryFontSettingViewController: BasetableViewController<DiaryFontSettingViewModel>, ThemeNotification {
    var subscription: AnyCancellable?
    
    func themeChange() {
        tableView.backgroundColor = Themes.current.settingTableViewColor.background
    }
    
    deinit {
        removeThemeObserver()
    }
    
    @IBOutlet weak var fontSizeSlider: TextSettingSlider!
    @IBOutlet weak var lineSpacingSlider: TextSettingSlider!
    @IBOutlet weak var sampleTextView: UITextView!
    private let headerFooterHeight: CGFloat = 60
    private let numberOfSteps: Int = 16
    
    private lazy var resetDefaultButton = UIBarButtonItem(image: UIImage(systemName: "gobackward"),
                                                          style: .done, target: self, action: nil)
    
    private lazy var fontSizeValues: [Float] = {
        let minValue: Float = 8
        let maxValue: Float = 30
        let step = (maxValue - minValue) / Float(numberOfSteps - 1)
        return stride(from: minValue, to: maxValue + step, by: step).map {$0}
    }()
    
    private lazy var lineSpacingValues: [Float] = {
        let minValue: Float = 5
        let maxValue: Float = 25
        let step = (maxValue - minValue) / Float(numberOfSteps - 1)
        return stride(from: minValue, to: maxValue + step, by: step).map {$0}
    }()
    
    override func refreshView(_ animated: Bool) {
        super.refreshView(animated)
       defautlNavi()
    }
    
    override func setupView() {
        super.setupView()
        tableView.contentInset = .init(top: 24, left: 0, bottom: 0, right: 0)
        setupSlider()
        refreshSlider()
        sampleTextView.text = LocalizedString.fontSettingSampleTextTitle
        resetDefaultButton.tapPublisher.sink {[weak self] _ in
            Settings.fontSize.value = DefaultValue.fontSize
            Settings.lineSpacing.value = DefaultValue.lineSpacing
            self?.refreshSlider()
            self?.refreshSampleTextView()
        }.store(in: &anyCancelables)
        
        addThemeObserver()
        themeChange()
    }
    
    private func refreshSlider() {
        fontSizeSlider.value    = Float(getClosest(of: Settings.fontSize.value, in: fontSizeValues).offset)
        lineSpacingSlider.value = Float(getClosest(of: Settings.lineSpacing.value, in: lineSpacingValues).offset)
    }
    
    private func getClosest(of input: Float, in array: [Float]) -> (offset: Int, element: Float) {
        guard let closest = array.enumerated().min(by: { abs($0.1 - input) < abs($1.1 - input)}) else {
            return (0, 0)
        }
        return closest
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshSampleTextView()
    }
    
    private func setupSlider() {
        let steps = numberOfSteps - 1
        fontSizeSlider.minimumValue = 0
        fontSizeSlider.maximumValue = Float(steps)
        lineSpacingSlider.minimumValue = 0
        lineSpacingSlider.maximumValue = Float(steps)

    }
    
    override func setupNavigationView() {
        super.setupNavigationView()
        navigationItem.title = LocalizedString.diaryFontSettingTitle
        navigationItem.rightBarButtonItem = resetDefaultButton
    }
    
    @IBAction func changeValue(_ sender: UISlider) {
        let newIndex = Int(sender.value + 0.5)
        sender.setValue(Float(newIndex), animated: false)
        switch sender {
        case fontSizeSlider:
            guard let fontSize = fontSizeValues[safe: newIndex] else { return }
            if Settings.fontSize.value != fontSize {
                Settings.fontSize.value = fontSize
            }
        case lineSpacingSlider:
            guard let lineSpacing = lineSpacingValues[safe: newIndex] else { return }
            if Settings.lineSpacing.value != lineSpacing {
                Settings.lineSpacing.value = lineSpacing
            }
        default:
            return
        }
        
        refreshSampleTextView()
    }
    
    private func refreshSampleTextView() {
        sampleTextView.attributedText = NSAttributedString(string: sampleTextView.attributedText.string, attributes: SettingsHelper.textViewAttributes)
        sampleTextView.setFirstLineFont(SettingsHelper.firstLineFont)
    }
}

extension DiaryFontSettingViewController {
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? CGFloat.leastNonzeroMagnitude : headerFooterHeight
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == 4 ? headerFooterHeight : CGFloat.leastNonzeroMagnitude
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 1:
            return getHeaderView(text: LocalizedString.fontSizeSettingTitle)
        case 2:
            return getHeaderView(text: LocalizedString.lineHeightSettingTitle)
        default:
            return nil
        }
    }
    
    private func getHeaderView(text: String) -> UIView {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        let headerLabel: IncreaseHeightLabel = {
            let headerLabel = IncreaseHeightLabel()
            headerLabel.translatesAutoresizingMaskIntoConstraints = false
            headerLabel.font = .systemFont(ofSize: 13)
            headerLabel.text = text
            headerLabel.backgroundColor = UIColor.clear
            
            return headerLabel
        }()
        headerView.addSubview(headerLabel)
        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 8),
            headerLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8),
            headerLabel.heightAnchor.constraint(equalToConstant: 40)
            ])
        
        return headerView
    }

}

@IBDesignable
class TextSettingSlider: UISlider {
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var newBounds = super.trackRect(forBounds: bounds)
        newBounds.size.height = 5
        return newBounds
    }
}

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
