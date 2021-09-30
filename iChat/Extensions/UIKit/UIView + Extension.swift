//
//  UIView + Extension.swift
//  iChat
//
//  Created by Данил Дубов on 26.09.2021.
//

import UIKit

extension UIView {
    func applyGradients(cornerRadius: CGFloat) {
        self.backgroundColor = nil
        self.layoutIfNeeded()
        let gradientView = GradientView(from: .topTrailing, to: .bottomLeading,
                                        startColor: UIColor(red: 201/255, green: 161/255, blue: 240/255, alpha: 1),
                                        endColor: UIColor(red: 122/255, green: 178/255, blue: 235/255, alpha: 1 ))

        if let gradientLayer = gradientView.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = self.bounds
            gradientLayer.cornerRadius = cornerRadius
            self.layer.insertSublayer(gradientLayer, at: 0)
        }
    }
}
