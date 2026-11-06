//
//  ProductCardView.swift
//  Week3
//
//  Created by MAY 03 on 5/10/26.
//Ngoc Mai

import SwiftUI

struct ProductCardView: View {
    let products = [
        ("Sứa thạch núng nính", "119.999đ", "sp1"),
        ("Sao em trang trí", "59.999đ", "sp2"),
        ("Khu cá sống", "555.999đ", "sp3")
    ]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(products, id: \.0) { product in
                VStack(alignment: .leading, spacing: 0) {
                    ZStack(alignment: .topTrailing) {
                        Image(product.2)
                            .resizable()
                            .scaledToFit() 
                            .frame(height: 80)
                            .frame(maxWidth: .infinity)
                            .background(Color(.systemGray6))
                        
                        Button(action: {}) {
                            Image(systemName: "heart")
                                .font(.system(size: 10))
                                .padding(4)
                                .background(Color.white)
                                .clipShape(Circle())
                                .foregroundColor(.gray)
                        }
                        .padding(4)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(product.0)
                            .font(.custom("Georgia", size: 11))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        
                        Text(product.1)
                            .font(.custom("Georgia-Bold", size: 12))
                            .foregroundColor(Color(red: 1.0, green: 0.45, blue: 0.69))
                    }
                    .padding(6)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 1)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    ProductCardView()
}
