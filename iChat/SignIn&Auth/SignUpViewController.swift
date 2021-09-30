//
//  SignUpViewController.swift
//  iChat
//
//  Created by Данил Дубов on 23.09.2021.
//

import UIKit
import SnapKit
import SwiftUI

class SignUpViewController: UIViewController {

    let welcomeLabel = UILabel(text: "Good to see you", font: .avenir26())

    let emailLabel = UILabel(text: "Email")
    let passwordLabel = UILabel(text: "Password")
    let confirmLabel = UILabel(text: "Confirm password")
    let alreadyOnBoardLabel = UILabel(text: "Already onboard?")

    let emailTextField = OneLineTextField(font: .avenir20())
    let passwordTextField = OneLineTextField(font: .avenir20())
    let confirmPasswordTextField = OneLineTextField(font: .avenir20())

    let signUpButton = UIButton(title: "Sign Up", titleColor: .white, backgroundColor: .buttonDark())

    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.buttonRed(), for: .normal)
        button.titleLabel?.font = .avenir20()
        return button
    }()

    weak var delegate: AuthNavigationDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configurate()
        signUpButtonConstraints()

        signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
    }

    @objc private func signUpButtonTapped() {
        AuthService.shared.register(email: emailTextField.text,
                                    password: passwordTextField.text,
                                    confirmPassword: confirmPasswordTextField.text) { result in
            switch result {
            case .success(let user):
                self.showAlert(with: "Успешно", and: "Вы зарегестрированы!") {
                    self.present(SetupProfileViewController(currentUser: user), animated: true, completion: nil)
                }
            case .failure(let error):
                self.showAlert(with: "Ошибка", and: error.localizedDescription)
            }
        }
        print(#function)
    }

    @objc private func loginButtonTapped() {
        print(#function)
        self.dismiss(animated: true) {
            self.delegate?.toLoginVc()
        }
    }

}

// MARK: - Configuration

extension SignUpViewController {
    private func configurate() {
        let emailStackView = UIStackView(arrangedSubviews: [emailLabel, emailTextField],
                                         axis: .vertical,
                                         spacing: 0)

        let passwordStackView = UIStackView(arrangedSubviews: [passwordLabel, passwordTextField],
                                            axis: .vertical,
                                            spacing: 0)

        let confirmPasswordStackView = UIStackView(arrangedSubviews: [confirmLabel, confirmPasswordTextField],
                                                   axis: .vertical,
                                                   spacing: 0)

        let stackView = UIStackView(arrangedSubviews: [emailStackView,
                                                       passwordStackView,
                                                       confirmPasswordStackView,
                                                       signUpButton],
                                    axis: .vertical,
                                    spacing: 40)

        let bottomStackView = UIStackView(arrangedSubviews: [alreadyOnBoardLabel, loginButton],
                                          axis: .horizontal,
                                          spacing: 0)

        bottomStackView.alignment = .firstBaseline

        stackView.translatesAutoresizingMaskIntoConstraints = false
        bottomStackView.translatesAutoresizingMaskIntoConstraints = false
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(welcomeLabel)
        view.addSubview(stackView)
        view.addSubview(bottomStackView)

        welcomeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(160)
            make.centerX.equalToSuperview()
        }

        stackView.snp.makeConstraints { make in
            make.top.equalTo(welcomeLabel.snp.bottom).offset(160)
            make.left.right.equalToSuperview().inset(40)
        }

        bottomStackView.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom).offset(60)
            make.left.right.equalToSuperview().inset(40)
        }
    }

    private func signUpButtonConstraints() {
        signUpButton.snp.makeConstraints { make in
            make.height.equalTo(60)
        }
    }
}

// MARK: - End Editing

extension SignUpViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

// MARK: - SwiftUI SignUpViewControllerProvider

struct SignUpViewControllerProvider: PreviewProvider {
    static var previews: some View {
        Group {
            ContainerView().edgesIgnoringSafeArea(.all)
        }
    }

    struct ContainerView: UIViewControllerRepresentable {
        let signUpVC = SignUpViewController()

        func makeUIViewController(context: Context) -> SignUpViewController {
            return signUpVC
        }

        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {  }
    }
}

extension UIViewController {
    func showAlert(with title: String, and message: String, complition: @escaping () -> Void = { }) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { _ in
            complition()
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
