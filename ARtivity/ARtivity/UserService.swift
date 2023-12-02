//
//  UserService.swift
//  ARtivity
//
//  Created by Сергей Киселев on 29.11.2023.
//

import Foundation
import Firebase

class UserService {

    static var currentUserProfile: UserProfile?

    static func observeUserProfile(_ uid: String, completion: @escaping ((_ userProfile: UserProfile?) -> Void)) {
        let userRef = Database.database().reference().child("users/\(uid)")

        userRef.observe(.value, with: { snapshot in
            var userProfile: UserProfile?

            if let dict = snapshot.value as? [String: Any],
                let name = dict["name"] as? String,
                let accountCompleted = dict["accountCompleted"] as? Bool,
                let email = dict["email"] as? String,
                let phone = dict["phone"] as? String,
                let photoURL = dict["photoURL"] as? String,
                let url = URL(string: photoURL) {

                userProfile = UserProfile(uid: snapshot.key, accountCompleted: accountCompleted, email: email, name: name, phone: phone)
            }

            completion(userProfile)
        })
    }

}

