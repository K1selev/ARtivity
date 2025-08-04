//
//  CLLocationCoordinate2D+Bearing.swift
//  ARtivity
//
//  Created by Сергей Киселев on 10.07.2025.
//

import CoreLocation
import Foundation

extension CLLocationCoordinate2D {
    func bearing(to destination: CLLocationCoordinate2D) -> Double {
        let lat1 = self.latitude.radians
        let lon1 = self.longitude.radians
        let lat2 = destination.latitude.radians
        let lon2 = destination.longitude.radians

        let deltaLon = lon2 - lon1
        let y = sin(deltaLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(deltaLon)
        let initialBearing = atan2(y, x)

        // Преобразуем из радиан в градусы и нормализуем
        return (initialBearing.degrees + 360).truncatingRemainder(dividingBy: 360)
    }
}

private extension Double {
    var radians: Double { return self * .pi / 180 }
    var degrees: Double { return self * 180 / .pi }
}
