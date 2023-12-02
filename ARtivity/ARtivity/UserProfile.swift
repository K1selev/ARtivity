//
//  UserProfile.swift
//  ARtivity
//
//  Created by Сергей Киселев on 29.11.2023.
//

import Foundation

class UserProfile {
    var uid: String
    var accountCompleted: Bool
    var email: String
    var name: String
    var phone: String
    var photoURL: URL?

    init(uid: String, accountCompleted: Bool, email: String, name: String, phone: String) {
        self.uid = uid
        self.accountCompleted = accountCompleted
        self.email = email
        self.name = name
        self.phone = phone
    }
}
