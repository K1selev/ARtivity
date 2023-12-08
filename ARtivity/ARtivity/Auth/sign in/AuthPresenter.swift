//
//  AuthPresenter.swift
//  ARtivity
//
//  Created by Сергей Киселев on 29.11.2023.
//

import Foundation
import Firebase

protocol AuthScreenView: class {
    func processingResult(error: String?)
}

protocol AuthScreenPresenter {
    init(view: AuthScreenView, email: String?, password: String?)
    func dataProcessing()
}

class AuthPresenter: AuthScreenPresenter {
    unowned let view: AuthScreenView
    let password: String?
    let email: String?

    required init(view: AuthScreenView, email: String?, password: String?) {
        self.password = password
        self.email = email
        self.view = view
    }

    func dataProcessing() {
        guard let email = self.email, let password = self.password else {
            self.view.processingResult(error: CauseOfError.loginOrPassword.localizedDescription)
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (_, error) in
            if let error = error {
                self?.view.processingResult(error: CauseOfError.loginOrPassword.localizedDescription)
                print(error.localizedDescription)
                return
            }
            UserDefaults.standard.set(true, forKey: "isLogin")
            Auth.auth().addStateDidChangeListener { _, user in
                print("user!.uid: \(user!.uid)")
                UserService.observeUserProfile(user!.uid) { userProfile in
                    UserService.currentUserProfile = userProfile
                }
            }
            self?.view.processingResult(error: nil)
        }
    }
}

