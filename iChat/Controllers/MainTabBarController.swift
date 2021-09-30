//
//  MainTabBarController.swift
//  iChat
//
//  Created by Данил Дубов on 24.09.2021.
//

import UIKit
import FirebaseAuth

class MainTabBarController: UITabBarController {
    private let currentUser: MUser

    init(currentUser: MUser = MUser(username: "", avatarStringURL: "", id: "", email: "", description: "", sex: "")) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let listViewController = ListViewController(currentUser: currentUser)
        let peopleViewController = PeopleViewController(currentUser: currentUser)

        let boldConfigurationForImage = UIImage.SymbolConfiguration(weight: .medium)
        let peopleImage = UIImage(systemName: "person.2", withConfiguration: boldConfigurationForImage)!
        let convImage = UIImage(systemName: "bubble.left.and.bubble.right", withConfiguration: boldConfigurationForImage)!

        tabBar.tintColor = #colorLiteral(red: 0.5568627451, green: 0.3529411765, blue: 0.968627451, alpha: 1)

        viewControllers = [
            generateNavigationController(rootViewController: peopleViewController, title: "People", image: peopleImage),
            generateNavigationController(rootViewController: listViewController, title: "Conversation", image: convImage)
        ]
    }

    private func generateNavigationController(rootViewController: UIViewController,
                                              title: String,
                                              image: UIImage) -> UIViewController {
        let navigationVC = UINavigationController(rootViewController: rootViewController)
        navigationVC.tabBarItem.title = title
        navigationVC.tabBarItem.image = image
        return navigationVC
    }
}
