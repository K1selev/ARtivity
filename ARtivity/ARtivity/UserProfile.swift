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
    var completedEvent: [String?]
    var userEvents: [String?]

    init(uid: String, accountCompleted: Bool, email: String, name: String, phone: String, isMaker: Bool, completedEvent: [String?], userEvents: [String?]) {
        self.uid = uid
        self.accountCompleted = accountCompleted
        self.email = email
        self.name = name
        self.phone = phone
        self.isMaker = isMaker
        self.completedEvent = completedEvent
        self.userEvents = userEvents
    }
}

//class UserProfile {
//    var uid: String
//    var accountCompleted: Bool
//    var email: String
//    var name: String
//    var phone: String
//    var isMaker: Bool
//    var completedEvent: String
//    var userEvents: String
