//
//  UIViewController + Extension.swift
//  iChat
//
//  Created by Данил Дубов on 26.09.2021.
//

import UIKit

extension UIViewController {
    func configure<T: SelfConfigurentCell, U: Hashable>(collectionView: UICollectionView,
                                                        cellType: T.Type,
                                                        withValue value: U,
                                                        for indexPath: IndexPath) -> T {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellType.reuseId, for: indexPath) as? T else {
            fatalError("Unable to dequeue \(cellType)")
        }
        cell.configure(with: value)
        return cell
    }
}
