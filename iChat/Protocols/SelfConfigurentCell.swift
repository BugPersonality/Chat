//
//  SelfConfigurentCellProtocol.swift
//  iChat
//
//  Created by Данил Дубов on 25.09.2021.
//

import UIKit

protocol SelfConfigurentCell {
    static var reuseId: String { get }
    func configure<U: Hashable>(with value: U)
}
