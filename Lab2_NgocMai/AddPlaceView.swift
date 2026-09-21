//
//  AddPlaceView.swift
//  Lab2_NgocMai
//
//  Created by MAY 08 on 21/9/26.
//


import SwiftUI
import MapKit

struct AddPlaceView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var placeName: String = ""
    @State private var latitudeString: String = ""
    @State private var longitudeString: String = ""
    
    // Tìm kiếm vị trí
    @State private var searchQuery: String = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var isSearching: Bool = false
    
    // Vị trí camera bản đồ (Mặc định ở TP.HCM / HCMIU)
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 10.87788, longitude: 106.80157),
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )
    )
    
    // Tọa độ điểm ghim được chọn
    @State private var selectedCoordinate: CLLocationCoordinate2D? = nil
    
    var onSave: (Location) -> Void
    
    var body: some View {
        Form {
            // SECTION 1: BẢN ĐỒ TƯƠNG TÁC (Bấm vào bản đồ để chọn vị trí)
            Section(
                header: Text("Chạm lên bản đồ để chọn vị trí"),
                footer: Text("Mẹo: Phóng to/thu nhỏ bản đồ và nhấn vào vị trí bất kỳ để ghim tọa độ.")
            ) {
                MapReader { proxy in
                    Map(position: $cameraPosition) {
                        if let coord = selectedCoordinate {
                            Marker(placeName.isEmpty ? "Vị trí đã chọn" : placeName, coordinate: coord)
                        }
                    }
                    .frame(height: 250)
                    .cornerRadius(12)
                    .onTapGesture { screenCoord in
                        // Chuyển đổi tọa độ màn hình (Point) sang tọa độ địa lý (Lat/Lon)
                        if let pinCoordinate = proxy.convert(screenCoord, from: .local) {
                            updateSelectedCoordinate(pinCoordinate)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
            
            // SECTION 2: TÌM KIẾM ĐỊA ĐIỂM
            Section(header: Text("Hoặc Tìm kiếm địa điểm")) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Nhập tên địa điểm (VD: HCMUTE, Bitexco...)", text: $searchQuery)
                        .onChange(of: searchQuery) { oldValue, newValue in
                            searchLocation(query: newValue)
                        }
                    
                    if !searchQuery.isEmpty {
                        Button(action: {
                            searchQuery = ""
                            searchResults = []
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                // Danh sách gợi ý tìm kiếm
                if isSearching {
                    ProgressView("Đang tìm kiếm...")
                } else if !searchResults.isEmpty {
                    List(searchResults, id: \.self) { item in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.name ?? "Địa điểm không xác định")
                                .font(.body)
                                .fontWeight(.medium)
                            
                            let coord = item.getCoordinate()
                            Text(String(format: "Lat: %.4f, Lon: %.4f", coord.latitude, coord.longitude))
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectSearchResult(item: item)
                        }
                    }
                    .frame(maxHeight: 180)
                }
            }
            
            // SECTION 3: THÔNG TIN CHI TIẾT
            Section(header: Text("Thông tin địa điểm")) {
                TextField("Tên địa điểm (VD: Nhà sách, Quán cafe...)", text: $placeName)
                
                HStack {
                    Text("Latitude:")
                        .foregroundColor(.gray)
                    Spacer()
                    TextField("Vĩ độ", text: $latitudeString)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                }
                
                HStack {
                    Text("Longitude:")
                        .foregroundColor(.gray)
                    Spacer()
                    TextField("Kinh độ", text: $longitudeString)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                }
            }
            
            // SECTION 4: NÚT LƯU
            Section {
                Button(action: savePlace) {
                    HStack {
                        Spacer()
                        Text("Save Place")
                            .fontWeight(.bold)
                        Spacer()
                    }
                }
                .disabled(placeName.isEmpty || latitudeString.isEmpty || longitudeString.isEmpty)
            }
        }
        .navigationTitle("Add New Place")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // Cập nhật tọa độ khi người dùng CHẠM TRỰC TIẾP LÊN BẢN ĐỒ
    private func updateSelectedCoordinate(_ coord: CLLocationCoordinate2D) {
        selectedCoordinate = coord
        latitudeString = String(coord.latitude)
        longitudeString = String(coord.longitude)
    }
    
    // Hàm tìm kiếm địa điểm
    private func searchLocation(query: String) {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            searchResults = []
            return
        }
        
        isSearching = true
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            isSearching = false
            guard let response = response, error == nil else {
                return
            }
            searchResults = response.mapItems
        }
    }
    
    // Xử lý khi chọn từ danh sách TÌM KIẾM
    private func selectSearchResult(item: MKMapItem) {
        placeName = item.name ?? ""
        
        let coord = item.getCoordinate()
        updateSelectedCoordinate(coord)
        
        // Di chuyển camera bản đồ tới vị trí tìm kiếm
        withAnimation {
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: coord,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            )
        }
        
        searchResults = []
        searchQuery = ""
    }
    
    // Lưu địa điểm
    private func savePlace() {
        guard let lat = Double(latitudeString),
              let lon = Double(longitudeString) else { return }
        
        let newLocation = Location(name: placeName, latitude: lat, longitude: lon)
        onSave(newLocation)
        dismiss()
    }
}

// Extension hỗ trợ lấy tọa độ MKMapItem
extension MKMapItem {
    func getCoordinate() -> CLLocationCoordinate2D {
        return self.location.coordinate
    }
}

#Preview {
    NavigationStack {
        AddPlaceView { _ in }
    }
}
