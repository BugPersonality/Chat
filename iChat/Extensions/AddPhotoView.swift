//
//  AddPhotoView.swift
//  iChat
//
//  Created by Данил Дубов on 23.09.2021.
//

import UIKit
import SnapKit

class AddPhotoView: UIView {
    var circleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "avatar")
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.layer.borderWidth = Constants.circleImageViewBorderWidth
        return imageView
    }()

    let plusButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "plus"), for: .normal)
        button.tintColor = .buttonDark()
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configurate()
    }

    private func configurate() {
        addSubview(circleImageView)
        addSubview(plusButton)

        circleImageView.snp.makeConstraints { make in
            make.top.left.equalToSuperview()
            make.height.width.equalTo(Constants.circleImageViewImageSize)
        }

        plusButton.snp.makeConstraints { make in
            make.left.equalTo(circleImageView.snp.right).offset(Constants.offsetBetweenCircleImageAndPlusButton)
            make.height.width.equalTo(Constants.plusButtonImageSize)
            make.centerY.equalToSuperview()
        }

        self.snp.makeConstraints { make in
            make.bottom.equalTo(circleImageView.snp.bottom)
            make.right.equalTo(plusButton.snp.right)
        }
    }

    override func layoutSubviews() {
        circleImageView.layer.masksToBounds = true
        circleImageView.layer.cornerRadius = Constants.circleImageViewCornerRadius
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Constants

private enum Constants {
    static let circleImageViewCornerRadius: CGFloat = 50

    static let plusButtonImageSize: Int = 30
    static let circleImageViewImageSize: Int = 100

    static let offsetBetweenCircleImageAndPlusButton: Int = 16

    static let circleImageViewBorderWidth: CGFloat = 1
}
