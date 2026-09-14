import SwiftUI

struct ContentView: View {
    @State private var inputN: String = ""
    @State private var inputA: String = ""
    @State private var inputB: String = ""
    
    @State private var resultSquare: String = "-"
    @State private var resultCube: String = "-"
    @State private var resultFactorial: String = "-"
    @State private var resultPrime: String = "-"
    
    @State private var resultGCD: String = "-"
    @State private var resultLCM: String = "-"
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // Header
                VStack(spacing: 4) {
                    Text("Number Tools")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.blue)
                    
                }
                .padding(.top, 10)
                
                // Single Number Input Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Single Number (n)")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    Text("Enter a number:")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    
                    TextField("n", text: $inputN)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                    
                    HStack(spacing: 10) {
                        ActionButton(title: "n²", subtitle: "Square", color: .blue) { calculateSquare() }
                        ActionButton(title: "n³", subtitle: "Cube", color: .purple) { calculateCube() }
                        ActionButton(title: "n!", subtitle: "Factorial", color: .pink) { calculateFactorial() }
                        ActionButton(title: "Prime?", subtitle: "Check", color: .green) { checkPrime() }
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(16)
                
                // Single Number Results Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Results for n = \(inputN.isEmpty ? "?" : inputN)")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    HStack(spacing: 10) {
                        ResultCard(title: "n²", result: resultSquare, color: .blue.opacity(0.2), textColor: .blue)
                        ResultCard(title: "n³", result: resultCube, color: .purple.opacity(0.2), textColor: .purple)
                        ResultCard(title: "n!", result: resultFactorial, color: .pink.opacity(0.2), textColor: .pink)
                        ResultCard(title: "Prime?", result: resultPrime, color: .green.opacity(0.2), textColor: .green)
                    }
                }
                .padding()
                .background(Color.pink.opacity(0.1))
                .cornerRadius(16)
                
                // Two Numbers Input Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Two Numbers (a, b)")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    HStack(spacing: 20) {
                        VStack(alignment: .leading) {
                            Text("Enter a:")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                            TextField("a", text: $inputA)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                        }
                        VStack(alignment: .leading) {
                            Text("Enter b:")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                            TextField("b", text: $inputB)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                        }
                    }
                    
                    HStack(spacing: 10) {
                        WideButton(title: "UCLN (GCD)", color: .green) { calculateGCD() }
                        WideButton(title: "BCNN (LCM)", color: .orange) { calculateLCM() }
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(16)
                
                // Two Numbers Results Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Results for a = \(inputA.isEmpty ? "?" : inputA), b = \(inputB.isEmpty ? "?" : inputB)")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    HStack(spacing: 10) {
                        ResultCard(title: "UCLN (GCD)", result: resultGCD, color: .green.opacity(0.2), textColor: .blue)
                        ResultCard(title: "BCNN (LCM)", result: resultLCM, color: .orange.opacity(0.2), textColor: .blue)
                    }
                }
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.blue.opacity(0.2), lineWidth: 2))
                .padding(.horizontal, 2)
                
                // Bottom Action Buttons
                HStack(spacing: 20) {
                    Button(action: clearAll) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Clear All")
                        }
                        .font(.headline)
                        .foregroundColor(.pink)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.pink.opacity(0.2))
                        .cornerRadius(12)
                    }
                    
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "questionmark.circle")
                            Text("Help")
                        }
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(12)
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Logic Functions
    
    func calculateSquare() {
        guard let n = Int(inputN) else { resultSquare = "Err"; return }
        resultSquare = "\(n * n)"
    }
    
    func calculateCube() {
        guard let n = Int(inputN) else { resultCube = "Err"; return }
        resultCube = "\(n * n * n)"
    }
    
    func calculateFactorial() {
        guard let n = Int(inputN) else { resultFactorial = "Err"; return }
        if n < 0 { resultFactorial = "Err"; return }
        if n > 20 { resultFactorial = "Max"; return }
        var fact: Int64 = 1
        if n > 0 { for i in 1...n { fact *= Int64(i) } }
        resultFactorial = "\(fact)"
    }
    
    func checkPrime() {
        guard let n = Int(inputN) else { resultPrime = "Err"; return }
        if n < 2 { resultPrime = "No"; return }
        if n == 2 || n == 3 { resultPrime = "Yes"; return }
        var isPrime = true
        let limit = Int(Double(n).squareRoot())
        if limit >= 2 {
            for i in 2...limit {
                if n % i == 0 {
                    isPrime = false
                    break
                }
            }
        }
        resultPrime = isPrime ? "Yes" : "No"
    }
    
    func calculateGCD() {
        guard let a = Int(inputA), let b = Int(inputB) else { resultGCD = "Err"; return }
        resultGCD = "\(gcd(a, b))"
    }
    
    func calculateLCM() {
        guard let a = Int(inputA), let b = Int(inputB) else { resultLCM = "Err"; return }
        if a == 0 || b == 0 { resultLCM = "0"; return }
        resultLCM = "\(abs(a * b) / gcd(a, b))"
    }
    
    private func gcd(_ x: Int, _ y: Int) -> Int {
        var a = abs(x)
        var b = abs(y)
        while b != 0 {
            let temp = b
            b = a % b
            a = temp
        }
        return a
    }
    
    func clearAll() {
        inputN = ""
        inputA = ""
        inputB = ""
        resultSquare = "-"
        resultCube = "-"
        resultFactorial = "-"
        resultPrime = "-"
        resultGCD = "-"
        resultLCM = "-"
    }
}

// MARK: - Helper Views

struct ActionButton: View {
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Text(title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                Text(subtitle)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(color)
            .cornerRadius(12)
        }
    }
}

struct ResultCard: View {
    let title: String
    let result: String
    let color: Color
    let textColor: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(textColor)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            Text(result)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.blue)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color)
        .cornerRadius(12)
    }
}

struct WideButton: View {
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(color)
                .cornerRadius(12)
        }
    }
}
