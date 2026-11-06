//
//  ContentView.swift
//  Week3
//
//  Created by MAY 03 on 5/10/26.
//Ngoc Mai

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.pink.opacity(0.025)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        HomeHeaderView()
                        NavigationLink(destination: MapView()) {
                            HStack(spacing: 8) {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundColor(.pink.opacity(0.5))
                                
                                Text("Giao đến: Quận 3, Thành phố Hồ Chí Minh")
                                    .font(.custom("Georgia", size: 13))
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.gray)
                            }
                            .padding(10)
                            .background(Color.pink.opacity(0.05))
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                        SearchBarView()
                        BannerView()
                        CategoryRowView()
                        ProductCardView()
                        // ... các view khác
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
