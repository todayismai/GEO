//
//  MapView.swift
//  Week3
//
//  Created by MAY 03 on 5/10/26.
//Ngoc Mai

import SwiftUI
import MapKit

struct MapView: View {
    // Tọa độ cửa hàng (Quận 1, TP.HCM)
    private let storeCoordinate = CLLocationCoordinate2D(latitude: 10.7769, longitude: 106.7009)
    // Tọa độ điểm giao hàng gần đó (Quận 3, TP.HCM)
    private let deliveryCoordinate = CLLocationCoordinate2D(latitude: 10.7872, longitude: 106.6918)

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 10.7820, longitude: 106.6960),
        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
    )
    
    @State private var routePolyline: MKPolyline?
    @State private var distanceText: String = "Đang tính..."

    var body: some View {
        ZStack(alignment: .bottom) {
            MapWithRoute(store: storeCoordinate, destination: deliveryCoordinate, polyline: $routePolyline)
                .ignoresSafeArea(edges: .top)
                .onAppear {
                    calculateRoute()
                }

            // Bảng thông tin cửa hàng & khoảng cách
            VStack(alignment: .leading, spacing: 6) {
                Text("Ngon Ká - Cửa hàng chính")
                    .font(.custom("Georgia-Bold", size: 16))
                
                Text("Giao đến: Quận 3, Thành phố Hồ Chí Minh")
                    .font(.custom("Georgia", size: 12))
                    .foregroundColor(.gray)

                Text("Quãng đường giao hàng: \(distanceText)")
                    .font(.custom("Georgia-Bold", size: 12))
                    .foregroundColor(.blue)

                Button(action: {
                    let mapItemStore = MKMapItem(placemark: MKPlacemark(coordinate: storeCoordinate))
                    let mapItemDelivery = MKMapItem(placemark: MKPlacemark(coordinate: deliveryCoordinate))
                    mapItemStore.name = "Ngon Ká"
                    mapItemDelivery.name = "Điểm giao hàng"
                    
                    MKMapItem.openMaps(
                        with: [mapItemStore, mapItemDelivery],
                        launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                    )
                }) {
                    Text("Giao hàng")
                        .font(.custom("Georgia-Bold", size: 12))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.pink.opacity(0.55))
                        .cornerRadius(8 )
                }
                .padding(.top, 4)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(radius: 5)
            .padding()
        }
    }

    // Hàm tính toán quãng đường và vẽ tuyến đường
    func calculateRoute() {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: storeCoordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: deliveryCoordinate))
        request.transportType = .automobile

        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            guard let route = response?.routes.first else { return }
            self.routePolyline = route.polyline
            
            let distanceInKm = route.distance / 1000
            self.distanceText = String(format: "%.1f km", distanceInKm)
        }
    }
}

// Helper kết nối MapKit UIKit (MKMapView) để vẽ polyline đường đi
struct MapWithRoute: UIViewRepresentable {
    let store: CLLocationCoordinate2D
    let destination: CLLocationCoordinate2D
    @Binding var polyline: MKPolyline?

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
        // Thêm pin cửa hàng
        let storeAnno = MKPointAnnotation()
        storeAnno.coordinate = store
        storeAnno.title = "Ngon Ká"
        mapView.addAnnotation(storeAnno)
        
        // Thêm pin điểm giao
        let deliveryAnno = MKPointAnnotation()
        deliveryAnno.coordinate = destination
        deliveryAnno.title = "Điểm giao hàng"
        mapView.addAnnotation(deliveryAnno)
        
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        if let polyline = polyline {
            uiView.removeOverlays(uiView.overlays)
            uiView.addOverlay(polyline)
            
            let rect = polyline.boundingMapRect
            uiView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 80, left: 50, bottom: 150, right: 50), animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let routePolyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: routePolyline)
                renderer.strokeColor = .systemBlue
                renderer.lineWidth = 4
                return renderer
            }
            return MKOverlayRenderer()
        }
    }
}

#Preview {
    MapView()
}
