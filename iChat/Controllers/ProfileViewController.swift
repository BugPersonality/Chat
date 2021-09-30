//
//  ProfileViewController.swift
//  iChat
//
//  Created by Данил Дубов on 26.09.2021.
//

import UIKit
import SwiftUI
import SnapKit
import SDWebImage

class ProfileViewController: UIViewController {

    let conteinerView = UIView()

    let imageView = UIImageView(image: UIImage(named: "human1"), contentMode: .scaleAspectFill)

    let nameLabel = UILabel(text: "Dim Ass", font: .systemFont(ofSize: 20, weight: .light))

    let aboutLabel = UILabel(text: "Do you want spend your time with me?", font: .systemFont(ofSize: 16, weight: .light))

    let myTextField = InsertableTextField()

    private let user: MUser

    init(user: MUser) {
        self.user = user
        self.nameLabel.text = user.username
        self.aboutLabel.text = user.description
        self.imageView.sd_setImage(with: URL(string: user.avatarStringURL), completed: nil)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        customizeElements()
        setupConstraints()
    }

    private func customizeElements() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        conteinerView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        aboutLabel.translatesAutoresizingMaskIntoConstraints = false
        myTextField.translatesAutoresizingMaskIntoConstraints = false

        aboutLabel.numberOfLines = 0

        conteinerView.backgroundColor = .mainWhite()
        conteinerView.layer.cornerRadius = 30

        if let button = myTextField.rightView as? UIButton {
            button.addTarget(self, action: #selector(sentMessage), for: .touchUpInside)
        }
    }

    @objc private func sentMessage() {
        guard let message = myTextField.text, !message.isEmpty else { return }
        self.dismiss(animated: true) {
            FirestoreService.shared.createWaitingChat(message: message, reciver: self.user) { result in
                switch result {
                case .success:
                    UIApplication.getTopViewController()?.showAlert(with: "Успех!", and: "Сообщение, для \(self.user.username) отправлено!")
                case .failure(let error):
                    UIApplication.getTopViewController()?.showAlert(with: "Ошибка", and: error.localizedDescription)
                }
            }
        }
    }

}

// MARK: - Setup Constraints

extension ProfileViewController {
    private func setupConstraints() {
        view.addSubview(imageView)
        view.addSubview(conteinerView)

        conteinerView.addSubview(nameLabel)
        conteinerView.addSubview(aboutLabel)
        conteinerView.addSubview(myTextField)

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

        myTextField.snp.makeConstraints { make in
            make.top.equalTo(aboutLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(48)
        }
    }
}

// MARK: - End Editing

extension ProfileViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

// MARK: - SwiftUI ProfileViewControllerProvider

struct ProfileViewControllerProvider: PreviewProvider {
    static var previews: some View {
        Group {
            ContainerView().previewDevice("iPhone 11").edgesIgnoringSafeArea(.all)
        }
    }

    struct ContainerView: UIViewControllerRepresentable {
        let profileVC = ProfileViewController(user: MUser(username: "", avatarStringURL: "", id: "", email: "", description: "", sex: ""))

        func makeUIViewController(context: Context) -> ProfileViewController {
            return profileVC
        }

        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {  }
    }
}
