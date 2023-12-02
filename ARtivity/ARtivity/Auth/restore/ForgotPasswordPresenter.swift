//
//  ForgotPasswordPresenter.swift
//  ARtivity
//
//  Created by Сергей Киселев on 02.12.2023.
//

import Foundation
import Firebase

protocol ForgotPasswordScreenView: class {
    func conclusion(title: String, message: String?)
}

protocol ForgotPasswordScreenPresenter {
    init(view: ForgotPassViewController, email: String)
    func checkForSending()
}

class ForgotPasswordPresenter: ForgotPasswordScreenPresenter {

    unowned let view: ForgotPasswordScreenView
    let email: String

    required init(view: ForgotPassViewController, email: String) {
        self.view = view
        self.email = email
    }

    func checkForSending() {
        Auth.auth().sendPasswordReset(withEmail: self.email) { [weak self] (error) in
            if error != nil {
                self?.view.conclusion(title: "Ошибка", message: CauseOfError.mailNotFound.localizedDescription)
                return
            }
//            self?.present(SuccessfullyRestored, animated: true, completion: nil)
            self?.view.conclusion(title: "", message: "На вашу почту отправление ссылка для изменения пароля")
        }
    }
}
