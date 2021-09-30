//
//  UIButton + Extension.swift
//  iChat
//
//  Created by Данил Дубов on 23.09.2021.
//

import UIKit

extension UIButton {
    convenience init(title: String,
                     titleColor: UIColor,
                     backgroundColor: UIColor,
                     font: UIFont? = .avenir20(),
                     isShadow: Bool = false,
                     cornerRadius: CGFloat = 4) {

        self.init(type: .system)

        self.setTitle(title, for: .normal)
        self.setTitleColor(titleColor, for: .normal)
        self.backgroundColor = backgroundColor
        self.titleLabel?.font = font
        self.layer.cornerRadius = cornerRadius

        if isShadow {
            self.layer.shadowColor = UIColor.black.cgColor
            self.layer.shadowRadius = 4
            self.layer.shadowOpacity = 0.2
            self.layer.shadowOffset = CGSize(width: 0, height: 4)
        }
    }

    func customizeGoogleButton() {
        let googleLogo = UIImageView(image: UIImage(named: "googleLogo"),
                                     contentMode: .scaleAspectFit)

        googleLogo.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(googleLogo)

        googleLogo.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.centerY.equalToSuperview()
        }
    }
}
