//
//  AddPlaceView.swift
//  Lab2_NgocMai
//
//  Created by MAY 08 on 21/9/26.
//


import SwiftUI
import MapKit

struct AddPlaceView: View {
    var onSave: (Location) -> Void
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String = ""
    @State private var selectedCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 10.8506, longitude: 106.7719) // Mặc định HCMUTE
    
    // Vùng bản đồ ban đầu
    @State private var cameraPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 10.8506, longitude: 106.7719),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Bản đồ chọn vị trí
                MapReader { proxy in
                    Map(position: $cameraPosition) {
                        Annotation(name.isEmpty ? "Vị trí chọn" : name, coordinate: selectedCoordinate) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.title)
                                .foregroundColor(.red)
                        }
                    }
                    .onTapGesture { screenCoord in
                        if let pinCoord = proxy.convert(screenCoord, from: .local) {
                            selectedCoordinate = pinCoord
                        }
                    }
                }
                .frame(height: 300)
                
                // Form nhập thông tin
                Form {
                    Section(header: Text("Thông tin địa điểm")) {
                        TextField("Tên địa điểm (ví dụ: Thư viện)", text: $name)
                        
                        HStack {
                            Text("Vĩ độ (Lat):")
                            Spacer()
                            Text(String(format: "%.4f", selectedCoordinate.latitude))
                                .foregroundColor(.gray)
                        }
                        
                        HStack {
                            Text("Kinh độ (Long):")
                            Spacer()
                            Text(String(format: "%.4f", selectedCoordinate.longitude))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Section {
                        Text("💡 Mẹo: Nhấn vào vị trí bất kỳ trên bản đồ ở trên để chọn tọa độ.")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Thêm địa điểm")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Hủy") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Lưu") {
                        if !name.isEmpty {
                            let newLocation = Location(
                                name: name,
                                latitude: selectedCoordinate.latitude,
                                longitude: selectedCoordinate.longitude
                            )
                            onSave(newLocation)
                            dismiss()
                        }
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .preferredColorScheme(.light)
    }
}
