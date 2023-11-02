import Foundation

class AppViewModel: ObservableObject {
    @Published var accountData: AccountData?
    @Published var applications: [ApplicationData] = []
    @Published var requestState: RequestState = .none
    @Published var errorData: ErrorData?
    @Published var isAuthed: Bool = false
    private var baseUrl: String = "http://localhost:9000/api"
    
    func login(username: String, password: String) async {
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
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        let result = try JSONDecoder().decode(AccountData.self, from: data)
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
                    print(results)
                    self.applications = results
                    self.requestState = .success
//                    let result = try JSONDecoder().decode(ApplicationData.self, from: data)
//                    self.applications.append(result)
//                    self.requestState = .success
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
}
