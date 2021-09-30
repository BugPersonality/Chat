//
//  MChat.swift
//  iChat
//
//  Created by Данил Дубов on 25.09.2021.
//

import UIKit
import FirebaseFirestore

struct MChat: Hashable, Decodable {
    var friendUserName: String
    var friendAvatarStringUrl: String
    var lastMessageContent: String
    var friendId: String

    var representation: [String: Any] {
        var rep = ["friendUserName": friendUserName]
        rep["friendAvatarStringUrl"] = friendAvatarStringUrl
        rep["lastMessage"] = lastMessageContent
        rep["friendId"] = friendId
        return rep
    }

    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard let friendUserName = data["friendUserName"] as? String,
              let friendAvatarStringUrl = data["friendAvatarStringUrl"] as? String,
              let lastMessage = data["lastMessage"] as? String,
              let friendId = data["friendId"] as? String else { return nil }

        self.friendUserName = friendUserName
        self.friendAvatarStringUrl = friendAvatarStringUrl
        self.lastMessageContent = lastMessage
        self.friendId = friendId
    }

    init(friendUserName: String, friendAvatarStringUrl: String, lastMessageContent: String, friendId: String) {
        self.friendUserName = friendUserName
        self.friendAvatarStringUrl = friendAvatarStringUrl
        self.lastMessageContent = lastMessageContent
        self.friendId = friendId
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(friendId)
    }

    static func == (lhs: MChat, rhs: MChat) -> Bool {
        return lhs.friendId == rhs.friendId
    }
}
