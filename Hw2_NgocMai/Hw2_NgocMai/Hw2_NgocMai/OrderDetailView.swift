//
//  OrderDetailView.swift
//  Hw2_NgocMai
//
//  Created by MAY 08 on 21/9/26.
//


import SwiftUI
import MapKit

struct OrderDetailView: View {
    @ObservedObject var order: Order
    
    @State private var route: MKRoute?
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    var body: some View {
        VStack(spacing: 0) {
            // Bản đồ hiển thị vị trí Quán, Khách và Đường đi
            Map(position: $cameraPosition) {
                // Marker Quán ăn
                Annotation(order.restaurant.name, coordinate: order.restaurant.coordinate) {
                    VStack(spacing: 2) {
                        Image(systemName: "fork.knife.circle.fill")
                            .font(.title)
                            .foregroundColor(.red)
                            .background(Circle().fill(.white))
                    }
                }
                
                // Marker Khách hàng
                Annotation("Địa chỉ giao", coordinate: order.customerCoordinate) {
                    VStack(spacing: 2) {
                        Image(systemName: "house.circle.fill")
                            .font(.title)
                            .foregroundColor(.blue)
                            .background(Circle().fill(.white))
                    }
                }
                
                // Vẽ tuyến đường đi
                if let route = route {
                    MapPolyline(route)
                        .stroke(.blue, lineWidth: 5)
                }
            }
            .frame(maxHeight: .infinity)
            
            // Khối thông tin chi tiết bên dưới
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    Image(systemName: "fork.knife")
                        .foregroundColor(.red)
                    VStack(alignment: .leading) {
                        Text(order.restaurant.name)
                            .font(.headline)
                        Text(order.restaurant.address)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                
                Divider()
                
                HStack(spacing: 12) {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(.blue)
                    VStack(alignment: .leading) {
                        Text("Giao cho: \(order.customerName)")
                            .font(.headline)
                        Text(order.deliveryAddress)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                
                Divider()
                
                HStack {
                    Image(systemName: "car.fill")
                        .foregroundColor(.gray)
                    Text("Khoảng cách: \(order.distanceText) (\(order.timeText))")
                        .font(.subheadline)
                        .bold()
                }
                
                // Cập nhật trạng thái đơn hàng
                HStack {
                    Text("Trạng thái:")
                        .font(.subheadline)
                    Spacer()
                    Picker("Trạng thái", selection: $order.status) {
                        Text("Chưa giao").tag("Chưa giao")
                        Text("Đang giao").tag("Đang giao")
                        Text("Đã giao").tag("Đã giao")
                    }
                    .pickerStyle(.menu)
                }
            }
            .padding()
            .background(Color(.systemBackground))
        }
        .navigationTitle("Chi tiết đơn hàng")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            calculateRoute()
        }
    }
    
    private func calculateRoute() {
        MapService.shared.getRoute(from: order.restaurant.coordinate, to: order.customerCoordinate) { calculatedRoute, distanceKm, timeMinutes in
            DispatchQueue.main.async {
                self.route = calculatedRoute
                self.order.distanceText = String(format: "%.1f km", distanceKm)
                self.order.timeText = String(format: "~%.0f phút", timeMinutes)
            }
        }
    }
}