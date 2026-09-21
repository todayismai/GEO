//
//  MapService.swift
//  Hw2_NgocMai
//
//  Created by MAY 08 on 21/9/26.
//


import Foundation
import MapKit

class MapService {
    static let shared = MapService()
    private init() {}
    
    // Tính đường đi, khoảng cách (km) và thời gian (phút) giữa 2 tọa độ
    func getRoute(from source: CLLocationCoordinate2D,
                  to destination: CLLocationCoordinate2D,
                  completion: @escaping (MKRoute?, Double, TimeInterval) -> Void) {
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: source))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            guard let route = response?.routes.first, error == nil else {
                completion(nil, 0, 0)
                return
            }
            let distanceKm = route.distance / 1000.0 // Chuyển từ mét sang km
            let timeMinutes = route.expectedTravelTime / 60.0 // Chuyển từ giây sang phút
            
            completion(route, distanceKm, timeMinutes)
        }
    }
}