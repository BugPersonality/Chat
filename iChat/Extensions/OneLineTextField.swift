//
//  OneLineTextField.swift
//  iChat
//
//  Created by Данил Дубов on 23.09.2021.
//

import UIKit

class OneLineTextField: UITextField {
    convenience init(font: UIFont? = .avenir20()) {
        self.init()

        self.font = font
        self.borderStyle = .none
        self.translatesAutoresizingMaskIntoConstraints = false

        configurateButtomView()
    }

    private func configurateButtomView() {
        let bottomView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        bottomView.backgroundColor = .textFieldLight()
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(bottomView)

        bottomView.snp.makeConstraints { make in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
    }
}
