//
//  StorageService.swift
//  ARtivity
//
//  Created by Сергей Киселев on 21.11.2024.
//


import UIKit
import Firebase
import FirebaseStorage

class StorageService {
    
    private let databaseReference = Database.database().reference()

    static let shared = StorageService()

    func uploadPostImages(_ images: [UIImage], imageCategory: String, completion: @escaping ((_ urls: [String]) -> Void)) {
        var imageUrls = [String]()
        let group = DispatchGroup()

        for image in images {
            group.enter()

            let timeStamp = Int(NSDate.timeIntervalSinceReferenceDate*1000)
            let storageRef = Storage.storage().reference().child("\(imageCategory)/\(timeStamp)")

            guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }

            let metaData = StorageMetadata()
            metaData.contentType = "image/jpeg"

            storageRef.putData(imageData, metadata: metaData) { metaData, error in
                if error == nil, metaData != nil {

                    storageRef.downloadURL { url, _ in
                        if let downloadUrl = url {
                            imageUrls.append("\(downloadUrl)")
                        }
                        group.leave()
                    }
                } else {
                    group.leave()
                }
            }
        }

        group.notify(queue: .main) {
            completion(imageUrls)
        }
    }
    
    func createNewPoint(data: PointDetail, completion: @escaping (_ success: Bool) -> Void) {
        let adRef = databaseReference.child("points").childByAutoId()
        adRef.setValue(data.representation) { (error, _) in
            if let error = error {
                completion(false)
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}
