//
//  Validators.swift
//  iChat
//
//  Created by Данил Дубов on 27.09.2021.
//

import Foundation

class Validators {
    static func isFilled(email: String?, password: String?, confirmPassword: String?) -> Bool {
        guard let email = email, let password = password, let confirmPassword = confirmPassword else {
            return false
        }
        guard !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            return false
        }
        return true
    }

    static func isFilled(username: String?, description: String?, sex: String?) -> Bool {
        guard let username = username, let description = description, let sex = sex else {
            return false
        }
        guard !username.isEmpty, !description.isEmpty, !sex.isEmpty else {
            return false
        }
        return true
    }

    static func isSimpleEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return check(text: email, regEx: emailRegEx)
    }

    private static func check(text: String, regEx: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", regEx)
        return predicate.evaluate(with: text)
    }

}
