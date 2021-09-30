//
//  SetupProfileViewController.swift
//  iChat
//
//  Created by Данил Дубов on 23.09.2021.
//

import UIKit
import SnapKit
import SwiftUI
import FirebaseAuth

class SetupProfileViewController: UIViewController {
    let welcomeLabel = UILabel(text: "Set up Profile!", font: .avenir26())

    let fullNameLabel = UILabel(text: "Full name")
    let aboutMeLabel = UILabel(text: "About me")
    let sexLabel = UILabel(text: "Sex")

    let fillImageView = AddPhotoView()

    let fullNameTextField = OneLineTextField(font: .avenir20())
    let aboutMeTextField = OneLineTextField(font: .avenir20())

    let sexSegmentedControl = UISegmentedControl(first: "Male", second: "Femail")

    let goToChartsButton = UIButton(title: "Go to Charts!", titleColor: .white, backgroundColor: .buttonDark())

    private let currentUser: User

    init(currentUser: User) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configurateGoToChartButton()
        configurate()

        goToChartsButton.addTarget(self, action: #selector(goToChartsButtonTapped), for: .touchUpInside)
        fillImageView.plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
    }

    @objc private func goToChartsButtonTapped() {
        FirestoreService.shared.saveProfileWith(id: currentUser.uid,
                                                email: currentUser.email!,
                                                username: fullNameTextField.text,
                                                avatarImage: fillImageView.circleImageView.image,
                                                description: aboutMeTextField.text,
                                                sex: sexSegmentedControl.titleForSegment(at: sexSegmentedControl.selectedSegmentIndex)) { result in
            switch result {
            case .success(let user):
                self.showAlert(with: "Успешно", and: "Приятного общения!") {
                    let mainTabBar = MainTabBarController(currentUser: user)
                    mainTabBar.modalPresentationStyle = .fullScreen
                    self.present(mainTabBar, animated: true, completion: nil)
                }
            case .failure(let error):
                self.showAlert(with: "Ошибка!", and: error.localizedDescription)
            }
        }
    }

    @objc private func plusButtonTapped() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
}

// MARK: - Configurate

extension SetupProfileViewController {
    private func configurate() {
        let fullNameStackView = UIStackView(arrangedSubviews: [fullNameLabel, fullNameTextField],
                                            axis: .vertical,
                                            spacing: 0)

        let aboutMeStackView = UIStackView(arrangedSubviews: [aboutMeLabel, aboutMeTextField],
                                            axis: .vertical,
                                            spacing: 0)

        let sexStackView = UIStackView(arrangedSubviews: [sexLabel, sexSegmentedControl],
                                            axis: .vertical,
                                            spacing: 12)

        let stackView = UIStackView(arrangedSubviews: [fullNameStackView,
                                                       aboutMeStackView,
                                                       sexStackView,
                                                       goToChartsButton],
                                    axis: .vertical,
                                    spacing: 40)

        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        fillImageView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(welcomeLabel)
        view.addSubview(fillImageView)
        view.addSubview(stackView)

        welcomeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(160)
            make.centerX.equalToSuperview()
        }

        fillImageView.snp.makeConstraints { make in
            make.top.equalTo(welcomeLabel.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
        }

        stackView.snp.makeConstraints { make in
            make.top.equalTo(fillImageView.snp.bottom).offset(40)
            make.left.right.equalToSuperview().inset(40)
        }
    }

    private func configurateGoToChartButton() {
        goToChartsButton.snp.makeConstraints { make in
            make.height.equalTo(60)
        }
    }

}

// MARK: - UIImagePickerControllerDelegate

extension SetupProfileViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        fillImageView.circleImageView.image = image
    }
}

// MARK: - End Editing

extension SetupProfileViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

// MARK: - SwiftUI SetupProfileViewControllerProvider

struct SetupProfileViewControllerProvider: PreviewProvider {
    static var previews: some View {
        Group {
            ContainerView().edgesIgnoringSafeArea(.all)
        }
    }

    struct ContainerView: UIViewControllerRepresentable {
        let setupProfileVC = SetupProfileViewController(currentUser: Auth.auth().currentUser!)

        func makeUIViewController(context: Context) -> SetupProfileViewController {
            return setupProfileVC
        }

        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {  }
    }
}
