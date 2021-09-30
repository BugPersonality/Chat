//
//  ButtonFormView.swift
//  iChat
//
//  Created by Данил Дубов on 23.09.2021.
//

import UIKit

class ButtonFormView: UIView {

    var label: UILabel?
    var button: UIButton?

    init(label: UILabel, button: UIButton) {
        super.init(frame: .zero)

        self.label = label
        self.button = button

        configurate()
    }

    private func configurate() {
        guard let label = label, let button = button else { return }

        self.addSubview(label)
        self.addSubview(button)

        self.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false

        label.snp.makeConstraints { make in
            make.top.left.equalToSuperview()
        }

        button.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(Constants.buttonTopOffset)
            make.left.right.equalTo(self)
            make.height.equalTo(Constants.buttonHeight)
        }

        self.snp.makeConstraints { make in
            make.bottom.equalTo(button.snp.bottom)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private enum Constants {
    static let buttonHeight: Int = 60
    static let buttonTopOffset: Int = 20
}
