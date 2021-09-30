//
//  StorageService.swift
//  iChat
//
//  Created by Данил Дубов on 27.09.2021.
//

import UIKit
import FirebaseAuth
import FirebaseStorage

class StorageService {
    static let shared = StorageService()

    let storageRef = Storage.storage().reference()

    private var avatarRef: StorageReference {
        return storageRef.child("avatars")
    }

    private var currentUserId: String {
        return Auth.auth().currentUser!.uid
    }

    private var chatsRef: StorageReference {
        return storageRef.child("chats")
    }

    func upload(photo: UIImage, complition: @escaping (Result<URL, Error>) -> Void) {
        guard let scaledImage = photo.scaledToSafeUploadSize, let imagaData = scaledImage.jpegData(compressionQuality: 0.4)  else { return }

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        avatarRef.child(currentUserId).putData(imagaData, metadata: metadata) { (metadata, error) in
            guard metadata != nil else {
                complition(.failure(error!))
                return
            }

            self.avatarRef.child(self.currentUserId).downloadURL { (url, error) in
                guard let downloadUrl = url else {
                    complition(.failure(error!))
                    return
                }
                complition(.success(downloadUrl))
            }
        }
    }

    func uploadImageMessage(photo: UIImage, to chat: MChat, complition: @escaping (Result<URL, Error>) -> Void) {
        guard let scaledImage = photo.scaledToSafeUploadSize, let imagaData = scaledImage.jpegData(compressionQuality: 0.4)  else { return }

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        let imageName: String = [UUID().uuidString, String(Date().timeIntervalSince1970)].joined()
        let uid: String = Auth.auth().currentUser!.uid
        let chatName = [chat.friendUserName, uid].joined()
        self.chatsRef.child(imageName).putData(imagaData, metadata: metadata) { metadata, error in
            guard metadata != nil else {
                complition(.failure(error!))
                return
            }
            self.chatsRef.child(chatName).child(imageName).downloadURL { url, error in
                guard let downloadUrl = url else {
                    complition(.failure(error!))
                    return
                }
                complition(.success(downloadUrl))
            }
        }
    }

    func downloadImage(url: URL, complition: @escaping (Result<UIImage?, Error>) -> Void) {
        let ref = Storage.storage().reference(forURL: url.absoluteString)
        let megaByte: Int64 = Int64(1 * 1024 * 1024)
        ref.getData(maxSize: megaByte) { data, error in
            guard let imagedata = data else {
                complition(.failure(error!))
                return
            }
            complition(.success(UIImage(data: imagedata)))
        }
    }

}
