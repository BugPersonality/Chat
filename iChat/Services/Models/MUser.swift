//
//  MUser.swift
//  iChat
//
//  Created by Данил Дубов on 25.09.2021.
//

import UIKit
import FirebaseFirestore

struct MUser: Hashable, Decodable {
    var username: String
    var avatarStringURL: String
    var id: String
    var email: String
    var description: String
    var sex: String

    init?(document: DocumentSnapshot) {
        guard let data = document.data() else { return nil }
        guard let username = data["username"] as? String else { return nil }
        guard let sex = data["sex"] as? String else { return nil }
        guard let avatarStringURL = data["avatarStringURL"] as? String else { return nil }
        guard let uid = data["uid"] as? String else { return nil }
        guard let email = data["email"] as? String else { return nil }
        guard let description = data["description"] as? String else { return nil }

        self.username = username
        self.sex = sex
        self.avatarStringURL = avatarStringURL
        self.id = uid
        self.email = email
        self.description = description
    }

    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard let username = data["username"] as? String else { return nil }
        guard let sex = data["sex"] as? String else { return nil }
        guard let avatarStringURL = data["avatarStringURL"] as? String else { return nil }
        guard let uid = data["uid"] as? String else { return nil }
        guard let email = data["email"] as? String else { return nil }
        guard let description = data["description"] as? String else { return nil }

        self.username = username
        self.sex = sex
        self.avatarStringURL = avatarStringURL
        self.id = uid
        self.email = email
        self.description = description
    }

    init(username: String, avatarStringURL: String, id: String, email: String, description: String, sex: String) {
        self.username = username
        self.sex = sex
        self.avatarStringURL = avatarStringURL
        self.id = id
        self.email = email
        self.description = description
    }

    var representation: [String: Any] {
        var rep = ["username": username]
        rep["sex"] = sex
        rep["avatarStringURL"] = avatarStringURL
        rep["uid"] = id
        rep["email"] = email
        rep["description"] = description
        return rep
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: MUser, rhs: MUser) -> Bool {
        return lhs.id == rhs.id
    }

    func containst(filter: String?) -> Bool {
        guard let filter = filter else { return true }
        if filter.isEmpty { return true }

        let lowercasedFilter = filter.lowercased()

        return username.lowercased().contains(lowercasedFilter)
    }
}
