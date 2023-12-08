//
//  EventAuthorModel.swift
//  ARtivity
//
//  Created by Сергей Киселев on 07.12.2023.
//

import Foundation

struct EventAuthorModel {
    let authorId: String?
    var authorName: String?
}

extension EventAuthorModel: DatabaseRepresentation {
    var representation: [String: Any] {
        let rep: [String: Any] = [
            "authorId": authorId,
            "authorName": authorName
        ]

        return rep
    }
}
