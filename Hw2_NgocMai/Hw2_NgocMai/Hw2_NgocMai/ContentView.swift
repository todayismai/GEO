//
//  ContentView.swift
//  Hw2_NgocMai
//
//  Created by MAY 08 on 21/9/26.
//

import SwiftUI

struct ContentView: View {
    // Khởi tạo danh sách quán ăn mẫu
    let sampleRestaurants = [
        Restaurant(name: "Phở 24", address: "10 Nguyễn Văn Linh, Q.7", latitude: 10.7293, longitude: 106.7028),
        Restaurant(name: "Highlands Coffee", address: "72 Lê Lợi, Q.1", latitude: 10.7731, longitude: 106.7001),
        Restaurant(name: "Lotteria", address: "285 Cách Mạng Tháng 8, Q.10", latitude: 10.7788, longitude: 106.6782),
        Restaurant(name: "Pizza Hut", address: "1 Võ Văn Ngân, TP. Thủ Đức", latitude: 10.8506, longitude: 106.7719)
    ]
    
    // Danh sách đơn hàng mẫu khởi tạo
    @State private var orders: [Order] = []
    @State private var showAddSheet = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                Text("Đơn Hàng Cần Giao")
                    .font(.title2)
                    .bold()
                    .padding()
                
                // Danh sách các đơn hàng
                List {
                    ForEach(orders) { order in
                        NavigationLink(destination: OrderDetailView(order: order)) {
                            OrderRowView(order: order)
                        }
                    }
                }
                .listStyle(.plain)
                
                // Nút Thêm Đơn Hàng & Tổng Số Đơn
                VStack(spacing: 8) {
                    Button(action: { showAddSheet = true }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("Thêm đơn hàng")
                                .bold()
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    Text("Tổng số đơn hàng: \(orders.count)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
            }
            .sheet(isPresented: $showAddSheet) {
                AddOrderView(sampleRestaurants: sampleRestaurants) { newOrder in
                    orders.append(newOrder)
                    loadDistance(for: newOrder)
                }
            }
            .onAppear {
                if orders.isEmpty {
                    setupInitialOrders()
                }
            }
        }
    }
    
    // Khởi tạo 4 đơn hàng mặc định giống hình bài tập
    private func setupInitialOrders() {
        let initialList = [
            Order(restaurant: sampleRestaurants[0], customerName: "Wai", deliveryAddress: "12 Lê Văn Sỹ, Q.3", latitude: 10.7878, longitude: 106.6753, status: "Chưa giao"),
            Order(restaurant: sampleRestaurants[1], customerName: "todayismaii", deliveryAddress: "46 Điện Biên Phủ, Q.10", latitude: 10.7712, longitude: 106.6689, status: "Đang giao"),
            Order(restaurant: sampleRestaurants[2], customerName: "Ngọc Mai", deliveryAddress: "9 Âu Cơ, Q.11", latitude: 10.7671, longitude: 106.6501, status: "Chưa giao"),
            Order(restaurant: sampleRestaurants[3], customerName: "Nami_kawaii", deliveryAddress: "12 Hoàng Diệu 2, TP. Thủ Đức", latitude: 10.8542, longitude: 106.7780, status: "Đã giao")
        ]
        
        self.orders = initialList
        for order in initialList {
            loadDistance(for: order)
        }
    }
    
    // Gọi MapKit tính khoảng cách ngay khi load danh sách
    private func loadDistance(for order: Order) {
        MapService.shared.getRoute(from: order.restaurant.coordinate, to: order.customerCoordinate) { _, distanceKm, timeMinutes in
            DispatchQueue.main.async {
                order.distanceText = String(format: "%.1f km", distanceKm)
                order.timeText = String(format: "~%.0f phút", timeMinutes)
            }
        }
    }
}

// Component hiển thị mỗi dòng đơn hàng
struct OrderRowView: View {
    @ObservedObject var order: Order
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Icon đại diện theo tên quán
            restaurantIcon(for: order.restaurant.name)
                .font(.largeTitle)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(order.restaurant.name)
                    .font(.headline)
                Text(order.restaurant.address)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text("Giao cho: \(order.customerName)")
                    .font(.caption)
                    .foregroundColor(.primary)
                Text(order.deliveryAddress)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 12) {
                Text(order.distanceText)
                    .font(.subheadline)
                    .bold()
                
                // Badge Trạng thái màu sắc
                Text(order.status)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor(for: order.status))
                    .cornerRadius(10)
            }
        }
        .padding(.vertical, 4)
    }
    
    @ViewBuilder
    func restaurantIcon(for name: String) -> some View {
        let imageName: String = {
            if name.contains("Phở") {
                return "pho"
            } else if name.contains("Coffee") {
                return "coffee"
            } else if name.contains("Lotteria") {
                return "lotteria"
            } else if name.contains("Pizza") {
                return "pizza"
            } else {
                return "food_default"
            }
        }()
        
        Image(imageName)
            .resizable()
            .scaledToFill()
            .frame(width: 45, height: 45)
            .clipShape(Circle())
    }
    
    func statusColor(for status: String) -> Color {
        switch status {
        case "Đang giao": return .orange
        case "Đã giao": return .green
        default: return .blue
        }
    }
}

#Preview {
    ContentView()
}
