import Foundation

class AppViewModel: ObservableObject {
    @Published var accountData: AccountLoginData?
    @Published var applications: [ApplicationData] = []
    @Published var applicationData: ApplicationData?
    @Published var selectedAppId: String?
    @Published var isShowingDetailSheet: Bool = false
    @Published var generalChatMsgs: [ChatMessageData] = []
    @Published var individualAccountLogs: [LogData] = []
    @Published var users: [UserData] = []
    @Published var userSubs: [UserSubData] = []
    @Published var licenses: [LicenseData] = []
    @Published var requestState: RequestState = .none
    @Published var errorData: ErrorData?
    @Published var isAuthed: Bool = false
    private var baseUrl: String = "http://localhost:9000/api"
    
    // MARK: - Account request functions
    
    func login(username: String, password: String) async {
        self.errorData = nil
        self.requestState = .pending
        
        guard let url = URL(string: "http://localhost:9000/api/accounts/login") else { return }
        
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
                        self.accountData = result
                        self.requestState = .success
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
        
        guard let url = URL(string: "http://localhost:9000/api/accounts/\(id)") else { return }
        
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
                    self.accountData?.account = result
                    self.requestState = .success
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
        
        guard let url = URL(string: "http://localhost:9000/api/accounts/profilePicture/\(id)") else { return }
        
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
                    if httpResponse.statusCode == 200 {
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
        
        guard let url = URL(string: "http://localhost:9000/api/applications/byAccId/\(self.accountData!.account.id)") else { return }
        
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
                    self.applications = results
                    self.requestState = .success
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
        
        guard let url = URL(string: "http://localhost:9000/api/applications/\(application.id)") else { return }
        
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
                    if httpResponse.statusCode == 200 {
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
        
        guard let url = URL(string: "http://localhost:9000/api/applications/\(applicationId)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(self.accountData!.token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            self.requestState = .sent
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 204 {
                    if let index = self.applications.firstIndex(where: { $0.id == applicationId }) {
                        self.applications.remove(at: index)
                    }
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
    }
    
    func createApplication(name: String) async {
        self.errorData = nil
        self.requestState = .pending
        
        guard let url = URL(string: "http://localhost:9000/api/applications") else { return }
        
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
                        self.applications.append(result)
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
    
    func getApplicationById(id: String) async {
        self.errorData = nil
        self.requestState = .pending
        
        guard let url = URL(string: "http://localhost:9000/api/applications/byAppId/\(id)") else { return }
        
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
                    self.applicationData = result
                    self.requestState = .success
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
        
        guard let url = URL(string: "http://localhost:9000/api/chatMsgs/chat/\(id)") else { return }
        
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
                    self.generalChatMsgs = results
                    self.requestState = .success
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
        
        guard let url = URL(string: "http://localhost:9000/api/chatMsgs") else { return }
        
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
                        self.generalChatMsgs.append(result)
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
    
    func deleteChatMsgById(id: Int) async {
        self.errorData = nil
        self.requestState = .pending
        
        guard let url = URL(string: "http://localhost:9000/api/chatMsgs/\(id)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(self.accountData!.token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            self.requestState = .sent
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 204 {
                    if let index = generalChatMsgs.firstIndex(where: { $0.id == id }) {
                        generalChatMsgs.remove(at: index)
                    }
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
    }
    
    
    // MARK: - Log request functions
    
    func getLogsByUsername(username: String) async {
        self.errorData = nil
        self.requestState = .pending
        
        guard let url = URL(string: "http://localhost:9000/api/logs/\(username)") else { return }
        
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
                    self.individualAccountLogs = results
                    self.requestState = .success
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
        
        guard let url = URL(string: "http://localhost:9000/api/logs/\(id)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(self.accountData!.token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            self.requestState = .sent
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 204 {
                    if let index = individualAccountLogs.firstIndex(where: { $0.id == id }) {
                        individualAccountLogs.remove(at: index)
                    }
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
    }
    
    
    // MARK: - User request functions
    
    func getUsersOfApplication(applicationId: String) async {
        self.errorData = nil
        self.requestState = .pending
        
        guard let url = URL(string: "http://localhost:9000/api/users/\(applicationId)") else { return }
        
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
                    self.users = results
                    self.requestState = .success
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
        
        guard let url = URL(string: "http://localhost:9000/api/users/registerFromDashboard") else { return }
        
        let body: [String: Any] = ["username": username, "email": email, "password": password, "id": id, "expiry": expiry,
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
                        self.users.append(result)
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
    
    func updateUserById(user: UserDataMutate) async {
        self.errorData = nil
        self.requestState = .pending
        
        guard let url = URL(string: "http://localhost:9000/api/users/\(user.id)") else { return }
        
        let body: [String: Any] = ["username": user.username, "email": user.email, "expiryDate": user.expiryDate, "hwid": user.hwid,
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
                
                let responseString = String(data: data, encoding: .utf8)
                print("Raw Response Data:\n\(responseString ?? "Empty")")
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
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
        
        guard let url = URL(string: "http://localhost:9000/api/users/\(userId)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(self.accountData!.token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            self.requestState = .sent
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 204 {
                    if let index = self.users.firstIndex(where: { $0.id == userId }) {
                        self.users.remove(at: index)
                    }
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
    }

    
    
    // MARK: - UserSub request functions
    
    func getUserSubsOfApplication(applicationId: String) async {
        self.errorData = nil
        self.requestState = .pending
        
        guard let url = URL(string: "http://localhost:9000/api/userSubs/application/\(applicationId)") else { return }
        
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
                    self.userSubs = results
                    self.requestState = .success
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
    
    
    // MARK: - License request functions
    
    func getLicensesOfApplication(applicationId: String) async {
        self.errorData = nil
        self.requestState = .pending
        
        guard let url = URL(string: "http://localhost:9000/api/licenses/\(applicationId)") else { return }
        
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
                    self.licenses = results
                    self.requestState = .success
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
        
        guard let url = URL(string: "http://localhost:9000/api/licenses") else { return }
        
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
                        let result = try JSONDecoder().decode(LicenseData.self, from: data)
                        self.licenses.append(result)
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
    
    func updateLicenseById(license: LicenseDataMutate) async {
        self.errorData = nil
        self.requestState = .pending
        
        guard let url = URL(string: "http://localhost:9000/api/licenses/\(license.id)") else { return }
        
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
                
                let responseString = String(data: data, encoding: .utf8)
                print("Raw Response Data:\n\(responseString ?? "Empty")")
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
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
        
        guard let url = URL(string: "http://localhost:9000/api/users/\(licenseId)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(self.accountData!.token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            self.requestState = .sent
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 204 {
                    if let index = self.licenses.firstIndex(where: { $0.id == licenseId }) {
                        self.licenses.remove(at: index)
                    }
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
    }
}
