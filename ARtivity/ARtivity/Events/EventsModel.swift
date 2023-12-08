//
//  EventsModel.swift
//  ARtivity
//
//  Created by Сергей Киселев on 07.12.2023.
//

import Foundation

struct EventsModel {
    var id: String?
    var eventId: String?
    var eventDistance: Int?
    var eventImage: String?
    var eventName: String?
    var eventPoint: Int?
    var eventRating: Double?
    var eventTime: Int?
    var eventTimestamp: Date?
    var eventAuthor: EventAuthorModel?
}

extension EventsModel: DatabaseRepresentation {
    var representation: [String: Any] {
        let rep: [String: Any] = [
            "eventId": eventId,
            "eventDistance": eventDistance,
            "eventImage": eventImage,
            "eventName": eventName,
            "eventPoint": eventPoint,
            "eventRating": eventRating,
            "eventTime": eventTime,
            "eventAuthor": eventAuthor?.representation,
            "eventTimestamp": eventTimestamp?.timeIntervalSince1970
        ]
        return rep
    }
    
    static func parse(_ key: String, _ data: [String: Any]) -> EventsModel? {

        if let eventAuthor = data["eventAuthor"] as? [String: Any],
           let authorId = eventAuthor["authorId"] as? String,
           let authorName = eventAuthor["authorName"] as? String,
           let eventId = data["eventId"] as? String,
           let eventDistance = data["eventDistance"] as? Int,
           let eventImage = data["eventImage"] as? String,
           let eventName = data["eventName"] as? String,
           let eventPoint = data["eventPoint"] as? Int,
           let eventRating = data["eventRating"] as? Double,
           let eventTime = data["eventTime"] as? Int,
           let eventTimestamp = data["eventTimestamp"] as? Double
        {
            
            let eventAuthor = EventAuthorModel(authorId: authorId, authorName: authorName)
            let crDate = Date(timeIntervalSince1970: eventTimestamp)
            
            return EventsModel(id: key,
                               eventId: eventId,
                               eventDistance: eventDistance,
                               eventImage: eventImage,
                               eventName: eventName,
                               eventPoint: eventPoint,
                               eventRating: eventRating,
                               eventTime: eventTime,
                               eventTimestamp: crDate,
                               eventAuthor: eventAuthor)
        }
        print("DEBUG ERROR")
        return nil
    }
}

