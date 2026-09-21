//
//  Place.swift
//  Lab2_NgocMai
//
//  Created by MAY 08 on 21/9/26.
//


import Foundation

class Place: Identifiable {
    let id = UUID()
    var name: String
    var latitude: Double
    var longitude: Double
    
    init(name: String, latitude: Double, longitude: Double) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
}
