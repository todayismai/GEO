//
//  CategoryRowView.swift
//  Week3
//
//  Created by MAY 03 on 5/10/26.
//Ngoc Mai

import SwiftUI

struct CategoryRowView: View {
    let categories = [
        ("Cá cảnh", "1"),
        ("Cây thủy sinh", "2"),
        ("Phụ kiện bể", "3"),
        ("Bể cá", "4"),
        ("Thiết bị lọc", "5"),
        ("Thức ăn", "6"),
        ("Thuốc", "7"),
        ("Tép cảnh", "8"),
        ("Khuyến mãi", "9"),
        ("Tư vấn", "10")
    ]

    // Định nghĩa 2 hàng (mỗi hàng 5 cột)
    let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(categories, id: \.0) { category in
                VStack(spacing: 6) {
                    Image(category.1)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .background(Color.yellow.opacity(0.2))
                        .clipShape(Circle())
                    
                    Text(category.0)
                        .font(.custom("Georgia", size: 10))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                }
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    CategoryRowView()
}
