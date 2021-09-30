//
//  ListViewController.swift
//  iChat
//
//  Created by Данил Дубов on 24.09.2021.
//

import UIKit
import SnapKit
import SwiftUI
import FirebaseFirestore

class ListViewController: UIViewController {
    enum Section: Int, CaseIterable {
        case waitingChats
        case avtiveChats

        func description() -> String {
            switch self {
            case .waitingChats:
                return "Waiting Chats"
            case .avtiveChats:
                return "Active Chats"
            }
        }
    }

    var activeChats: [MChat] = []
    var waitingChats: [MChat] = []

    private var waitingChatListener: ListenerRegistration?
    private var activeChatListener: ListenerRegistration?

    var collectionView: UICollectionView!

    var dataSourse: UICollectionViewDiffableDataSource<Section, MChat>?

    private let currentUser: MUser

    init(currentUser: MUser) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
        title = currentUser.username
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        waitingChatListener?.remove()
        activeChatListener?.remove()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()

        setupCollectionView()

        createDataSource()
        reloadData()

        waitingChatListener = ListenerService.shared.waitingChatsObserve(chats: waitingChats) { result in
            switch result {
            case .success(let chats):
                if !self.waitingChats.isEmpty, self.waitingChats.count <= chats.count {
                    let chatRequestVC = ChatRequestViewController(chat: chats.last!)
                    chatRequestVC.delegate = self
                    self.present(chatRequestVC, animated: true, completion: nil)
                }
                self.waitingChats = chats
                self.reloadData()
            case .failure(let error):
                self.showAlert(with: "Ошибка", and: error.localizedDescription)
            }
        }

        activeChatListener = ListenerService.shared.activeChatsObserve(chats: self.activeChats) { result in
            switch result {
            case .success(let chats):
                self.activeChats = chats
                self.reloadData()
            case .failure(let error):
                self.showAlert(with: "Ошибка", and: error.localizedDescription)
            }
        }
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

        collectionView.register(ActiveChatCell.self, forCellWithReuseIdentifier: ActiveChatCell.reuseId)
        collectionView.register(WaitingChatCell.self, forCellWithReuseIdentifier: WaitingChatCell.reuseId)

        collectionView.register(SectionHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: SectionHeader.reuseId)
    }

    private func reloadData() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, MChat>()
        snapshot.appendSections([.waitingChats, .avtiveChats])
        snapshot.appendItems(waitingChats, toSection: .waitingChats)
        snapshot.appendItems(activeChats, toSection: .avtiveChats)
        dataSourse?.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - DiffableDataSource

extension ListViewController {
    private func createDataSource() {
        self.dataSourse = UICollectionViewDiffableDataSource<Section, MChat>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, chat) -> UICollectionViewCell? in
            guard let section = Section(rawValue: indexPath.section) else {
                fatalError("Unknown section kind")
            }

            switch section {
            case .avtiveChats:
                return self.configure(collectionView: collectionView, cellType: ActiveChatCell.self,
                                      withValue: chat, for: indexPath)
            case .waitingChats:
                return self.configure(collectionView: collectionView, cellType: WaitingChatCell.self,
                                      withValue: chat, for: indexPath)
            }
        })

        dataSourse?.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                                      withReuseIdentifier: SectionHeader.reuseId,
                                                                                      for: indexPath) as? SectionHeader else {
                fatalError("Can't create new section header")
            }

            guard let section = Section(rawValue: indexPath.section) else { fatalError("Unknown section kind") }

            sectionHeader.configurate(text: section.description(),
                                      font: .laoSangamMN20(),
                                      textColor: UIColor(red: 146/255, green: 146/255, blue: 146/255, alpha: 1))
            return sectionHeader
        }
    }
}

// MARK: - Setup CompositionalLayout

extension ListViewController {
    private func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, _) -> NSCollectionLayoutSection? in
            // section -> groups -> items -> size
            guard let section = Section(rawValue: sectionIndex) else {
                fatalError("Unknown section kind")
            }

            switch section {
            case .avtiveChats:
                return self.createActiveChats()
            case .waitingChats:
                return self.createWaitingChats()
            }
        }

        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20
        layout.configuration = config

        return layout
    }

    private func createActiveChats() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(78))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 0, trailing: 20)
        section.interGroupSpacing = 8

        let sectionHeader = createSectionHeader()
        section.boundarySupplementaryItems = [sectionHeader]

        return section
    }

    private func createWaitingChats() -> NSCollectionLayoutSection {

        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(88), heightDimension: .absolute(88))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 0, trailing: 20)
        section.interGroupSpacing = 20
        section.orthogonalScrollingBehavior = .continuous

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

extension ListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
    }
}

// MARK: - UICollectionViewDelegate

extension ListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let chat = self.dataSourse?.itemIdentifier(for: indexPath) else { return }
        guard let section = Section(rawValue: indexPath.section) else { return }
        switch section {
        case .waitingChats:
            let chatReuestViewController = ChatRequestViewController(chat: chat)
            chatReuestViewController.delegate = self
            self.present(chatReuestViewController, animated: true, completion: nil)
        case .avtiveChats:
            let chatsViewController = ChatsViewController(user: currentUser, chat: chat)
            navigationController?.pushViewController(chatsViewController, animated: true)
        }
    }
}

extension ListViewController: WaitingChatsNavigation {
    func removeWaitingChat(chat: MChat) {
        FirestoreService.shared.deleteWaitingChat(chat: chat) { result in
            switch result {
            case .success:
                self.showAlert(with: "Успешно", and: "Чат с \(chat.friendUserName) был удален!")
            case .failure(let error):
                self.showAlert(with: "Ошибка", and: error.localizedDescription)
            }
        }
    }

    func changeToActive(chat: MChat) {
        FirestoreService.shared.changeToActive(chat: chat) { result in
            switch result {
            case .success:
                self.showAlert(with: "Успешно", and: "Приятного общения с \(chat.friendUserName)")
            case .failure(let error):
                self.showAlert(with: "Ошибка", and: error.localizedDescription)
            }
        }
    }
}

// MARK: - SwiftUI ListViewControllerProvider

struct ListViewControllerProvider: PreviewProvider {
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
