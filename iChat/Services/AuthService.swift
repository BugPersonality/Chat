//
//  AuthService.swift
//  iChat
//
//  Created by Данил Дубов on 27.09.2021.
//

import UIKit
import Firebase
import FirebaseAuth

class AuthService {
    static let shared = AuthService()

    private let auth = Auth.auth()

    func login(email: String?, password: String?, complition: @escaping (Result<User, Error>) -> Void) {
        guard let email = email, let password = password else {
            complition(.failure(AuthError.notFilled))
            return
        }

        auth.signIn(withEmail: email, password: password) { result, error in
            guard let result = result else {
                complition(.failure(error!))
                return
            }
            complition(.success(result.user))
        }
    }

    func register(email: String?, password: String?, confirmPassword: String?, complition: @escaping (Result<User, Error>) -> Void) {
        guard Validators.isFilled(email: email, password: password, confirmPassword: confirmPassword) else {
            complition(.failure(AuthError.notFilled))
            return
        }

        guard password!.lowercased() == confirmPassword!.lowercased() else {
            complition(.failure(AuthError.passwordNotMatched))
            return
        }

        guard Validators.isSimpleEmail(email!) else {
            complition(.failure(AuthError.invalidEmail))
            return
        }

        auth.createUser(withEmail: email!, password: password!) { result, error in
            guard let result = result else {
                complition(.failure(error!))
                return
            }
            complition(.success(result.user))
        }
    }
}
