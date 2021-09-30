//
//  SectionHeader.swift
//  iChat
//
//  Created by Данил Дубов on 25.09.2021.
//

import UIKit
import SnapKit

class SectionHeader: UICollectionReusableView {
    static let reuseId = "SectionHeader"

    let title: UILabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        title.translatesAutoresizingMaskIntoConstraints = false
        addSubview(title)

        title.snp.makeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()
        }
    }

    func configurate(text: String, font: UIFont?, textColor: UIColor) {
        title.textColor = textColor
        title.font = font
        title.text = text
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
