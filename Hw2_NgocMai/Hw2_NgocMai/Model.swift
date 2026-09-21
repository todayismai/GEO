//
//  Model.swift
//  Hw2_NgocMai
//
//  Created by MAY 08 on 21/9/26.
//

import Foundation
import CoreLocation
import Combine

// Class Quán ăn
class Restaurant: Identifiable {
    let id: UUID
    var name: String
    var address: String
    var latitude: Double
    var longitude: Double
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(name: String, address: String, latitude: Double, longitude: Double) {
        self.id = UUID()
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
    }
}

// Class Đơn hàng
class Order: Identifiable, ObservableObject {
    let id: UUID
    var restaurant: Restaurant
    var customerName: String
    var deliveryAddress: String
    var latitude: Double
    var longitude: Double
    @Published var status: String // "Chưa giao", "Đang giao", "Đã giao"
    
    // Lưu khoảng cách và thời gian tính toán từ MapKit
    @Published var distanceText: String = "Đang tính..."
    @Published var timeText: String = ""
    
    var customerCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(restaurant: Restaurant, customerName: String, deliveryAddress: String, latitude: Double, longitude: Double, status: String = "Chưa giao") {
        self.id = UUID()
        self.restaurant = restaurant
        self.customerName = customerName
        self.deliveryAddress = deliveryAddress
        self.latitude = latitude
        self.longitude = longitude
        self.status = status
    }
}
