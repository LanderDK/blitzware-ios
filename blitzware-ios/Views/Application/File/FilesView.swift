//
//  FilesView.swift
//  blitzware-ios
//
//  Created by Lander De Kesel on 06/12/2023.
//

import SwiftUI

struct FilesList: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var isShowingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var isShowingAddSheet = false
    var application: ApplicationData
    
    var body: some View {
        VStack {
            HStack {
                Text("File Manager - \(application.name)")
                    .font(.title)
                    .padding()
                Spacer()
                Button {
                    isShowingAddSheet = true
                } label: {
                    Image(systemName: "plus.app.fill")
                }
                .font(.title)
                .padding()
                .accentColor(Color(red: 25/255, green: 118/255, blue: 210/255))
            }
            VStack {
                if viewModel.requestState == .error {
                    Text(viewModel.errorData?.message ?? "Unknown error")
                        .foregroundColor(.red)
                }
                if viewModel.requestState == .pending || viewModel.requestState == .sent {
                    ProgressView()
                }
                List(viewModel.files, id: \.id) { file in
                    FileRowView(file: file)
                        .contextMenu {
                            CustomButton(title: "Delete") {
                                Task {
                                    await viewModel.deleteFileById(fileId: file.id)
                                    if viewModel.requestState == .success {
                                        alertTitle = "Success!"
                                        alertMessage = "File deleted successfully."
                                        isShowingAlert = true
                                    } else {
                                        alertTitle = "Oops!"
                                        alertMessage = viewModel.errorData?.message ?? "Unkown error"
                                        isShowingAlert = true
                                    }
                                }
                            }
                        }
                }
            }.onAppear(perform: {
                Task {
                    await viewModel.getFilesOfApplication(applicationId: application.id)
                }
            })
            .alert(isPresented: $isShowingAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .sheet(isPresented: $isShowingAddSheet) {
                AddFileView(isPresented: $isShowingAddSheet)
            }
        }
    }
}

struct AddFileView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Binding var isPresented: Bool
    @State private var name = ""
    @State private var level = 0
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack {
            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                Spacer()
                Text("Upload a file")
                    .font(.headline)
                    .padding()
                Spacer()
                Button("Upload") {
                    if !name.isEmpty && level >= 0 && level <= 9  {
                        Task {
                            await viewModel.createFile(applicationId: viewModel.applicationData!.id)
                        }
                        isPresented = false
                    }
                }
            }
            .padding()
            
            Form {
                TextField("Name", text: $name)
                    .focused($isTextFieldFocused)
                HStack {
                    Text("Level")
                    Spacer()
                    TextField("Level", text: Binding<String>(
                        get: { String(self.level) },
                        set: { if let value = Int($0) { self.level = value } }
                    ))
                }
                
            }
        }
        .onAppear {
            isTextFieldFocused = true
        }
    }
}


struct FileRowView: View {
    @EnvironmentObject var viewModel: AppViewModel
    var file: FileData

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(file.name)
                .foregroundColor(.primary)
                .font(.headline)
            HStack {
                Text("ID: ")
                    .font(.subheadline)
                    .fontWeight(.bold)
                Text(file.id)
                    .font(.subheadline)
            }
            HStack {
                Text("Size: ")
                    .font(.subheadline)
                    .fontWeight(.bold)
                Text(formatBytes(file.size) ?? "N/A")
                    .font(.subheadline)
            }
            HStack {
                Text("Created On: ")
                    .font(.subheadline)
                    .fontWeight(.bold)
                Text(file.createdOnString)
                    .font(.subheadline)
            }
        }
    }
}

