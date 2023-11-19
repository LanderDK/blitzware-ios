//
//  ResourcesView.swift
//  blitzware-ios
//
//  Created by Lander De Kesel on 09/11/2023.
//

import SwiftUI

struct ResourceView: View {
    var name: String
    var link: String
    var iconName: String

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(name)
                    .font(.headline)
                Text(link)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Link(destination: URL(string: link)!, label: {
                Image(systemName: "\(iconName)")
                    .foregroundColor(Color(red: 253/255, green: 126/255, blue: 20/255))
                    .font(.system(size: 20, weight: .bold))
            })
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding(.horizontal)
        .padding(.bottom, 10)
    }
}

struct ResourcesList: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    ResourceView(name: "API Documentation", link: "https://docs.blitzware.xyz/", iconName: "arrowshape.forward.fill")
                    ResourceView(name: "Video Tutorials", link: "https://youtube.com/playlist?list=PLdX34hqAHqx8eia7qY4XE8R68t769vA-j&si=2fGZaEvYzm8x-byx", iconName: "arrowshape.forward.fill")
                    ResourceView(name: "C# Example", link: "https://github.com/LanderDK/BlitzWare-CSHARP-Example", iconName: "arrow.down.to.line")
                    ResourceView(name: "C++ Example", link: "https://github.com/LanderDK/BlitzWare-CPP-Example", iconName: "arrow.down.to.line")
                    ResourceView(name: "Python Example", link: "https://github.com/LanderDK/BlitzWare-Python-Example", iconName: "arrow.down.to.line")
                    ResourceView(name: "Java Example", link: "https://github.com/LanderDK/ApiTestJava", iconName: "arrow.down.to.line")
                    ResourceView(name: "ReactJS Example", link: "https://github.com/LanderDK/ApiTestReact", iconName: "arrow.down.to.line")
                }
            }
            .navigationBarTitle("Resources")
        }
    }
}

struct ResourcesList_Previews: PreviewProvider {
    static var previews: some View {
        ResourcesList()
    }
}
