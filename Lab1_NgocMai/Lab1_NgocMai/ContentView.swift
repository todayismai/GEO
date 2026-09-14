//
//  ContentView.swift
//  Lab1_NgocMai
//
//  Created by MAY 08 on 14/9/26.
//

import SwiftUI

struct ContentView: View {
    @State private var inputN = ""
    @State private var result = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Calculate n²")
                .font(.largeTitle)
                .bold()
            
            TextField("Enter a number", text: $inputN)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
                .padding()
            
            Button("Calculate n²") {
                if let n = Int(inputN) {
                    let square = n * n
                    result = "\(square)"
                } else {
                    result = "Please enter a valid number."
                }
            }
            .buttonStyle(.borderedProminent)
            
            Text("Result: \(result)")
                .font(.title3)
        }
        .padding()
    }
}
