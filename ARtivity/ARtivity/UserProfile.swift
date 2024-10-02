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
    var isMaker: Bool

    init(uid: String, accountCompleted: Bool, email: String, name: String, phone: String, isMaker: Bool) {
        self.uid = uid
        self.accountCompleted = accountCompleted
        self.email = email
        self.name = name
        self.phone = phone
        self.isMaker = isMaker
    }
}
