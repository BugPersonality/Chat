//
//  ActiveChatCell.swift
//  iChat
//
//  Created by Данил Дубов on 25.09.2021.
//

import UIKit
import SnapKit
import SwiftUI

class ActiveChatCell: UICollectionViewCell, SelfConfigurentCell {
    static var reuseId: String = "ActiveChatCell"

    let friendImageView = UIImageView()
    let friendName = UILabel(text: "User Name", font: .laoSangamMN20())
    let lastMessage = UILabel(text: "How are you", font: .laoSangamMN18())
    let gradientView = GradientView(from: .topTrailing,
                                    to: .bottomLeading,
                                    startColor: UIColor(red: 201/255, green: 161/255, blue: 240/255, alpha: 1),
                                    endColor: UIColor(red: 122/255, green: 178/255, blue: 235/255, alpha: 1 ))

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .white
        self.layer.cornerRadius = 4
        self.clipsToBounds = true

        setupConstraints()
    }

    func configure<U>(with value: U) where U: Hashable {
        guard let chat: MChat = value as? MChat else { return }
        friendImageView.sd_setImage(with: URL(string: chat.friendAvatarStringUrl), completed: nil)
        friendName.text = chat.friendUserName
        lastMessage.text = chat.lastMessageContent
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - SetupConstraints

extension ActiveChatCell {
    private func setupConstraints() {
        contentView.addSubview(friendImageView)
        contentView.addSubview(friendName)
        contentView.addSubview(lastMessage)
        contentView.addSubview(gradientView)

        friendImageView.translatesAutoresizingMaskIntoConstraints = false
        friendName.translatesAutoresizingMaskIntoConstraints = false
        lastMessage.translatesAutoresizingMaskIntoConstraints = false
        gradientView.translatesAutoresizingMaskIntoConstraints = false

        friendImageView.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
            make.height.width.equalTo(78)
        }

        gradientView.snp.makeConstraints { make in
            make.right.centerY.equalToSuperview()
            make.width.equalTo(16)
            make.height.equalTo(78)
        }

        friendName.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.equalTo(friendImageView.snp.right).offset(16)
            make.right.equalTo(gradientView.snp.left).offset(16)
        }

        lastMessage.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-14)
            make.left.equalTo(friendImageView.snp.right).offset(16)
            make.right.equalTo(gradientView.snp.left).offset(16)
        }
    }
}

// MARK: - SwiftUI ActiveChatCellProvider

struct ActiveChatCellProvider: PreviewProvider {
    static var previews: some View {
        Group {
            ContainerView().previewDevice("iPhone 11").edgesIgnoringSafeArea(.all)
        }
    }

    struct ContainerView: UIViewControllerRepresentable {
        let tapBarVC = MainTabBarController()

        func makeUIViewController(context: Context) -> MainTabBarController {
            return tapBarVC
        }

        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {  }
    }
}
