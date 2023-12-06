import Foundation

class AppViewModel: ObservableObject {
    @Published var accountData: AccountLoginData?
    @Published var applications: [ApplicationData] = []
    @Published var applicationData: ApplicationData?
    @Published var generalChatMsgs: [ChatMessageData] = []
    @Published var individualAccountLogs: [LogData] = []
    @Published var users: [UserData] = []
    @Published var userSubs: [UserSubData] = []
    @Published var licenses: [LicenseData] = []
    @Published var files: [FileData] = []
    @Published var appLogs: [AppLogData] = []
    @Published var requestState: RequestState = .none
    @Published var errorData: ErrorData?
    @Published var isAuthed: Bool = false
    private var baseUrl: String = "http://localhost:9000/api"
    
    // MARK: - Account request functions
    
    func login(username: String, password: String) async {
        self.errorData = nil
        self.requestState = .pending
        
        guard let url = URL(string: baseUrl + "/accounts/login") else { return }
        
        let body: [String: Any] = ["username": username, "password": password]
        
        do {
            let finalData = try JSONSerialization.data(withJSONObject: body)
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = finalData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                self.requestState = .sent
//                let responseString = String(data: data, encoding: .utf8)
//                print("Raw Response Data:\n\(responseString ?? "Empty")")
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        let result = try JSONDecoder().decode(AccountLoginData.self, from: data)
                        self.requestState = .success
                        self.accountData = result
                        self.isAuthed = true
                    } else {
                        let result = try JSONDecoder().decode(ErrorData.self, from: data)
                        self.errorData = result
                        self.requestState = .error
                        self.isAuthed = false
                    }
                }
            } catch {
                print("Error fetching data: \(error)")
                self.requestState = .error
                self.errorData = ErrorData(code: "FETCH_ERROR", message: "Error fetching data: \(error.localizedDescription)")
            }
        } catch {
            print("Error serializing JSON: \(error.localizedDescription)")
            self.requestState = .error
            self.errorData = ErrorData(code: "CATCH_ERROR", message: "Error serializing JSON: \(error.localizedDescription)")
        }
    }
    
    func getAccountById(id: String) async {
        self.errorData = nil
        self.requestState = .pending
        
        guard let url = URL(string: baseUrl + "/accounts/\(id)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(self.accountData!.token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            self.requestState = .sent
//            let responseString = String(data: data, encoding: .utf8)
//            print("Raw Response Data:\n\(responseString ?? "Empty")")
            
            if let httpResponse = response as? HTTPURLResponse {
//                          print("HTTP Status Code: \(httpResponse.statusCode)")
//                          print("Response Headers: \(httpResponse.allHeaderFields)")
                if httpResponse.statusCode == 200 {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(AccountLoginData.Account.self, from: data)
                    self.requestState = .success
                    self.accountData?.account = result
                } else {
                    let result = try JSONDecoder().decode(ErrorData.self, from: data)
                    self.errorData = result
                    self.requestState = .error
                }
            }
        } catch {
            print("Error decoding data: \(error)")
            self.requestState = .error
            self.errorData = ErrorData(code: "CATCH_ERROR", message: "Error decoding data: \(error.localizedDescription)")
        }
    }
    
    // TODO: - DOES NOT WORK
    func updateAccountProfilePictureById(id: String, profilePicture: [String: Any]) async {
        self.errorData = nil
        self.requestState = .pending
        
        guard let url = URL(string: baseUrl + "/accounts/profilePicture/\(id)") else { return }
        
        let body: [String: Any] = ["profilePicture":profilePicture]
        
        do {
            let finalData = try JSONSerialization.data(withJSONObject: body)
            
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.httpBody = finalData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(self.accountData!.token)", forHTTPHeaderField: "Authorization")
            
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                self.requestState = .sent
                
                let responseString = String(data: data, encoding: .utf8)
                print("Raw Response Data:\n\(responseString ?? "Empty")")
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 204 {
                        self.requestState = .success
                    } else {
                        let result = try JSONDecoder().decode(ErrorData.self, from: data)
                        self.errorData = result
                        self.requestState = .error
                    }
                }
            } catch {
                print("Error fetching data: \(error)")
                self.requestState = .error
                self.errorData = ErrorData(code: "FETCH_ERROR", message: "Error fetching data: \(error.localizedDescription)")
            }
        } catch {
            print("Error serializing JSON: \(error.localizedDescription)")
            self.requestState = .error
            self.errorData = ErrorData(code: "CATCH_ERROR", message: "Error serializing JSON: \(error.localizedDescription)")
        }
    }

    
    // MARK: - Application request functions
    
    func getApplicationsOfAccount() async {
        self.errorData = nil
        self.requestState = .pending
        
        guard let url = URL(string: baseUrl + "/applications/byAccId/\(self.accountData!.account.id)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(self.accountData!.token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            self.requestState = .sent
//                      let responseString = String(data: data, encoding: .utf8)
//                      print("Raw Response Data:\n\(responseString ?? "Empty")")
            
            if let httpResponse = response as? HTTPURLResponse {
//                          print("HTTP Status Code: \(httpResponse.statusCode)")
//                          print("Response Headers: \(httpResponse.allHeaderFields)")
                if httpResponse.statusCode == 200 {
                    let decoder = JSONDecoder()
                    let results = try decoder.decode([ApplicationData].self, from: data)
                    self.requestState = .success
                    self.applications = results
                } else {
                    let result = try JSONDecoder().decode(ErrorData.self, from: data)
                    self.errorData = result
                    self.requestState = .error
                }
            }
        } catch {
            print("Error decoding data: \(error)")
            self.requestState = .error
            self.errorData = ErrorData(code: "CATCH_ERROR", message: "Error decoding data: \(error.localizedDescription)")
        }
    }
    
    func updateApplicationById(application: ApplicationData) async {
        self.errorData = nil
        self.requestState = .pending
        
        guard let url = URL(string: baseUrl + "/applications/\(application.id)") else { return }
        
        let body: [String: Any] = ["status": application.status, "hwidCheck": application.hwidCheck, "developerMode": application.developerMode,
                                   "integrityCheck": application.integrityCheck, "freeMode": application.freeMode,
                                   "twoFactorAuth": application.twoFactorAuth, "programHash": application.programHash ?? nil,
                                   "version": application.version, "downloadLink": application.downloadLink ?? nil,
                                   "accountId": self.accountData!.account.id, "subscription": application.adminRoleId ?? nil]
        
        do {
            let finalData = try JSONSerialization.data(withJSONObject: body)
            
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.httpBody = finalData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(self.accountData!.token)", forHTTPHeaderField: "Authorization")
            
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                self.requestState = .sent
                
                let responseString = String(data: data, encoding: .utf8)
                print("Raw Response Data:\n\(responseString ?? "Empty")")
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 204 {
                        self.requestState = .success
                    } else {
                        let result = try JSONDecoder().decode(ErrorData.self, from: data)
                        self.errorData = result
                        self.requestState = .error
                    }
                }
            } catch {
                print("Error fetching data: \(error)")
                self.requestState = .error
                self.errorData = ErrorData(code: "FETCH_ERROR", message: "Error fetching data: \(error.localizedDescription)")
            }
        } catch {
            print("Error serializing JSON: \(error.localizedDescription)")
            self.requestState = .error
            self.errorData = ErrorData(code: "CATCH_ERROR", message: "Error serializing JSON: \(error.localizedDescription)")
        }
    }
    
    func deleteApplicationById(applicationId: String) async {
        self.errorData = nil
        self.requestState = .pending
        
        guard let url = URL(string: baseUrl + "/applications/\(applicationId)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(self.accountData!.token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            self.requestState = .sent
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 204 {
                    self.requestState = .success
                    if let index = self.applications.firstIndex(where: { $0.id == applicationId }) {
                        self.applications.remove(at: index)
                    }
                } else {
                    let result = try JSONDecoder().decode(ErrorData.self, from: data)
                    self.errorData = result
                    self.requestState = .error
                }
            }
        } catch {
            print("Error fetching data: \(error)")
            self.requestState = .error
            self.errorData = ErrorData(code: "FETCH_ERROR", message: "Error fetching data: \(error.localizedDescription)")
        }
    }
    
    func createApplication(name: String) async {
        self.errorData = nil
        self.requestState = .pending
        
        guard let url = URL(string: baseUrl + "/applications") else { return }
        
        let body: [String: Any] = ["name": name, "accountId": self.accountData!.account.id]
        
        do {
            let finalData = try JSONSerialization.data(withJSONObject: body)
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = finalData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(self.accountData!.token)", forHTTPHeaderField: "Authorization")
            
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                self.requestState = .sent
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 201 {
                        let result = try JSONDecoder().decode(ApplicationData.self, from: data)
                        self.requestState = .success
                        self.applications.append(result)
                    } else {
                        let result = try JSONDecoder().decode(ErrorData.self, from: data)
                        self.errorData = result
                        self.requestState = .error
                    }
                }
            } catch {
                print("Error fetching data: \(error)")
                self.requestState = .error
                self.errorData = ErrorData(code: "FETCH_ERROR", message: "Error fetching data: \(error.localizedDescription)")
            }
        } catch {
            print("Error serializing JSON: \(error.localizedDescription)")
            self.requestState = .error
            self.errorData = ErrorData(code: "CATCH_ERROR", message: "Error serializing JSON: \(error.localizedDescription)")
        }
    }
    
    func getApplicationById(id: String) async {
        self.errorData = nil
        self.requestState = .pending
        
        guard let url = URL(string: baseUrl + "/applications/byAppId/\(id)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(self.accountData!.token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            self.requestState = .sent
//                      let responseString = String(data: data, encoding: .utf8)
//                      print("Raw Response Data:\n\(responseString ?? "Empty")")
            
            if let httpResponse = response as? HTTPURLResponse {
//                          print("HTTP Status Code: \(httpResponse.statusCode)")
//                          print("Response Headers: \(httpResponse.allHeaderFields)")
                if httpResponse.statusCode == 200 {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(ApplicationData.self, from: data)
                    self.requestState = .success
                    self.applicationData = result
                } else {
                    let result = try JSONDecoder().decode(ErrorData.self, from: data)
                    self.errorData = result
                    self.requestState = .error
                }
            }
        } catch {
            print("Error decoding data: \(error)")
            self.requestState = .error
            self.errorData = ErrorData(code: "CATCH_ERROR", message: "Error decoding data: \(error.localizedDescription)")
        }
    }
    
    
    // MARK: - ChatMsg request functions
    
    func getChatMsgsByChatId(id: Int) async {
        self.errorData = nil
        self.requestState = .pending
        
        guard let url = URL(string: baseUrl + "/chatMsgs/chat/\(id)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(self.accountData!.token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            self.requestState = .sent
//                      let responseString = String(data: data, encoding: .utf8)
//                      print("Raw Response Data:\n\(responseString ?? "Empty")")
            
            if let httpResponse = response as? HTTPURLResponse {
//                          print("HTTP Status Code: \(httpResponse.statusCode)")
//                          print("Response Headers: \(httpResponse.allHeaderFields)")
                if httpResponse.statusCode == 200 {
                    let decoder = JSONDecoder()
                    let results = try decoder.decode([ChatMessageData].self, from: data)
                    self.requestState = .success
                    self.generalChatMsgs = results
                } else {
                    let result = try JSONDecoder().decode(ErrorData.self, from: data)
                    self.errorData = result
                    self.requestState = .error
                }
            }
        } catch {
            print("Error decoding data: \(error)")
            self.requestState = .error
            self.errorData = ErrorData(code: "CATCH_ERROR", message: "Error decoding data: \(error.localizedDescription)")
        }
    }
    
    func createChatMsg(msg: String, chatId: Int) async {
        self.errorData = nil
        self.requestState = .pending
        
        guard let url = URL(string: baseUrl + "/chatMsgs") else { return }
        
        let dateFormatter = ISO8601DateFormatter()
        let dateString = dateFormatter.string(from: Date())
        
        let body: [String: Any] = ["username": self.accountData!.account.username, "message": msg, "date": dateString, "chatId": chatId]
        
        do {
            let finalData = try JSONSerialization.data(withJSONObject: body)
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = finalData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(self.accountData!.token)", forHTTPHeaderField: "Authorization")
            
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                self.requestState = .sent
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 201 {
                        let result = try JSONDecoder().decode(ChatMessageData.self, from: data)
                        self.requestState = .success
                        self.generalChatMsgs.append(result)
                    } else {
                        let result = try JSONDecoder().decode(ErrorData.self, from: data)
                        self.errorData = result
                        self.requestState = .error
                    }
                }
            } catch {
                print("Error fetching data: \(error)")
                self.requestState = .error
                self.errorData = ErrorData(code: "FETCH_ERROR", message: "Error fetching data: \(error.localizedDescription)")
            }
        } catch {
            print("Error serializing JSON: \(error.localizedDescription)")
            self.requestState = .error
            self.errorData = ErrorData(code: "CATCH_ERROR", message: "Error serializing JSON: \(error.localizedDescription)")
        }
    }
    
    func deleteChatMsgById(id: Int) async {
        self.errorData = nil
        self.requestState = .pending
        
        guard let url = URL(string: baseUrl + "/chatMsgs/\(id)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(self.accountData!.token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            self.requestState = .sent
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 204 {
                    self.requestState = .success
                    if let index = generalChatMsgs.firstIndex(where: { $0.id == id }) {
                        generalChatMsgs.remove(at: index)
                    }
                } else {
                    let result = try JSONDecoder().decode(ErrorData.self, from: data)
                    self.errorData = result
                    self.requestState = .error
                }
            }
        } catch {
            print("Error fetching data: \(error)")
            self.requestState = .error
            self.errorData = ErrorData(code: "FETCH_ERROR", message: "Error fetching data: \(error.localizedDescription)")
        }
    }
    
    
    // MARK: - Log request functions
    
    func getLogsByUsername(username: String) async {
        self.errorData = nil
        self.requestState = .pending
        
        guard let url = URL(string: baseUrl + "/logs/\(username)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(self.accountData!.token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            self.requestState = .sent
//                      let responseString = String(data: data, encoding: .utf8)
//                      print("Raw Response Data:\n\(responseString ?? "Empty")")
            
            if let httpResponse = response as? HTTPURLResponse {
//                          print("HTTP Status Code: \(httpResponse.statusCode)")
//                          print("Response Headers: \(httpResponse.allHeaderFields)")
                if httpResponse.statusCode == 200 {
                    let decoder = JSONDecoder()
                    let results = try decoder.decode([LogData].self, from: data)
                    self.requestState = .success
                    self.individualAccountLogs = results
                } else {
                    let result = try JSONDecoder().decode(ErrorData.self, from: data)
                    self.errorData = result
                    self.requestState = .error
                }
            }
        } catch {
            print("Error decoding data: \(error)")
            self.requestState = .error
            self.errorData = ErrorData(code: "CATCH_ERROR", message: "Error decoding data: \(error.localizedDescription)")
        }
    }
    
    func deleteLogById(id: Int) async {
        self.errorData = nil
        self.requestState = .pending
        
        guard let url = URL(string: baseUrl + "/logs/\(id)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(self.accountData!.token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            self.requestState = .sent
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 204 {
                    self.requestState = .success
                    if let index = individualAccountLogs.firstIndex(where: { $0.id == id }) {
                        individualAccountLogs.remove(at: index)
                    }
                } else {
                    let result = try JSONDecoder().decode(ErrorData.self, from: data)
                    self.errorData = result
                    self.requestState = .error
                }
            }
        } catch {
            print("Error fetching data: \(error)")
            self.requestState = .error
            self.errorData = ErrorData(code: "FETCH_ERROR", message: "Error fetching data: \(error.localizedDescription)")
        }
    }
    
    
    // MARK: - User request functions
    
    func getUsersOfApplication(applicationId: String) async {
        self.errorData = nil
        self.requestState = .pending
        
        guard let url = URL(string: baseUrl + "/users/\(applicationId)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(self.accountData!.token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            self.requestState = .sent
//                      let responseString = String(data: data, encoding: .utf8)
//                      print("Raw Response Data:\n\(responseString ?? "Empty")")
            
            if let httpResponse = response as? HTTPURLResponse {
//                          print("HTTP Status Code: \(httpResponse.statusCode)")
//                          print("Response Headers: \(httpResponse.allHeaderFields)")
                if httpResponse.statusCode == 200 {
                    let decoder = JSONDecoder()
                    let results = try decoder.decode([UserData].self, from: data)
                    self.requestState = .success
                    self.users = results
                } else {
                    let result = try JSONDecoder().decode(ErrorData.self, from: data)
                    self.errorData = result
                    self.requestState = .error
                }
            }
        } catch {
            print("Error decoding data: \(error)")
            self.requestState = .error
            self.errorData = ErrorData(code: "CATCH_ERROR", message: "Error decoding data: \(error.localizedDescription)")
        }
    }
    
    func createUserFromDashboard(username: String, email: String, password: String, id: String, expiry: Date, subscription: Int) async {
        self.errorData = nil
        self.requestState = .pending
        
        guard let url = URL(string: baseUrl + "/users/registerFromDashboard") else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let formattedDateString = dateFormatter.string(from: expiry)
        
        let body: [String: Any] = ["username": username, "email": email, "password": password, "id": id, "expiry": formattedDateString,
                                   "subscription": subscription]
        
        do {
            let finalData = try JSONSerialization.data(withJSONObject: body)
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = finalData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(self.accountData!.token)", forHTTPHeaderField: "Authorization")
            
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                self.requestState = .sent
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 201 {
                        let result = try JSONDecoder().decode(UserData.self, from: data)
                        self.requestState = .success
                        self.users.append(result)
                    } else {
                        let result = try JSONDecoder().decode(ErrorData.self, from: data)
                        self.errorData = result
                        self.requestState = .error
                    }
                }
            } catch {
                print("Error fetching data: \(error)")
                self.requestState = .error
                self.errorData = ErrorData(code: "FETCH_ERROR", message: "Error fetching data: \(error.localizedDescription)")
            }
        } catch {
            print("Error serializing JSON: \(error.localizedDescription)")
            self.requestState = .error
            self.errorData = ErrorData(code: "CATCH_ERROR", message: "Error serializing JSON: \(error.localizedDescription)")
        }
    }
    
    func updateUserById(user: UserDataMutate) async {
        self.errorData = nil
        self.requestState = .pending
        
        guard let url = URL(string: baseUrl + "/users/\(user.id)") else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let formattedDateString = dateFormatter.string(from: user.expiryDate)
        
        let body: [String: Any] = ["username": user.username, "email": user.email, "expiryDate": formattedDateString, "hwid": user.hwid,
                                   "twoFactorAuth": user.twoFactorAuth, "enabled": user.enabled, "subscription": user.subscription]
        
        do {
            let finalData = try JSONSerialization.data(withJSONObject: body)
            
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.httpBody = finalData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(self.accountData!.token)", forHTTPHeaderField: "Authorization")
            
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                self.requestState = .sent
                
//                let responseString = String(data: data, encoding: .utf8)
//                print("Raw Response Data:\n\(responseString ?? "Empty")")
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 204 {
                        self.requestState = .success
                    } else {
                        let result = try JSONDecoder().decode(ErrorData.self, from: data)
                        self.errorData = result
                        self.requestState = .error
                    }
                }
            } catch {
                print("Error fetching data: \(error)")
                self.requestState = .error
                self.errorData = ErrorData(code: "FETCH_ERROR", message: "Error fetching data: \(error.localizedDescription)")
            }
        } catch {
            print("Error serializing JSON: \(error.localizedDescription)")
            self.requestState = .error
            self.errorData = ErrorData(code: "CATCH_ERROR", message: "Error serializing JSON: \(error.localizedDescription)")
        }
    }
    
    func deleteUserById(userId: String) async {
        self.errorData = nil
        self.requestState = .pending
        
        guard let url = URL(string: baseUrl + "/users/\(userId)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(self.accountData!.token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            self.requestState = .sent
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 204 {
                    self.requestState = .success
                    if let index = self.users.firstIndex(where: { $0.id == userId }) {
                        self.users.remove(at: index)
                    }
                } else {
                    let result = try JSONDecoder().decode(ErrorData.self, from: data)
                    self.errorData = result
                    self.requestState = .error
                }
            }
        } catch {
            print("Error fetching data: \(error)")
            self.requestState = .error
            self.errorData = ErrorData(code: "FETCH_ERROR", message: "Error fetching data: \(error.localizedDescription)")
        }
    }

    
    
    // MARK: - UserSub request functions
    
    func getUserSubsOfApplication(applicationId: String) async {
        self.errorData = nil
        self.requestState = .pending
        
        guard let url = URL(string: baseUrl + "/userSubs/application/\(applicationId)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(self.accountData!.token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            self.requestState = .sent
//                      let responseString = String(data: data, encoding: .utf8)
//                      print("Raw Response Data:\n\(responseString ?? "Empty")")
            
            if let httpResponse = response as? HTTPURLResponse {
//                          print("HTTP Status Code: \(httpResponse.statusCode)")
//                          print("Response Headers: \(httpResponse.allHeaderFields)")
                if httpResponse.statusCode == 200 {
                    let decoder = JSONDecoder()
                    let results = try decoder.decode([UserSubData].self, from: data)
                    self.requestState = .success
                    self.userSubs = results
                } else {
                    let result = try JSONDecoder().decode(ErrorData.self, from: data)
                    self.errorData = result
                    self.requestState = .error
                }
            }
        } catch {
            print("Error decoding data: \(error)")
            self.requestState = .error
            self.errorData = ErrorData(code: "CATCH_ERROR", message: "Error decoding data: \(error.localizedDescription)")
        }
    }
    
    func createUserSub(name: String, level: Int, applicationId: String) async {
        self.errorData = nil
        self.requestState = .pending
        
        guard let url = URL(string: baseUrl + "/userSubs") else { return }
        
        let body: [String: Any] = ["name": name, "level": level, "applicationId": applicationId]
        
        do {
            let finalData = try JSONSerialization.data(withJSONObject: body)
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = finalData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(self.accountData!.token)", forHTTPHeaderField: "Authorization")
            
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                self.requestState = .sent
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 201 {
                        let result = try JSONDecoder().decode(UserSubData.self, from: data)
                        self.requestState = .success
                        self.userSubs.append(result)
                    } else {
                        let result = try JSONDecoder().decode(ErrorData.self, from: data)
                        self.errorData = result
                        self.requestState = .error
                    }
                }
            } catch {
                print("Error fetching data: \(error)")
                self.requestState = .error
                self.errorData = ErrorData(code: "FETCH_ERROR", message: "Error fetching data: \(error.localizedDescription)")
            }
        } catch {
            print("Error serializing JSON: \(error.localizedDescription)")
            self.requestState = .error
            self.errorData = ErrorData(code: "CATCH_ERROR", message: "Error serializing JSON: \(error.localizedDescription)")
        }
    }
    
    func updateUserSubById(userSub: UserSubData) async {
        self.errorData = nil
        self.requestState = .pending
        
        guard let url = URL(string: baseUrl + "/userSubs/\(userSub.id)") else { return }
        
        let body: [String: Any] = ["name": userSub.name, "level": userSub.level, "applicationId": userSub.applicationId]
        
        do {
            let finalData = try JSONSerialization.data(withJSONObject: body)
            
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.httpBody = finalData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(self.accountData!.token)", forHTTPHeaderField: "Authorization")
            
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                self.requestState = .sent
                
//                let responseString = String(data: data, encoding: .utf8)
//                print("Raw Response Data:\n\(responseString ?? "Empty")")
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 204 {
                        self.requestState = .success
                    } else {
                        let result = try JSONDecoder().decode(ErrorData.self, from: data)
                        self.errorData = result
                        self.requestState = .error
                    }
                }
            } catch {
                print("Error fetching data: \(error)")
                self.requestState = .error
                self.errorData = ErrorData(code: "FETCH_ERROR", message: "Error fetching data: \(error.localizedDescription)")
            }
        } catch {
            print("Error serializing JSON: \(error.localizedDescription)")
            self.requestState = .error
            self.errorData = ErrorData(code: "CATCH_ERROR", message: "Error serializing JSON: \(error.localizedDescription)")
        }
    }
    
    func deleteUserSubById(userSubId: Int) async {
        self.errorData = nil
        self.requestState = .pending
        
        guard let url = URL(string: baseUrl + "/userSubs/\(userSubId)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(self.accountData!.token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            self.requestState = .sent
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 204 {
                    self.requestState = .success
                    if let index = self.userSubs.firstIndex(where: { $0.id == userSubId }) {
                        self.userSubs.remove(at: index)
                    }
                } else {
                    let result = try JSONDecoder().decode(ErrorData.self, from: data)
                    self.errorData = result
                    self.requestState = .error
                }
            }
        } catch {
            print("Error fetching data: \(error)")
            self.requestState = .error
            self.errorData = ErrorData(code: "FETCH_ERROR", message: "Error fetching data: \(error.localizedDescription)")
        }
    }
    
    
    // MARK: - License request functions
    
    func getLicensesOfApplication(applicationId: String) async {
        self.errorData = nil
        self.requestState = .pending
        
        guard let url = URL(string: baseUrl + "/licenses/\(applicationId)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(self.accountData!.token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            self.requestState = .sent
//                      let responseString = String(data: data, encoding: .utf8)
//                      print("Raw Response Data:\n\(responseString ?? "Empty")")
            
            if let httpResponse = response as? HTTPURLResponse {
//                          print("HTTP Status Code: \(httpResponse.statusCode)")
//                          print("Response Headers: \(httpResponse.allHeaderFields)")
                if httpResponse.statusCode == 200 {
                    let decoder = JSONDecoder()
                    let results = try decoder.decode([LicenseData].self, from: data)
                    self.requestState = .success
                    self.licenses = results
                } else {
                    let result = try JSONDecoder().decode(ErrorData.self, from: data)
                    self.errorData = result
                    self.requestState = .error
                }
            }
        } catch {
            print("Error decoding data: \(error)")
            self.requestState = .error
            self.errorData = ErrorData(code: "CATCH_ERROR", message: "Error decoding data: \(error.localizedDescription)")
        }
    }
    
    func createLicense(days: Int, format: String, amount: Int, subscription: Int, applicationId: String) async {
        self.errorData = nil
        self.requestState = .pending
        
        guard let url = URL(string: baseUrl + "/licenses") else { return }
        
        let body: [String: Any] = ["days": days, "format": format, "amount": amount, "subscription": subscription, "applicationId": applicationId]
        
        do {
            let finalData = try JSONSerialization.data(withJSONObject: body)
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = finalData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(self.accountData!.token)", forHTTPHeaderField: "Authorization")
            
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                self.requestState = .sent
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 201 {
                        let results = try JSONDecoder().decode([LicenseData].self, from: data)
                        self.requestState = .success
                        for result in results {
                            self.licenses.append(result)
                        }
                    } else {
                        let result = try JSONDecoder().decode(ErrorData.self, from: data)
                        self.errorData = result
                        self.requestState = .error
                    }
                }
            } catch {
                print("Error fetching data: \(error)")
                self.requestState = .error
                self.errorData = ErrorData(code: "FETCH_ERROR", message: "Error fetching data: \(error.localizedDescription)")
            }
        } catch {
            print("Error serializing JSON: \(error.localizedDescription)")
            self.requestState = .error
            self.errorData = ErrorData(code: "CATCH_ERROR", message: "Error serializing JSON: \(error.localizedDescription)")
        }
    }
    
    func updateLicenseById(license: LicenseDataMutate) async {
        self.errorData = nil
        self.requestState = .pending
        
        guard let url = URL(string: baseUrl + "/licenses/\(license.id)") else { return }
        
        let body: [String: Any] = ["license": license.license, "days": license.days, "used": license.used, "enabled": license.enabled,
                                   "subscription": license.subscription]
        
        do {
            let finalData = try JSONSerialization.data(withJSONObject: body)
            
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.httpBody = finalData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(self.accountData!.token)", forHTTPHeaderField: "Authorization")
            
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                self.requestState = .sent
                
//                let responseString = String(data: data, encoding: .utf8)
//                print("Raw Response Data:\n\(responseString ?? "Empty")")
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 204 {
                        self.requestState = .success
                    } else {
                        let result = try JSONDecoder().decode(ErrorData.self, from: data)
                        self.errorData = result
                        self.requestState = .error
                    }
                }
            } catch {
                print("Error fetching data: \(error)")
                self.requestState = .error
                self.errorData = ErrorData(code: "FETCH_ERROR", message: "Error fetching data: \(error.localizedDescription)")
            }
        } catch {
            print("Error serializing JSON: \(error.localizedDescription)")
            self.requestState = .error
            self.errorData = ErrorData(code: "CATCH_ERROR", message: "Error serializing JSON: \(error.localizedDescription)")
        }
    }
    
    func deleteLicenseById(licenseId: String) async {
        self.errorData = nil
        self.requestState = .pending
        
        guard let url = URL(string: baseUrl + "/licenses/\(licenseId)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(self.accountData!.token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            self.requestState = .sent
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 204 {
                    self.requestState = .success
                    if let index = self.licenses.firstIndex(where: { $0.id == licenseId }) {
                        self.licenses.remove(at: index)
                    }
                } else {
                    let result = try JSONDecoder().decode(ErrorData.self, from: data)
                    self.errorData = result
                    self.requestState = .error
                }
            }
        } catch {
            print("Error fetching data: \(error)")
            self.requestState = .error
            self.errorData = ErrorData(code: "FETCH_ERROR", message: "Error fetching data: \(error.localizedDescription)")
        }
    }
    
    
    // MARK: - File request functions
    
    func getFilesOfApplication(applicationId: String) async {
        self.errorData = nil
        self.requestState = .pending
        
        guard let url = URL(string: baseUrl + "/files/app/\(applicationId)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(self.accountData!.token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            self.requestState = .sent
//                      let responseString = String(data: data, encoding: .utf8)
//                      print("Raw Response Data:\n\(responseString ?? "Empty")")
            
            if let httpResponse = response as? HTTPURLResponse {
//                          print("HTTP Status Code: \(httpResponse.statusCode)")
//                          print("Response Headers: \(httpResponse.allHeaderFields)")
                if httpResponse.statusCode == 200 {
                    let decoder = JSONDecoder()
                    let results = try decoder.decode([FileData].self, from: data)
                    self.requestState = .success
                    self.files = results
                } else {
                    let result = try JSONDecoder().decode(ErrorData.self, from: data)
                    self.errorData = result
                    self.requestState = .error
                }
            }
        } catch {
            print("Error decoding data: \(error)")
            self.requestState = .error
            self.errorData = ErrorData(code: "CATCH_ERROR", message: "Error decoding data: \(error.localizedDescription)")
        }
    }
    
    func createFile(applicationId: String) async {
        self.errorData = nil
        self.requestState = .pending
        
        guard let url = URL(string: baseUrl + "/files/upload/\(applicationId)") else { return }
        
        let body: [String: Any] = ["file": "file"]
        
        do {
            let finalData = try JSONSerialization.data(withJSONObject: body)
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = finalData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(self.accountData!.token)", forHTTPHeaderField: "Authorization")
            
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                self.requestState = .sent
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 201 {
                        let result = try JSONDecoder().decode(FileData.self, from: data)
                        self.requestState = .success
                        self.files.append(result)
                    } else {
                        let result = try JSONDecoder().decode(ErrorData.self, from: data)
                        self.errorData = result
                        self.requestState = .error
                    }
                }
            } catch {
                print("Error fetching data: \(error)")
                self.requestState = .error
                self.errorData = ErrorData(code: "FETCH_ERROR", message: "Error fetching data: \(error.localizedDescription)")
            }
        } catch {
            print("Error serializing JSON: \(error.localizedDescription)")
            self.requestState = .error
            self.errorData = ErrorData(code: "CATCH_ERROR", message: "Error serializing JSON: \(error.localizedDescription)")
        }
    }
    
    func deleteFileById(fileId: String) async {
        self.errorData = nil
        self.requestState = .pending
        
        guard let url = URL(string: baseUrl + "/files/\(fileId)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(self.accountData!.token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            self.requestState = .sent
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 204 {
                    self.requestState = .success
                    if let index = self.files.firstIndex(where: { $0.id == fileId }) {
                        self.files.remove(at: index)
                    }
                } else {
                    let result = try JSONDecoder().decode(ErrorData.self, from: data)
                    self.errorData = result
                    self.requestState = .error
                }
            }
        } catch {
            print("Error fetching data: \(error)")
            self.requestState = .error
            self.errorData = ErrorData(code: "FETCH_ERROR", message: "Error fetching data: \(error.localizedDescription)")
        }
    }
    
    
    // MARK: - AppLog request functions
    
    func getAppLogsOfApplication(applicationId: String) async {
        self.errorData = nil
        self.requestState = .pending
        
        guard let url = URL(string: baseUrl + "/appLogs/\(applicationId)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(self.accountData!.token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            self.requestState = .sent
//                      let responseString = String(data: data, encoding: .utf8)
//                      print("Raw Response Data:\n\(responseString ?? "Empty")")
            
            if let httpResponse = response as? HTTPURLResponse {
//                          print("HTTP Status Code: \(httpResponse.statusCode)")
//                          print("Response Headers: \(httpResponse.allHeaderFields)")
                if httpResponse.statusCode == 200 {
                    let decoder = JSONDecoder()
                    let results = try decoder.decode([AppLogData].self, from: data)
                    self.requestState = .success
                    self.appLogs = results
                } else {
                    let result = try JSONDecoder().decode(ErrorData.self, from: data)
                    self.errorData = result
                    self.requestState = .error
                }
            }
        } catch {
            print("Error decoding data: \(error)")
            self.requestState = .error
            self.errorData = ErrorData(code: "CATCH_ERROR", message: "Error decoding data: \(error.localizedDescription)")
        }
    }
    
    func deleteAppLogById(appLogId: Int) async {
        self.errorData = nil
        self.requestState = .pending
        
        guard let url = URL(string: baseUrl + "/appLogs/\(appLogId)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(self.accountData!.token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            self.requestState = .sent
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 204 {
                    self.requestState = .success
                    if let index = self.appLogs.firstIndex(where: { $0.id == appLogId }) {
                        self.appLogs.remove(at: index)
                    }
                } else {
                    let result = try JSONDecoder().decode(ErrorData.self, from: data)
                    self.errorData = result
                    self.requestState = .error
                }
            }
        } catch {
            print("Error fetching data: \(error)")
            self.requestState = .error
            self.errorData = ErrorData(code: "FETCH_ERROR", message: "Error fetching data: \(error.localizedDescription)")
        }
    }
}
