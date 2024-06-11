//
//  ThemeSettingViewController.swift
//  lovediary
//
//  Created by daovu on 22/03/2021.
//

import UIKit
import Combine

class ThemeSettingViewController: BaseViewController<ThemeSettingViewModel> {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var doneButton: UIButton!
    
    private lazy var didScrollToIndex = CurrentValueSubject<Int, Never>(Settings.theme.value)
    
    typealias DataSource = UICollectionViewDiffableDataSource<Int, Themes>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Themes>
    
    private lazy var dataSource = DataSource(collectionView: collectionView) { (collectionView, indexPath, theme) -> UICollectionViewCell? in
        let cell = collectionView.dequeueReusableCell(ThemeCollectionViewCell.self, for: indexPath)
        cell.bind(theme: theme)
        return cell
    }
    
    override func refreshView(_ animated: Bool) {
        super.refreshView(animated)
        defautlNavi()
    }
    
    override func setupView() {
        super.setupView()
        
        collectionView.contentInset = .zero
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.automaticallyAdjustsScrollIndicatorInsets = false
        collectionView.contentInsetAdjustmentBehavior = .never
        
        var snapShot = Snapshot()
        snapShot.appendSections([0])
        snapShot.appendItems(Themes.allCases, toSection: 0)
        dataSource.apply(snapShot, animatingDifferences: false)
        pageControl.numberOfPages = Themes.allCases.count
        
        DispatchQueue.main.async {
            self.collectionView.scrollToItem(at: IndexPath(row: self.didScrollToIndex.value, section: 0),
                                             at: [.centeredHorizontally], animated: false)
        }
        
        doneButton.setTitle(LocalizedString.done, for: .normal)
        
        didScrollToIndex.removeDuplicates()
            .sink {[weak self] index in
                self?.pageControl.currentPage = index
                self?.navigationItem.title = Themes.allCases[index].name
                self?.themeDidChange(at: index)
            }.store(in: &anyCancelables)
        
        doneButton.tapPublisher.sink {[weak self] _ in
            self?.applyTheme()
            self?.navigationController?.popViewController(animated: true)
        }.store(in: &anyCancelables)
    }
    
    private func themeDidChange(at index: Int) {
        let current = Themes.allCases[index].theme
        current.applyNavigation(with: navigationController?.navigationBar)
        changeSettingNavigationTheme(theme: current)
        self.view.backgroundColor = current.settingTableViewColor.background
        doneButton.backgroundColor = current.pencilButtonColor.background
        current.applyUserInterfaceStyle()
    }
    
    private func applyTheme() {
        let index = self.didScrollToIndex.value
        Settings.theme.value = index
        Themes.getCurrent().theme.applyNavigation(with: navigationController?.navigationBar)
        Themes.getCurrent().theme.apply()
        changeSettingNavigationTheme(theme: Themes.current)
    }
    
    override func setupNavigationView() {
        super.setupNavigationView()
    }
    
    private func changeSettingNavigationTheme(theme: Theme) {
        navigationController?.navigationBar.barTintColor = theme.navigationColor.background
        navigationController?.navigationBar.tintColor = theme.navigationColor.tint
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: theme.navigationColor.title]
        navigationController?.navigationBar.barStyle = theme.navigationColor.barStyle
        theme.applyNavigationBarColor(with: navigationController?.navigationBar )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Themes.getCurrent().theme.applyNavigation(with: navigationController?.navigationBar)
        Themes.getCurrent().theme.apply()
    }
}

extension ThemeSettingViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
}

extension ThemeSettingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let selectTedIndex = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        didScrollToIndex.send(selectTedIndex)
    }
}
