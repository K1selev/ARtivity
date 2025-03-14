//
//  EventsModel.swift
//  ARtivity
//
//  Created by Сергей Киселев on 07.12.2023.
//

import Foundation

//struct EventsModel {
//    var id: String?
//    var eventId: String?
//    var eventDistance: Int?
//    var eventImage: String?
//    var eventName: String?
//    var eventPoint: Int?
//    var eventRating: Double?
//    var eventTime: Int?
//    var eventTimestamp: Date?
//    var eventAuthor: EventAuthorModel?
//}
//
//extension EventsModel: DatabaseRepresentation {
//    var representation: [String: Any] {
//        let rep: [String: Any] = [
//            "eventId": eventId,
//            "eventDistance": eventDistance,
//            "eventImage": eventImage,
//            "eventName": eventName,
//            "eventPoint": eventPoint,
//            "eventRating": eventRating,
//            "eventTime": eventTime,
//            "eventAuthor": eventAuthor?.representation,
//            "eventTimestamp": eventTimestamp?.timeIntervalSince1970
//        ]
//        return rep
//    }
//    
//    static func parse(_ key: String, _ data: [String: Any]) -> EventsModel? {
//
//        if let eventAuthor = data["eventAuthor"] as? [String: Any],
//           let authorId = eventAuthor["authorId"] as? String,
//           let authorName = eventAuthor["authorName"] as? String,
//           let eventId = data["eventId"] as? String,
//           let eventDistance = data["eventDistance"] as? Int,
//           let eventImage = data["eventImage"] as? String,
//           let eventName = data["eventName"] as? String,
//           let eventPoint = data["eventPoint"] as? Int,
//           let eventRating = data["eventRating"] as? Double,
//           let eventTime = data["eventTime"] as? Int,
//           let eventTimestamp = data["eventTimestamp"] as? Double
//        {
//            
//            let eventAuthor = EventAuthorModel(authorId: authorId, authorName: authorName)
//            let crDate = Date(timeIntervalSince1970: eventTimestamp)
//            
//            return EventsModel(id: key,
//                               eventId: eventId,
//                               eventDistance: eventDistance,
//                               eventImage: eventImage,
//                               eventName: eventName,
//                               eventPoint: eventPoint,
//                               eventRating: eventRating,
//                               eventTime: eventTime,
//                               eventTimestamp: crDate,
//                               eventAuthor: eventAuthor)
//        }
//        return nil
//    }
//}
//
//struct EventDetails {
//    var id: String?
//    var eventId: String?
//    var description: String?
//    var eventPoints: [String]?
//    var eventPhotos: [String]?
//    var eventCity: String?
//    var eventQuest: Bool?
//}
//
//extension EventDetails: DatabaseRepresentation {
//    var representation: [String: Any] {
//        let rep: [String: Any] = [
//            "eventId": eventId,
//            "description": description,
//            "eventPoints": eventPoints,
//            "eventPhotos": eventPhotos,
//            "eventCity": eventCity,
//            "eventQuest": eventQuest
//        ]
//        return rep
//    }
//    
//    static func parse(_ key: String, _ data: [String: Any]) -> EventDetails? {
//
//        if let eventId = data["eventId"] as? String,
//           let description = data["description"] as? String,
//           let eventPoints = data["eventPoints"] as? [String],
//           let eventPhotos = data["eventPhotos"] as? [String],
//           let eventCity = data["eventCity"] as? String,
//           let eventQuest = data["eventQuest"] as? Bool
//        {
//            
//            return EventDetails(id: key,
//                               eventId: eventId,
//                               description: description,
//                               eventPoints: eventPoints,
//                               eventPhotos: eventPhotos,
//                               eventCity: eventCity,
//                               eventQuest: eventQuest)
//        }
//        return nil
//    }
//}

struct PointDetail {
    var id: String?
    var address: String?
    var description: String?
    var isFirstPoint: Bool?
    var latitude: Double?
    var longitude: Double?
    var name: String?
    var photos: [String]?
    var urlNet: String?
}

extension PointDetail: DatabaseRepresentation {
    var representation: [String: Any] {
        let rep: [String: Any] = [
            "address": address,
            "description": description,
            "isFirstPoint": isFirstPoint,
            "latitude": latitude,
            "longitude": longitude,
            "name": name,
            "photos": photos,
            "urlNet": urlNet
        ]
        return rep
    }
    
    static func parse(_ key: String, _ data: [String: Any]) -> PointDetail? {

        if let address = data["address"] as? String,
           let description = data["description"] as? String,
           let isFirstPoint = data["isFirstPoint"] as? Bool,
           let latitude = data["latitude"] as? Double,
           let longitude = data["longitude"] as? Double,
           let name = data["name"] as? String,
           let photos = data["photos"] as? [String],
           let urlNet = data["urlNet"] as? String
        {
            
            return PointDetail(id: key,
                               address: address,
                               description: description,
                               isFirstPoint: isFirstPoint,
                               latitude: latitude,
                               longitude: longitude,
                               name: name,
                               photos: photos,
                               urlNet: urlNet)
        }
        return nil
    }
}



struct EventDetailsTest {
    var id: String?
    var eventId: String?
    var description: String?
    var eventPoints: [String]?
    var eventPhotos: [String]?
    var eventCity: String?
    var eventQuest: Bool?
    var eventQuestId: String?
    var eventDistance: Int?
    var eventImage: String?
    var eventName: String?
    var eventPointCount: Int?
    var eventRating: Double?
    var eventTime: Int?
    var eventTimestamp: Date?
    var eventAuthor: EventAuthorModel?
    var eventIsFree: Bool?
}

extension EventDetailsTest: DatabaseRepresentation {
    var representation: [String: Any] {
        let rep: [String: Any] = [
            "eventId": eventId,
            "description": description,
            "eventPoints": eventPoints,
            "eventPhotos": eventPhotos,
            "eventCity": eventCity,
            "eventQuest": eventQuest,
            "eventQuestId": eventQuestId,
            "eventDistance": eventDistance,
            "eventImage": eventImage,
            "eventName": eventName,
            "eventPointCount": eventPointCount,
            "eventRating": eventRating,
            "eventTime": eventTime,
            "eventAuthor": eventAuthor?.representation,
            "eventTimestamp": eventTimestamp?.timeIntervalSince1970,
            "eventIsFree": eventIsFree
        ]
        return rep
    }
    
    static func parse(_ key: String, _ data: [String: Any]) -> EventDetailsTest? {
        
        if let eventId = data["eventId"] as? String,
           let description = data["description"] as? String,
           let eventPoints = data["eventPoints"] as? [String],
           let eventPhotos = data["eventPhotos"] as? [String],
           let eventCity = data["eventCity"] as? String,
           let eventQuest = data["eventQuest"] as? Bool,
           let eventQuestId = data["eventQuestId"] as? String,
           let eventAuthor = data["eventAuthor"] as? [String: Any],
           let authorId = eventAuthor["authorId"] as? String,
           let authorName = eventAuthor["authorName"] as? String,
           let eventId = data["eventId"] as? String,
           let eventDistance = data["eventDistance"] as? Int,
           let eventImage = data["eventImage"] as? String,
           let eventName = data["eventName"] as? String,
           let eventPointCount = data["eventPointCount"] as? Int,
           let eventRating = data["eventRating"] as? Double,
           let eventTime = data["eventTime"] as? Int,
           let eventTimestamp = data["eventTimestamp"] as? Double,
           let eventIsFree = data["eventIsFree"] as? Bool
            
        {
            
            let eventAuthor = EventAuthorModel(authorId: authorId, authorName: authorName)
            let crDate = Date(timeIntervalSince1970: eventTimestamp)
            
            return EventDetailsTest(id: key,
                                    eventId: eventId,
                                    description: description,
                                    eventPoints: eventPoints,
                                    eventPhotos: eventPhotos,
                                    eventCity: eventCity,
                                    eventQuest: eventQuest,
                                    eventQuestId: eventQuestId,
                                    eventDistance: eventDistance,
                                    eventImage: eventImage,
                                    eventName: eventName,
                                    eventPointCount: eventPointCount,
                                    eventRating: eventRating,
                                    eventTime: eventTime,
                                    eventTimestamp: crDate,
                                    eventAuthor: eventAuthor,
                                    eventIsFree: eventIsFree)
        }
        return nil
    }
}

