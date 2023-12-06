//
//  ExtentionsView.swift
//  blitzware-ios
//
//  Created by Lander De Kesel on 09/11/2023.
//

import SwiftUI

func formattedDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd MMM yyyy HH:mm"
    return formatter.string(from: date)
}

func formatBytes(_ bytesString: String, decimals: Int = 2) -> String? {
    guard let bytes = Double(bytesString) else {
        return nil
    }

    if bytes == 0 {
        return "0 Bytes"
    }

    let k = 1024.0
    let dm = decimals < 0 ? 0 : decimals
    let sizes = ["Bytes", "KB", "MB", "GB", "TB", "PB"]
    let i = Int(floor(log(bytes) / log(k)))

    return String(format: "%.\(dm)f %@",
                  bytes / pow(k, Double(i)),
                  sizes[i])
}

struct Constants {
    static let accentColor = Color(red: 253/255, green: 126/255, blue: 20/255)
    static let mainColorLight = Color(red: 255/255, green: 94/255, blue: 0/255)
    static let lightGray = Color(red: 211/255, green: 211/255, blue: 211/255)
    static let verticalPadding: CGFloat = 25.0
}

struct CustomButton: View {
    var title: String
    var isDisabled: Bool = false
    var action: () async -> Void
    
    var body: some View {
        Button(action: {
            Task {
                await action()
            }
        }) {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .padding()
                .background(isDisabled ? Color(red: 228/255, green: 228/255, blue: 228/255) :
                                Color(red: 25/255, green: 118/255, blue: 210/255))
                .foregroundColor(isDisabled ? .gray : .white)
                .cornerRadius(8)
        }
        .disabled(isDisabled)
    }
}

struct DropDownInputBool: View {
    let label: String
    let name: String
    let options: [String]
    @Binding var selectedOption: Int

    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
            Picker(selection: $selectedOption, label: Text("")) {
                ForEach(options, id: \.self) { option in
                    Text(option == "0" ? "False" : "True").tag(option)
                }
            }
            .pickerStyle(MenuPickerStyle())
        }
    }
}

struct DropdownInputString: View {
    let label: String
    let name: String
    let options: [String]
    @Binding var selectedOption: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
            Picker(selection: $selectedOption, label: Text("")) {
                ForEach(options, id: \.self) { option in
                    Text(option)
                }
            }
            .pickerStyle(MenuPickerStyle())
        }
    }
}
