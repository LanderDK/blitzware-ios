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

struct ReverseScrollView<Content>: View where Content: View {
    @State private var contentHeight: CGFloat = CGFloat.zero
    @State private var scrollOffset: CGFloat = CGFloat.zero
    @State private var currentOffset: CGFloat = CGFloat.zero
    
    var content: () -> Content
    
    // Calculate content offset
    func offset(outerheight: CGFloat, innerheight: CGFloat) -> CGFloat {
        //print("outerheight: \(outerheight) innerheight: \(innerheight)")
        
        let totalOffset = currentOffset + scrollOffset
        return -((innerheight/2 - outerheight/2) - totalOffset)
    }
    
    var body: some View {
        GeometryReader { outerGeometry in
            withAnimation(.easeInOut) {
                // Render the content
                self.content()
                    .modifier(ViewHeightKey())
                    .onPreferenceChange(ViewHeightKey.self) { self.contentHeight = $0 }
                    .frame(height: outerGeometry.size.height)
                    .offset(y: self.offset(outerheight: outerGeometry.size.height, innerheight: self.contentHeight))
                    .clipped()
                    .gesture(
                        DragGesture()
                            .onChanged({ self.onDragChanged($0) })
                            .onEnded({ self.onDragEnded($0, outerHeight: outerGeometry.size.height) })
                    )
            }
        }
    }
    
    func onDragChanged(_ value: DragGesture.Value) {
        // Update rendered offset
        //print("Start: \(value.startLocation.y)")
        //print("Start: \(value.location.y)")
        self.scrollOffset = (value.location.y - value.startLocation.y)
        //print("Scrolloffset: \(self.scrollOffset)")
    }
    
    func onDragEnded(_ value: DragGesture.Value, outerHeight: CGFloat) {
        // Update view to target position based on drag position
        let scrollOffset = value.location.y - value.startLocation.y
        //print("Ended currentOffset=\(self.currentOffset) scrollOffset=\(scrollOffset)")
        
        let topLimit = self.contentHeight - outerHeight
        //print("toplimit: \(topLimit)")
        
        // Negative topLimit => Content is smaller than screen size. We reset the scroll position on drag end:
        if topLimit < 0 {
             self.currentOffset = 0
        } else {
            // We cannot pass bottom limit (negative scroll)
            if self.currentOffset + scrollOffset < 0 {
                self.currentOffset = 0
            } else if self.currentOffset + scrollOffset > topLimit {
                self.currentOffset = topLimit
            } else {
                self.currentOffset += scrollOffset
            }
        }
        //print("new currentOffset=\(self.currentOffset)")
        self.scrollOffset = 0
    }
}

struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = value + nextValue()
    }
}

extension ViewHeightKey: ViewModifier {
    func body(content: Content) -> some View {
        return content.background(GeometryReader { proxy in
            Color.clear.preference(key: Self.self, value: proxy.size.height)
        })
    }
}
