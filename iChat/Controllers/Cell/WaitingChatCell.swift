//
//  WaitingChatCell.swift
//  iChat
//
//  Created by Данил Дубов on 25.09.2021.
//

import UIKit
import SnapKit

class WaitingChatCell: UICollectionViewCell, SelfConfigurentCell {

    static var reuseId: String = "WaitingChatCell"

    let friendImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.layer.cornerRadius = 4
        self.clipsToBounds = true

        setupConstrints()
    }

    private func setupConstrints() {
        contentView.addSubview(friendImageView)

        friendImageView.translatesAutoresizingMaskIntoConstraints = false

        friendImageView.snp.makeConstraints { make in
            make.top.bottom.left.right.equalToSuperview()
        }
    }

    func configure<U>(with value: U) where U: Hashable {
        guard let chat: MChat = value as? MChat else { return }
        friendImageView.sd_setImage(with: URL(string: chat.friendAvatarStringUrl), completed: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
