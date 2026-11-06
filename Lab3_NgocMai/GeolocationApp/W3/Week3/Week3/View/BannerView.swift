//
//  BannerView.swift
//  Week3
//
//  Created by MAY 03 on 5/10/26.
//Ngoc Mai

import SwiftUI

struct BannerView: View {
    var body: some View {
        ZStack(alignment: .center) { // 1. ZStack căn giữa tuyệt đối
            // Hình nền "bn"
            Image("bn")
                .resizable()
                .scaledToFill()
            
            // Gradient: Làm tối đều xung quanh để chữ nổi bật hơn
            //LinearGradient(
                //colors: [Color.black.opacity(0.2), Color.clear],
                //startPoint: .center,
                //endPoint: .bottom // Gradient tỏa nhẹ xuống dưới
            //)
            
            // 2. Nội dung chính
            HStack(alignment: .center, spacing: 20) { // 3. HStack căn giữa
                // 4. Khối chữ căn giữa
                VStack(alignment: .center, spacing: 6) {
                    Text("ƯU ĐÃI THÁNG NÀY")
                        .font(.custom("Georgia-Bold", size: 11))
                        .foregroundColor(Color(red: 1.0, green: 0.45, blue: 0.69))
                    
                    Text("CÁ XINH XAY XE")
                        .font(.custom("Georgia-Bold", size: 20))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.7), radius: 1, x: 0, y: 1)
                    
                    Text("đưa cá iu đi khám phá muôn nơi ")
                        .font(.custom("Georgia", size: 12))
                        .foregroundColor(Color(red: 1.0, green: 0.45, blue: 0.69))                        .multilineTextAlignment(.center)
                        .shadow(color: .white.opacity(0.7), radius: 1, x: 0, y: 1)
                }
                
                // Nhãn Giảm đến 30% (đặt bên phải chữ, cân bằng với layout cũ)
                VStack(spacing: 2) {
                    Text("GIẢM CỰC CĂNG")
                        .font(.custom("Georgia", size: 10))
                        .foregroundColor(Color(red: 1.0, green: 0.45, blue: 0.69))
                    Text("99%")
                        .font(.custom("Georgia-Bold", size: 18))
                        .foregroundColor(Color(red: 1.0, green: 0.45, blue: 0.69))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.5))
                .cornerRadius(8)
            }
            .padding() // Padding chung cho HStack so với viền banner
        }
        .frame(height: 140)
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

#Preview {
    BannerView()
}

