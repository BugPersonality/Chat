//
//  UserCell.swift
//  iChat
//
//  Created by Данил Дубов on 26.09.2021.
//

import UIKit
import SnapKit
import SDWebImage

class UserCell: UICollectionViewCell, SelfConfigurentCell {

    static var reuseId: String = "UserCell"

    let userImageView = UIImageView()
    let userName = UILabel(text: "text", font: .laoSangamMN20())
    let containerView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white

        setupConstraints()

        self.layer.shadowColor = UIColor(red: 189/255, green: 189/255, blue: 189/255, alpha: 1).cgColor
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
    }

    func configure<U>(with value: U) where U: Hashable {
        guard let user: MUser = value as? MUser else { return }
        userName.text = user.username
        guard let url = URL(string: user.avatarStringURL) else { return }
        userImageView.sd_setImage(with: url, completed: nil)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.containerView.layer.cornerRadius = 4
        self.containerView.clipsToBounds = true
    }

    override func prepareForReuse() {
        userImageView.image = nil
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - setupConstraints

extension UserCell {
    private func setupConstraints() {
        addSubview(containerView)
        containerView.addSubview(userImageView)
        containerView.addSubview(userName)

        userImageView.translatesAutoresizingMaskIntoConstraints = false
        userName.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false

        containerView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        userImageView.snp.makeConstraints { make in
            make.right.left.top.equalToSuperview()
            make.bottom.equalTo(userName.snp.top)
        }

        userName.snp.makeConstraints { make in
            make.left.right.equalTo(containerView).inset(8)
            make.bottom.equalTo(containerView)
        }
    }
}
