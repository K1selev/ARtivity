//
//  DatabaseManager.swift
//  ARtivity
//
//  Created by Сергей Киселев on 08.12.2023.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager {
    private let database = Database.database().reference()
    public static let shared = DatabaseManager()
    private var postsSearch = [EventsModel]()
}
extension DatabaseManager {

    public func getAllPosts(completion: @escaping (Result<[EventsModel], Error>) -> Void) {
        database.child("events").observeSingleEvent(of: .value, with: { snapshot in

            let lastPost = self.postsSearch.last
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                    let data = childSnapshot.value as? [String: Any],
                    let post = EventsModel.parse(childSnapshot.key, data),
                   childSnapshot.key != lastPost?.eventId {

                    self.postsSearch.insert(post, at: 0)
                }
            }

//            guard let value = post as? [Post] else {
//                completion(.failure(DatabaseError.failedToFetch))
//                return
//            }

            completion(.success(self.postsSearch))
        })
    }

    public enum DatabaseError: Error {
        case failedToFetch

        public var localizedDescription: String {
            switch self {
            case .failedToFetch:
                return "This means blah failed"
            }
        }
    }
}
