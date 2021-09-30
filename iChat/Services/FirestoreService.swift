//
//  FirestoreService.swift
//  iChat
//
//  Created by Данил Дубов on 27.09.2021.
//

import Firebase
import FirebaseFirestore
import UIKit

class FirestoreService {
    static let shared = FirestoreService()

    let db = Firestore.firestore()

    private var usersRef: CollectionReference {
        return db.collection("users")
    }

    private var waitingChatsRef: CollectionReference {
        return db.collection(["users", currentUser.id, "waitingChats"].joined(separator: "/"))
    }

    private var activeChatsRef: CollectionReference {
        return db.collection(["users", currentUser.id, "activeChats"].joined(separator: "/"))
    }

    var currentUser: MUser!

    func saveProfileWith(id: String,
                         email: String,
                         username: String?,
                         avatarImage: UIImage?,
                         description: String?,
                         sex: String?,
                         complition: @escaping (Result<MUser, Error>) -> Void) {
        guard Validators.isFilled(username: username, description: description, sex: sex) else {
            complition(.failure(UserError.notFilled))
            return
        }

        var mUser = MUser(username: username!,
                          avatarStringURL: "not exist",
                          id: id,
                          email: email,
                          description: description!,
                          sex: sex!)

        StorageService.shared.upload(photo: avatarImage!) { result in
            switch result {
            case .success(let url):
                mUser.avatarStringURL = url.absoluteString
                self.usersRef.document(mUser.id).setData(mUser.representation) { error in
                    if let error = error {
                        complition(.failure(error))
                    } else {
                        complition(.success(mUser))
                    }
                }
            case .failure(let error):
                complition(.failure(error))
            }
        }
    }

    func getUserData(user: User, complition: @escaping (Result<MUser, Error>) -> Void) {
        let docRef = usersRef.document(user.uid)
        docRef.getDocument { document, _ in
            if let document = document, document.exists {
                guard let mUser = MUser(document: document) else {
                    complition(.failure(UserError.cannotUnwrapToMUser))
                    return
                }
                self.currentUser = mUser
                complition(.success(mUser))
            } else {
                complition(.failure(UserError.cannotGetUserInfo))
            }
        }
    }

    func createWaitingChat(message: String, reciver: MUser, complition: @escaping (Result<Void, Error>) -> Void) {
        let reference = db.collection(["users", reciver.id, "waitingChats"].joined(separator: "/"))
        let messageRef = reference.document(self.currentUser.id).collection("messages")

        let message = MMessage(user: currentUser, content: message)

        let chat = MChat(friendUserName: currentUser.username,
                         friendAvatarStringUrl: currentUser.avatarStringURL,
                         lastMessageContent: message.content,
                         friendId: currentUser.id)

        reference.document(currentUser.id).setData(chat.representation) { error in
            if let error = error {
                complition(.failure(error))
                return
            }
            messageRef.addDocument(data: message.representation) { error in
                if let error = error {
                    complition(.failure(error))
                    return
                }
                complition(.success(Void()))
            }
        }
    }

    func deleteWaitingChat(chat: MChat, complition: @escaping (Result<Void, Error>) -> Void) {
        waitingChatsRef.document(chat.friendId).delete { error in
            if let error = error {
                complition(.failure(error))
                return
            }
            self.deleteMessages(chat: chat, complition: complition)
        }
    }

    func deleteMessages(chat: MChat, complition: @escaping (Result<Void, Error>) -> Void) {
        let reference = waitingChatsRef.document(chat.friendId).collection("messages")
        getWaitingChatMessage(chat: chat) { result in
            switch result {
            case .success(let messages):
                for message in messages {
                    guard let documentId = message.id else { return }
                    let messageRef = reference.document(documentId)
                    messageRef.delete { error in
                        if let error = error {
                            complition(.failure(error))
                            return
                        }
                        complition(.success(Void()))
                    }
                }
            case .failure(let error):
                complition(.failure(error))
            }
        }
    }

    func getWaitingChatMessage(chat: MChat, complition: @escaping (Result<[MMessage], Error>) -> Void) {
        let reference = waitingChatsRef.document(chat.friendId).collection("messages")
        var messages: [MMessage] = []
        reference.getDocuments { querySnapshot, error in
            if let error = error {
                complition(.failure(error))
                return
            }
            for document in querySnapshot!.documents {
                guard let message = MMessage(document: document) else { return }
                messages.append(message)
            }
            complition(.success(messages))
        }
    }

    func changeToActive(chat: MChat, complition: @escaping (Result<Void, Error>) -> Void) {
        self.getWaitingChatMessage(chat: chat) { result in
            switch result {
            case .success(let messages):
                self.deleteWaitingChat(chat: chat) { result in
                    switch result {
                    case .success:
                        self.createActiveChat(chat: chat, messages: messages) { result in
                            switch result {
                            case .success:
                                complition(.success(Void()))
                            case .failure(let error):
                                complition(.failure(error))
                            }
                        }
                    case .failure(let error):
                        complition(.failure(error))
                    }
                }
            case .failure(let error):
                complition(.failure(error))
            }
        }
    }

    func createActiveChat(chat: MChat, messages: [MMessage], complition: @escaping (Result<Void, Error>) -> Void) {
        let messageRef = activeChatsRef.document(chat.friendId).collection("messages")
        activeChatsRef.document(chat.friendId).setData(chat.representation) { error in
            if let error = error {
                complition(.failure(error))
                return
            }
            for message in messages {
                messageRef.addDocument(data: message.representation) { error in
                    if let error = error {
                        complition(.failure(error))
                        return
                    }
                    complition(.success(Void()))
                }
            }
        }
    }

    func sendMessage(chat: MChat, message: MMessage, complition: @escaping (Result<Void, Error>) -> Void) {
        let friendRef = usersRef.document(chat.friendId).collection("activeChats").document(currentUser.id)
        let friendMessageRef = friendRef.collection("messages")
        let myMessageRef = usersRef.document(currentUser.id).collection("activeChats").document(chat.friendId).collection("messages")

        let chatForFriend = MChat(friendUserName: currentUser.username,
                                  friendAvatarStringUrl: currentUser.avatarStringURL,
                                  lastMessageContent: currentUser.id,
                                  friendId: message.content)

        friendRef.setData(chatForFriend.representation) { error in
            if let error = error {
                complition(.failure(error))
                return
            }
            friendMessageRef.addDocument(data: message.representation) { error in
                if let error = error {
                    complition(.failure(error))
                    return
                }
                myMessageRef.addDocument(data: message.representation) { error in
                    if let error = error {
                        complition(.failure(error))
                        return
                    }
                    complition(.success(Void()))
                }
            }
        }
    }

}
