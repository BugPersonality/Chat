//
//  MMessage.swift
//  iChat
//
//  Created by Данил Дубов on 28.09.2021.
//

import UIKit
import FirebaseFirestore
import MessageKit

struct ImageItem: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}

struct MMessage: Hashable, MessageType {
    var sender: SenderType
    let content: String
    let sentDate: Date
    let id: String?

    var messageId: String {
        return id ?? UUID().uuidString
    }

    var kind: MessageKind {
        if let image = image {
            let mediaItem = ImageItem(url: nil, image: nil, placeholderImage: image, size: image.size)
            return .photo(mediaItem)
        } else {
            return .text(content)
        }
    }

    var image: UIImage! = nil
    var downloadUrl: URL! = nil

    var representation: [String: Any] {
        var rep: [String: Any] = [
            "senderId": sender.senderId,
            "senderUsername": sender.displayName,
            "sentDate": sentDate
        ]
        if let url = downloadUrl {
            rep["url"] = url.absoluteString
        } else {
            rep["content"] = content
        }
        return rep
    }

    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard let sentData = data["sentDate"] as? Timestamp else { return nil }
        guard let senderUsername = data["senderUsername"] as? String else { return nil }
        guard let senderId = data["senderId"] as? String else { return nil }

        self.id = document.documentID
        self.sentDate = sentData.dateValue()
        sender = Sender(senderId: senderId, displayName: senderUsername)

        if let content = data["content"] as? String {
            self.content = content
            self.downloadUrl = nil
        } else if let urlString = data["url"] as? String, let url = URL(string: urlString) {
            self.downloadUrl = url
            self.content = ""
        } else {
            return nil
        }
    }

    init(user: MUser, content: String) {
        self.content = content
        sender = Sender(senderId: user.id, displayName: user.username)
        sentDate = Date()
        id = nil
    }

    init(user: MUser, image: UIImage) {
        sender = Sender(senderId: user.id, displayName: user.username)
        self.image = image
        self.content = ""
        self.sentDate = Date()
        id = nil
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(messageId)
    }

    static func == (lhs: MMessage, rhs: MMessage) -> Bool {
        return lhs.messageId == rhs.messageId
    }
}

extension MMessage: Comparable {
    static func < (lhs: MMessage, rhs: MMessage) -> Bool {
        return lhs.sentDate < rhs.sentDate
    }
}
