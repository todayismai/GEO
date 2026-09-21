//
//  ContentView.swift
//  Lab2_NgocMai
//
//  Created by MAY 08 on 21/9/26.
//


import SwiftUI
import MapKit

enum ViewMode {
    case list
    case map
}

struct ContentView: View {
    @State private var searchText: String = ""
    @State private var viewMode: ViewMode = .list
    
    // Tọa độ mặc định (HCMIU)
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 10.87788, longitude: 106.80157),
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )
    )
    
    
    @State private var locations: [Location] = [
        Location(name: "HCMIU", latitude: 10.87788, longitude: 106.80157),
        Location(name: "Home", latitude: 10.9500, longitude: 106.8200),
        Location(name: "Coffee Shop", latitude: 10.8752, longitude: 106.8012),
        Location(name: "Park", latitude: 10.8601, longitude: 106.7930)
    ]
    
    // Lọc danh sách địa điểm theo từ khóa
    var filteredLocations: [Location] {
        if searchText.isEmpty {
            return locations
        } else {
            return locations.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                
                // 1. Header
                VStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(.red)
                    
                    Text("My Places")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Hoang Thi Ngoc Mai")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.top, 8)
                
                // 2. Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search place...", text: $searchText)
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // 3. Nội dung hiển thị (List / Map)
                if viewMode == .list {
                    // Hiển thị dạng List
                    List {
                        ForEach(filteredLocations) { loc in
                            HStack(spacing: 12) {
                                placeIcon(for: loc.name)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(loc.name)
                                        .font(.headline)
                                    Text(String(format: "%.4f, %.4f", loc.latitude, loc.longitude))
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .contentShape(Rectangle()) // Giúp bấm vào toàn bộ hàng
                            .onTapGesture {
                                // Xử lý khi bấm vào địa điểm:
                                // 1. Cập nhật vị trí camera bản đồ tới địa điểm đó
                                withAnimation {
                                    cameraPosition = .region(
                                        MKCoordinateRegion(
                                            center: loc.coordinate,
                                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                        )
                                    )
                                    // 2. Tự động chuyển sang tab Bản đồ
                                    viewMode = .map
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                } else {
                    // Hiển thị dạng Map View
                    Map(position: $cameraPosition) {
                        ForEach(filteredLocations) { loc in
                            Annotation(loc.name, coordinate: loc.coordinate) {
                                VStack(spacing: 2) {
                                    Text(loc.name)
                                        .font(.caption2)
                                        .bold()
                                        .padding(4)
                                        .background(Color.white)
                                        .cornerRadius(6)
                                        .shadow(radius: 2)
                                    placeIcon(for: loc.name)
                                        .font(.title2)
                                }
                            }
                        }
                    }
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                // 4. Picker chuyển đổi List/Map[cite: 8]
                Picker("View Mode", selection: $viewMode) {
                    Text("List").tag(ViewMode.list)
                    Text("Map").tag(ViewMode.map)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // 5. Nút Add Place
                NavigationLink(destination: AddPlaceView(onSave: { newLocation in
                    locations.append(newLocation)
                })) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add Place")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // 6. Tổng số địa điểm
                Text("Total places: \(locations.count)")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom, 6)
            }
        }
        .preferredColorScheme(.light)
    }
    
    // Icon tùy chỉnh theo loại địa điểm
    @ViewBuilder
    func placeIcon(for name: String) -> some View {
        let lowerName = name.lowercased()
        
        if lowerName.contains("hcmiu") {
            Image(systemName: "graduationcap.fill")
                .foregroundColor(.blue)
        } else if lowerName.contains("home") {
            Image(systemName: "house.fill")
                .foregroundColor(.orange)
        } else if lowerName.contains("coffee") {
            Image(systemName: "cup.and.saucer.fill")
                .foregroundColor(.brown)
        } else if lowerName.contains("park") {
            Image(systemName: "tree.fill")
                .foregroundColor(.green)
        } else {
            Image(systemName: "mappin.circle.fill")
                .foregroundColor(.red)
        }
    }
}

#Preview {
    ContentView()
}
