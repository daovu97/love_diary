//
//  UITableView+Extension.swift
//  QikNote
//
//  Created by daovu on 03/03/2021.
//

import Foundation
import UIKit

extension UITableView {
    
    func dequeueReusableCell<T: UITableViewCell>(_ cellType: T.Type, for indexPath: IndexPath) -> T {
        if let cell = dequeueReusableCell(withIdentifier: cellType.className, for: indexPath) as? T {
            return cell
        } else {
            fatalError("Couldn't dequeueReusableCell \(cellType.className)")
        }
    }
}

@IBDesignable extension UITableViewCell {
    @IBInspectable var selectedColor: UIColor? {
        get {
            return selectedBackgroundView?.backgroundColor
        }
        
        set {
            if let color = newValue {
                selectedBackgroundView = UIView()
                selectedBackgroundView!.backgroundColor = color
            } else {
                selectedBackgroundView = nil
            }
        }
    }
}

extension UICollectionView {
    
    func registerCell<T: UICollectionViewCell>(_ cellType: T.Type) {
        register(cellType.self, forCellWithReuseIdentifier: cellType.className)
    }
    
    func registerNib<T: UICollectionViewCell>(_ cellType: T.Type) {
        let nib = UINib(nibName: cellType.className, bundle: nil)
        register(nib, forCellWithReuseIdentifier: cellType.className)
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(_ cellType: T.Type, for indexPath: IndexPath) -> T {
        if let cell = dequeueReusableCell(withReuseIdentifier: cellType.className, for: indexPath) as? T {
            return cell
        } else {
            fatalError("Couldn't dequeueReusableCell \(cellType.className)")
        }
    }
}

extension NSDiffableDataSourceSnapshot  {
    subscript(_ index: Int) -> ItemIdentifierType {
        return itemIdentifiers[index]
    }
}
