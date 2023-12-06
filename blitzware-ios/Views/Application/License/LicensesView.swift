//
//  LicensesView.swift
//  blitzware-ios
//
//  Created by Lander De Kesel on 28/11/2023.
//

import SwiftUI

struct LicensesList: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var isShowingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var isShowingAddSheet = false
    @State private var isShowingEditSheet = false
    var application: ApplicationData
    @State var licenseToEdit: LicenseDataMutate?
    
    var body: some View {
        VStack {
            HStack {
                Text("License Manager - \(application.name)")
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
                List(viewModel.licenses, id: \.id) { license in
                    LicenseRowView(license: license)
                        .contextMenu {
                            CustomButton(title: "Edit") {
                                licenseToEdit = LicenseDataMutate(id: license.id, license: license.license, days: license.days,
                                                                  used: license.used, enabled: license.enabled,
                                                                  subscription: license.userSubId)
                                isShowingEditSheet = true
                            }
                            if license.enabled == 1 {
                                CustomButton(title: "Ban") {
                                    let newLicense = LicenseDataMutate(id: license.id, license: license.license, days: license.days,
                                                                       used: license.used, enabled: 0, subscription: license.userSubId)
                                    Task {
                                        await viewModel.updateLicenseById(license: newLicense)
                                        if viewModel.requestState == .success {
                                            if let index = viewModel.licenses.firstIndex(where: { $0.id == license.id }) {
                                                viewModel.licenses[index].enabled = 0
                                            }
                                            alertTitle = "Success!"
                                            alertMessage = "License banned successfully."
                                            isShowingAlert = true
                                        } else {
                                            alertTitle = "Oops!"
                                            alertMessage = viewModel.errorData?.message ?? "Unkown error"
                                            isShowingAlert = true
                                        }
                                    }
                                }
                            } else {
                                CustomButton(title: "Unban") {
                                    let newLicense = LicenseDataMutate(id: license.id, license: license.license, days: license.days,
                                                                       used: license.used, enabled: 1, subscription: license.userSubId)
                                    Task {
                                        await viewModel.updateLicenseById(license: newLicense)
                                        if viewModel.requestState == .success {
                                            if let index = viewModel.licenses.firstIndex(where: { $0.id == license.id }) {
                                                viewModel.licenses[index].enabled = 1
                                            }
                                            alertTitle = "Success!"
                                            alertMessage = "License unbanned successfully."
                                            isShowingAlert = true
                                        } else {
                                            alertTitle = "Oops!"
                                            alertMessage = viewModel.errorData?.message ?? "Unkown error"
                                            isShowingAlert = true
                                        }
                                    }
                                }
                            }
                            CustomButton(title: "Delete") {
                                Task {
                                    await viewModel.deleteLicenseById(licenseId: license.id)
                                    if viewModel.requestState == .success {
                                        alertTitle = "Success!"
                                        alertMessage = "License deleted successfully."
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
                    await viewModel.getLicensesOfApplication(applicationId: application.id)
                    await viewModel.getUserSubsOfApplication(applicationId: application.id)
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
                AddLicenseView(isPresented: $isShowingAddSheet)
            }
            .sheet(isPresented: $isShowingEditSheet) {
                EditLicenseView(license: licenseToEdit!, isPresented: $isShowingEditSheet)
            }
        }
    }
}

struct EditLicenseView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Binding var isPresented: Bool
    @State private var license: LicenseDataMutate
    @State private var llicnese: String
    @State private var days: Int
    @State private var used: Int
    @State private var enabled: Int
    @State private var subscription: Int
    private let options = ["0", "1"]

    init(license: LicenseDataMutate, isPresented: Binding<Bool>) {
        self._license = State(initialValue: license)
        self._llicnese = State(initialValue: license.license)
        self._days = State(initialValue: license.days)
        self._used = State(initialValue: license.used)
        self._enabled = State(initialValue: license.enabled)
        self._subscription = State(initialValue: license.subscription ?? 0)
        self._isPresented = isPresented
    }

    var body: some View {
        VStack {
            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                Spacer()
                Text("Update an user")
                    .font(.headline)
                    .padding()
                Spacer()
                Button("Update") {
                    let newLicense = LicenseDataMutate(id: license.id, license: llicnese, days: days, used: used, enabled: enabled,
                                                       subscription: subscription)
                    Task {
                        await viewModel.updateLicenseById(license: newLicense)
                    }
                    isPresented = false
                }
            }
            .padding()
            
            Form {
                TextField("License", text: $llicnese)
                TextField("Days", text: Binding<String>(
                    get: { String(self.days) },
                    set: { if let value = Int($0) { self.days = value } }
                ))
                DropDownInputBool(label: "Used", name: "used", options: options, selectedOption: $used)
                    .frame(width: 200)
                DropDownInputBool(label: "Enabled", name: "enabled", options: options, selectedOption: $enabled)
                    .frame(width: 200)
                Picker("Subscription level", selection: $subscription) {
                    ForEach(viewModel.userSubs, id: \.self) { userSub in
                        Text("\(userSub.name) (\(userSub.level)")
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
            }
        }.onDisappear(perform: {
            Task {
                await viewModel.getLicensesOfApplication(applicationId: viewModel.licenses.first(where: {$0.id == license.id})!.application.id)
            }
        })
    }
}

struct AddLicenseView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Binding var isPresented: Bool
    @State private var days = 0    
    @State private var format = "XXXXXXXXXXXXXXXXXXXX"
    @State private var prefix = ""
    @State private var amount = 0
    @State private var subscription: Int = 0
    let options = [
        "XXXXXXXXXXXXXXXXXXXX",
        "PREFIX-XXXXXXXXXXXXXXXXXXXX",
        "XXXXX-XXXXX-XXXXX-XXXXX",
        "PREFIX-XXXXX-XXXXX-XXXXX-XXXXX"
    ]

    var body: some View {
        VStack {
            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                Spacer()
                Text("Create a license")
                    .font(.headline)
                    .padding()
                Spacer()
                Button("Create") {
                    if days != 0 || amount != 0 || subscription != 0 {
                        Task {
                            if !prefix.isEmpty && prefix != "" {
                                format = format.replacingOccurrences(of: "PREFIX", with: prefix)
                            }
                            await viewModel.createLicense(days: days, format: format, amount: amount, subscription: subscription,
                                                          applicationId: viewModel.applicationData!.id)
                        }
                        isPresented = false
                    }
                }
            }
            .padding()
            
            Form {
                TextField("Days", text: Binding<String>(
                    get: { String(self.days) },
                    set: { if let value = Int($0) { self.days = value } }
                ))
                DropdownInputString(label: "Format", name: "format", options: options, selectedOption: $format)
                TextField("Prefix", text: $prefix)
                TextField("Amount", text: Binding<String>(
                    get: { String(self.amount) },
                    set: { if let value = Int($0) { self.amount = value } }
                ))
                Picker("Subscription level", selection: $subscription) {
                    ForEach(viewModel.userSubs, id: \.self) { userSub in
                        Text("\(userSub.name) (\(userSub.level)")
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }
    }
}


struct LicenseRowView: View {
    @EnvironmentObject var viewModel: AppViewModel
    var license: LicenseData

    var body: some View {
        //NavigationLink(destination: BottomNavBarApp(application: application)) {
            VStack(alignment: .leading, spacing: 3) {
                Text(license.license)
                    .foregroundColor(.primary)
                    .font(.headline)
                Text("\(license.days)")
                    .font(.subheadline)
                ForEach(viewModel.userSubs) { userSub in
                    if userSub.id == license.userSubId {
                        Text("\(userSub.name) (\(userSub.level))")
                            .font(.subheadline)
                    }
                }
                Text(license.used == 1 ? "Used" : "Not Used")
                    .font(.subheadline)
                Text(license.usedBy ?? "N/A")
                    .font(.subheadline)
            }
        //}
    }
}
