//
//  UILabel + Extension.swift
//  iChat
//
//  Created by Данил Дубов on 23.09.2021.
//

import UIKit

extension UILabel {
    convenience init(text: String, font: UIFont? = .avenir20()) {
        self.init()
        self.text = text
        self.font = font
    }
}
