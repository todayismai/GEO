//
//  AddOrderView.swift
//  Hw2_NgocMai
//
//  Created by MAY 08 on 21/9/26.
//


import SwiftUI
import MapKit

struct AddOrderView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedRestaurantIndex = 0
    @State private var customerName = ""
    @State private var deliveryAddress = ""
    @State private var latString = "10.762622"
    @State private var lonString = "106.660172"
    
    let sampleRestaurants: [Restaurant]
    var onAdd: (Order) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Chọn quán ăn") {
                    Picker("Quán ăn", selection: $selectedRestaurantIndex) {
                        ForEach(0..<sampleRestaurants.count, id: \.self) { i in
                            Text(sampleRestaurants[i].name)
                        }
                    }
                }
                
                Section("Thông tin người nhận") {
                    TextField("Tên khách hàng", text: $customerName)
                    TextField("Địa chỉ giao hàng", text: $deliveryAddress)
                }
                
                Section("Tọa độ giao hàng (Giao diện mẫu)") {
                    HStack {
                        Text("Vĩ độ (Lat):")
                        Spacer()
                        TextField("Lat", text: $latString)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Kinh độ (Lon):")
                        Spacer()
                        TextField("Lon", text: $lonString)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
            .navigationTitle("Thêm đơn hàng mới")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Hủy") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Lưu") {
                        if let lat = Double(latString), let lon = Double(lonString),
                           !customerName.isEmpty {
                            let newOrder = Order(
                                restaurant: sampleRestaurants[selectedRestaurantIndex],
                                customerName: customerName,
                                deliveryAddress: deliveryAddress,
                                latitude: lat,
                                longitude: lon
                            )
                            onAdd(newOrder)
                            dismiss()
                        }
                    }
                    .disabled(customerName.isEmpty || deliveryAddress.isEmpty)
                }
            }
        }
    }
}