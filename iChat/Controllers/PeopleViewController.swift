//
//  PeopleViewController.swift
//  iChat
//
//  Created by Данил Дубов on 24.09.2021.
//

import UIKit
import SnapKit
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
class PeopleViewController: UIViewController {
    enum Section: Int, CaseIterable {
        case users

        func description(usersCount: Int) -> String {
            switch self {
            case .users:
                return "\(usersCount) people nearby"
            }
        }
    }

    var users: [MUser] = []

    private var usersListener: ListenerRegistration?

    var collectionView: UICollectionView!

    var dataSourse: UICollectionViewDiffableDataSource<Section, MUser>?

    private let currentUser: MUser

    init(currentUser: MUser) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
        title = currentUser.username
    }

    deinit {
        usersListener?.remove()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupSearchBar()

        setupCollectionView()

        createDataSource()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log Out",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(signOut))

        usersListener = ListenerService.shared.usersObserve(users: users) { result in
            switch result {
            case .success(let users):
                self.users = users
                self.reloadData(with: nil)
            case .failure(let error):
                self.showAlert(with: "Ошибка", and: error.localizedDescription)
            }
        }
    }

    @objc private func signOut() {
        let alertController = UIAlertController(title: nil, message: "Sign Put?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { _ in
            do {
                try Auth.auth().signOut()
                UIApplication.shared.keyWindow?.rootViewController = AuthViewController()
            } catch {
                print("Error sign out \(error.localizedDescription)")
            }
        }))
        present(alertController, animated: true, completion: nil)
    }

    private func setupSearchBar() {
        navigationController?.navigationBar.barTintColor = .mainWhite()
        navigationController?.navigationBar.shadowImage = UIImage()
        let searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController

        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false

        searchController.searchBar.delegate = self
    }

    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .mainWhite()

        view.addSubview(collectionView)

        collectionView.delegate = self

        collectionView.register(UserCell.self, forCellWithReuseIdentifier: UserCell.reuseId)

        collectionView.register(SectionHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: SectionHeader.reuseId)
    }

    private func reloadData(with searchText: String?) {
        let filtered = users.filter { user -> Bool in
            user.containst(filter: searchText)
        }

        var snapshot = NSDiffableDataSourceSnapshot<Section, MUser>()
        snapshot.appendSections([.users])
        snapshot.appendItems(filtered, toSection: .users)
        dataSourse?.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - DiffableDataSource

extension PeopleViewController {
    private func createDataSource() {
        self.dataSourse = UICollectionViewDiffableDataSource<Section, MUser>(collectionView: collectionView,
                                                                             cellProvider: { (collectionView, indexPath, user) -> UICollectionViewCell? in
            guard let section = Section(rawValue: indexPath.section) else {
                fatalError("Unknown section kind")
            }

            switch section {
            case .users:
                return self.configure(collectionView: collectionView, cellType: UserCell.self,
                                      withValue: user, for: indexPath)
            }
        })

        dataSourse?.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                                      withReuseIdentifier: SectionHeader.reuseId,
                                                                                      for: indexPath) as? SectionHeader else {
                fatalError("Can't create new section header")
            }

            guard let section = Section(rawValue: indexPath.section) else { fatalError("Unknown section kind") }

            let itemsCount = self.dataSourse?.snapshot().itemIdentifiers(inSection: .users).count
            sectionHeader.configurate(text: section.description(usersCount: itemsCount ?? 0),
                                      font: .laoSangamMN20(),
                                      textColor: .label)
            return sectionHeader
        }
    }
}

// MARK: - Setup CompositionalLayout

extension PeopleViewController {
    private func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, _) -> NSCollectionLayoutSection? in
            // section -> groups -> items -> size
            guard let section = Section(rawValue: sectionIndex) else {
                fatalError("Unknown section kind")
            }

            switch section {
            case .users:
                return self.createUsersSection()
            }
        }

        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20
        layout.configuration = config

        return layout
    }

    private func createUsersSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.5))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        group.interItemSpacing  = .fixed(15)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 15
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 15, bottom: 0, trailing: 15)

        let sectionHeader = createSectionHeader()
        section.boundarySupplementaryItems = [sectionHeader]

        return section
    }

    private func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let sectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(1))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: sectionHeaderSize,
                                                                        elementKind: UICollectionView.elementKindSectionHeader,
                                                                        alignment: .top)
        return sectionHeader
    }
}

// MARK: - UISearchBarDelegate

extension PeopleViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        reloadData(with: searchText)
    }
}

// MARK: - UICollectionViewDelegate

extension PeopleViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let user = self.dataSourse?.itemIdentifier(for: indexPath) else { return }
        let profileViewController = ProfileViewController(user: user)
        present(profileViewController, animated: true, completion: nil)
    }
}

// MARK: - SwiftUI PeopleViewControllerProvider

struct PeopleViewControllerProvider: PreviewProvider {
    static var previews: some View {
        Group {
            ContainerView().edgesIgnoringSafeArea(.all)
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
