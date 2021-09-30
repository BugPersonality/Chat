//
//  ChatRequestViewController.swift
//  iChat
//
//  Created by Данил Дубов on 26.09.2021.
//

import UIKit
import SnapKit

class ChatRequestViewController: UIViewController {
    let conteinerView = UIView()
    let imageView = UIImageView(image: UIImage(named: "human2"), contentMode: .scaleAspectFill)
    let nameLabel = UILabel(text: "Dim Ass", font: .systemFont(ofSize: 20, weight: .light))
    let aboutLabel = UILabel(text: "Do you want spend your time with me?", font: .systemFont(ofSize: 16, weight: .light))
    let acceptButton = UIButton(title: "ACCEPT",
                                titleColor: .white,
                                backgroundColor: .black,
                                font: .laoSangamMN20(),
                                isShadow: false,
                                cornerRadius: 10)
    let denyButton = UIButton(title: "DENY",
                                titleColor: UIColor(red: 213/255, green: 51/255, blue: 51/255, alpha: 1),
                                backgroundColor: .mainWhite(),
                                font: .laoSangamMN20(),
                                isShadow: false,
                                cornerRadius: 10)

    private var chat: MChat

    weak var delegate: WaitingChatsNavigation?

    init(chat: MChat) {
        self.chat = chat
        nameLabel.text = chat.friendUserName
        imageView.sd_setImage(with: URL(string: chat.friendAvatarStringUrl), completed: nil)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .mainWhite()

        customizeElements()
        setupConstraints()

        denyButton.addTarget(self, action: #selector(denyButtonTapped), for: .touchUpInside)
        acceptButton.addTarget(self, action: #selector(acceptButtonTapped), for: .touchUpInside)
    }

    @objc private func denyButtonTapped() {
        self.dismiss(animated: true) {
            self.delegate?.removeWaitingChat(chat: self.chat)
        }
    }

    @objc private func acceptButtonTapped() {
        self.dismiss(animated: true) {
            self.delegate?.changeToActive(chat: self.chat)
        }
    }

    private func customizeElements() {
        conteinerView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        aboutLabel.translatesAutoresizingMaskIntoConstraints = false

        denyButton.layer.borderWidth = 1.2
        denyButton.layer.borderColor = UIColor(red: 213/255, green: 51/255, blue: 51/255, alpha: 1).cgColor

        conteinerView.backgroundColor = .mainWhite()
        conteinerView.layer.cornerRadius = 30
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.acceptButton.applyGradients(cornerRadius: 10)
    }
}

// MARK: - Setup Constraints

extension ChatRequestViewController {
    private func setupConstraints() {
        let buttonsStackView = createStackView(withFirstButton: acceptButton, withSecondButton: denyButton)

        view.addSubview(imageView)
        view.addSubview(conteinerView)

        conteinerView.addSubview(nameLabel)
        conteinerView.addSubview(aboutLabel)
        conteinerView.addSubview(buttonsStackView)

        conteinerView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(206)
        }

        imageView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(conteinerView.snp.top).offset(30)
        }

        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(35)
            make.left.right.equalToSuperview().inset(24)
        }

        aboutLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(24)
        }

        buttonsStackView.snp.makeConstraints { make in
            make.top.equalTo(aboutLabel.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(56)
        }
    }

    private func createStackView(withFirstButton button1: UIButton, withSecondButton button2: UIButton) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [button1, button2],
                                    axis: .horizontal,
                                    spacing: 7)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        return stackView
    }
}
