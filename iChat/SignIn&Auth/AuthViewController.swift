//
//  ViewController.swift
//  iChat
//
//  Created by Данил Дубов on 22.09.2021.
//

import UIKit
import SnapKit
import SwiftUI

class AuthViewController: UIViewController {

    let logoImageView = UIImageView(image: UIImage(named: "Logo"), contentMode: .scaleAspectFit)

    let googleLabel = UILabel(text: "Get started with")
    let emailLabel = UILabel(text: "Or sign up with")
    let alreadyOnBoardLabel = UILabel(text: "Already onboard?")

    let emailButton = UIButton(title: "Email", titleColor: .white, backgroundColor: .buttonDark())
    let loginButton = UIButton(title: "Login", titleColor: .buttonRed(), backgroundColor: .white, isShadow: true)
    let googleButton = UIButton(title: "Google", titleColor: .black, backgroundColor: .white, isShadow: true)

    let signUpVC = SignUpViewController()
    let loginVC = LoginViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        signUpVC.delegate = self
        loginVC.delegate = self

        configurate()

        emailButton.addTarget(self, action: #selector(emailButtonTapped), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
    }

    @objc private func emailButtonTapped() {
        print(#function)
        present(signUpVC, animated: true, completion: nil)
    }

    @objc private func loginButtonTapped() {
        print(#function)
        present(loginVC, animated: true, completion: nil)
    }
}

// MARK: - Configuration

extension AuthViewController {
    private func configurate() {
        let googleView = ButtonFormView(label: googleLabel, button: googleButton)
        let emailView = ButtonFormView(label: emailLabel, button: emailButton)
        let loginView = ButtonFormView(label: alreadyOnBoardLabel, button: loginButton)

        let stackView = UIStackView(arrangedSubviews: [googleView, emailView, loginView],
                                    axis: .vertical,
                                    spacing: 40)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoImageView)

        logoImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(160)
            make.centerX.equalToSuperview()
        }

        stackView.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(160)
            make.left.right.equalToSuperview().inset(40)
        }
    }
}

extension AuthViewController: AuthNavigationDelegate {
    func toLoginVc() {
        present(loginVC, animated: true, completion: nil)
    }

    func toSighUpVC() {
        present(signUpVC, animated: true, completion: nil)
    }
}

// MARK: - SwiftUI AuthViewController

struct AuthViewControllerProvider: PreviewProvider {
    static var previews: some View {
        Group {
            ContainerView().edgesIgnoringSafeArea(.all)
        }
    }

    struct ContainerView: UIViewControllerRepresentable {
        let authVC = AuthViewController()

        func makeUIViewController(context: Context) -> AuthViewController {
            return authVC
        }

        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {  }
    }
}
