//
//  Location.swift
//  Lab2_NgocMai
//
//  Created by MAY 08 on 21/9/26.
//


import Foundation
import CoreLocation

class Location: Identifiable {
    let id = UUID()
    var name: String
    var latitude: Double
    var longitude: Double
    
    // Thuộc tính phụ trợ lấy CLLocationCoordinate2D cho MapKit
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    // Initializer
    init(name: String, latitude: Double, longitude: Double) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        print("📍 Location initialized: \(name)")
    }
    
    // Deinitializer
    deinit {
        print("🗑️ Location deinitialized: \(name)")
    }
}