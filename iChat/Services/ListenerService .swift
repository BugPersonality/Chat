//
//  ListenerService .swift
//  iChat
//
//  Created by Данил Дубов on 28.09.2021.
//

import FirebaseAuth
import Firebase
import FirebaseFirestore

class ListenerService {
    static let shared = ListenerService()

    private let db = Firestore.firestore()

    private var usersRef: CollectionReference {
        return db.collection("users")
    }

    private var currUserId: String {
        return Auth.auth().currentUser!.uid
    }

    func usersObserve(users: [MUser], completion: @escaping (Result<[MUser], Error>) -> Void) -> ListenerRegistration {
        var users = users

        let usersListener = usersRef.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                completion(.failure(error!))
                return
            }

            snapshot.documentChanges.forEach { diff in
                guard let user = MUser(document: diff.document) else { return }
                switch diff.type {
                case .added:
                    guard !users.contains(user) else { return }
                    guard user.id != self.currUserId else { return }
                    users.append(user)
                case .modified:
                    guard let index = users.firstIndex(of: user) else { return }
                    users[index] = user
                case .removed:
                    guard let index = users.firstIndex(of: user) else { return }
                    users.remove(at: index)
                }
            }

            completion(.success(users))
        }

        return usersListener
    }

    func waitingChatsObserve(chats: [MChat], completion: @escaping (Result<[MChat], Error>) -> Void) -> ListenerRegistration {
        var chats = chats
        let chatsRef = db.collection(["users", currUserId, "waitingChats"].joined(separator: "/"))
        let chatsListener = chatsRef.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                completion(.failure(error!))
                return
            }

            snapshot.documentChanges.forEach { diff in
                guard let chat = MChat(document: diff.document) else { return }
                switch diff.type {
                case .added:
                    guard !chats.contains(chat) else { return }
                    chats.append(chat)
                case .modified:
                    guard let index = chats.firstIndex(of: chat) else { return }
                    chats[index] = chat
                case .removed:
                    guard let index = chats.firstIndex(of: chat) else { return }
                    chats.remove(at: index)
                }
            }
            completion(.success(chats))
        }
        return chatsListener
    }

    func activeChatsObserve(chats: [MChat], completion: @escaping (Result<[MChat], Error>) -> Void) -> ListenerRegistration {
        var chats = chats
        let chatsRef = db.collection(["users", currUserId, "activeChats"].joined(separator: "/"))
        let chatsListener = chatsRef.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                completion(.failure(error!))
                return
            }

            snapshot.documentChanges.forEach { diff in
                guard let chat = MChat(document: diff.document) else { return }
                switch diff.type {
                case .added:
                    guard !chats.contains(chat) else { return }
                    chats.append(chat)
                case .modified:
                    guard let index = chats.firstIndex(of: chat) else { return }
                    chats[index] = chat
                case .removed:
                    guard let index = chats.firstIndex(of: chat) else { return }
                    chats.remove(at: index)
                }
            }
            completion(.success(chats))
        }
        return chatsListener
    }

    func messagesObserve(chat: MChat, completion: @escaping (Result<MMessage, Error>) -> Void) -> ListenerRegistration {
        let ref = usersRef.document(currUserId).collection("activeChats").document(chat.friendId).collection("messages")
        let messageListener = ref.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                completion(.failure(error!))
                return
            }
            snapshot.documentChanges.forEach { diff in
                guard let message = MMessage(document: diff.document) else { return }
                switch diff.type {
                case .added:
                    completion(.success(message))
                case .modified:
                    break
                case .removed:
                    break
                }
            }
        }
        return messageListener
    }

}
