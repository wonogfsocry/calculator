//
//  ContentView.swift
//  calculator
//
//  Created by user10 on 2024/11/12.
//

import SwiftUI

struct ContentView: View {
    @State private var display = "0"
    @State private var currentNumber = 0.0
    @State private var currentOperation: String? = nil
    @State private var exchangeRateUSD: Double = 30.0 // 1 USD = 30 TWD
    @State private var exchangeRateJPY: Double = 0.27 // 1 JPY = 0.27 TWD
    @State private var selectedCurrency = "TWD" // 初始貨幣
    @State private var showCurrencyActionSheet = false

    let buttons = [
        ["AC", "+/-", "%", "÷"],
        ["7", "8", "9", "×"],
        ["4", "5", "6", "-"],
        ["1", "2", "3", "+"],
        ["0", ".", "="]
    ]

    var body: some View {
        VStack(spacing: 10) {
            // 當前貨幣顯示欄
            Text("Currency: \(selectedCurrency)")
                .font(.headline)
                .padding(.bottom, 10)
            
            // 顯示欄
            Text(display)
                .font(.largeTitle)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding()
                .background(Color.black)
                .foregroundColor(.white)
            
            // 按鈕
            ForEach(buttons, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(row, id: \.self) { button in
                        Button(action: {
                            self.buttonTapped(button)
                        }) {
                            Text(button)
                                .font(.title)
                                .frame(width: button == "0" ? 170 : 80, height: 80) // 長按鈕效果
                                .background(self.isOperator(button) ? Color.orange : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(40)
                        }
                    }
                }
            }
            
            // 匯率轉換按鈕
            Button(action: {
                self.showCurrencyActionSheet = true
            }) {
                Text("Select Currency")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .padding(.top, 10)
            }
            .actionSheet(isPresented: $showCurrencyActionSheet) {
                ActionSheet(
                    title: Text("Choose Currency"),
                    buttons: [
                        .default(Text("TWD")) { convertCurrency(to: "TWD") },
                        .default(Text("USD")) { convertCurrency(to: "USD") },
                        .default(Text("JPY")) { convertCurrency(to: "JPY") },
                        .cancel()
                    ]
                )
            }
        }
        .padding()
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }

    func buttonTapped(_ button: String) {
        switch button {
        case "0"..."9", ".":
            if display == "0" || (currentOperation != nil && currentNumber == Double(display)) {
                display = button
            } else {
                display += button
            }
            
        case "AC":
            display = "0"
            currentNumber = 0
            currentOperation = nil
            
        case "=", "+", "-", "×", "÷":
            if let operation = currentOperation {
                calculateResult()
                currentOperation = nil
            }
            currentNumber = Double(display) ?? 0
            currentOperation = button
            
        case "%":
            if let number = Double(display) {
                display = String(number / 100)
            }
            
        case "+/-":
            if let number = Double(display) {
                display = String(number * -1)
            }
            
        default:
            break
        }
    }

    func calculateResult() {
        guard let operation = currentOperation else { return }
        
        let newNumber = Double(display) ?? 0
        
        switch operation {
        case "+":
            display = String(currentNumber + newNumber)
        case "-":
            display = String(currentNumber - newNumber)
        case "×":
            display = String(currentNumber * newNumber)
        case "÷":
            display = newNumber != 0 ? String(currentNumber / newNumber) : "Error"
        default:
            break
        }
        
        currentNumber = Double(display) ?? 0
    }

    func isOperator(_ button: String) -> Bool {
        return button == "+" || button == "-" || button == "×" || button == "÷"
    }

    func convertCurrency(to targetCurrency: String) {
        guard let number = Double(display) else { return }

        var convertedNumber = number

        // 將當前貨幣轉換為目標貨幣
        if selectedCurrency == "TWD" {
            if targetCurrency == "USD" {
                convertedNumber = number / exchangeRateUSD
            } else if targetCurrency == "JPY" {
                convertedNumber = number / exchangeRateJPY
            }
        } else if selectedCurrency == "USD" {
            if targetCurrency == "TWD" {
                convertedNumber = number * exchangeRateUSD
            } else if targetCurrency == "JPY" {
                convertedNumber = (number * exchangeRateUSD) / exchangeRateJPY
            }
        } else if selectedCurrency == "JPY" {
            if targetCurrency == "TWD" {
                convertedNumber = number * exchangeRateJPY
            } else if targetCurrency == "USD" {
                convertedNumber = (number * exchangeRateJPY) / exchangeRateUSD
            }
        }

        display = String(convertedNumber)
        selectedCurrency = targetCurrency
    }
}

#Preview {
    ContentView()
}
