//
//  NetworkManager.swift
//  BankAIUI
//
//  Created by Gleb Korotkov on 30.06.2025.
//


import Alamofire
import Foundation
import SwiftUICore



enum AuthError: Error {
    case notAuthenticated
    case tokenExpired
    case invalidCredentials
}

class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = "http://localhost:5163"
    
    private init() {}
    
    // MARK: - Авторизация
    
    func login(email: String, password: String, completion: @escaping (Result<AuthResponse, Error>) -> Void) {
        let url = "\(baseURL)/api/Auth/login"
        let request = LoginRequest(email: email, password: password)
        
        AF.request(url, method: .post, parameters: request, encoder: JSONParameterEncoder.default)
            .validate()
            .responseDecodable(of: AuthResponse.self) { response in
                switch response.result {
                case .success(let authResponse):
                    if let token = authResponse.token {
                        self.saveToken(token)
                        completion(.success(authResponse))
                    } else {
                        let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: authResponse.error ?? "Unknown error"])
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    // MARK: - Регистрация
    
    func register(fullName: String, email: String, password: String, completion: @escaping (Result<AuthResponse, Error>) -> Void) {
        let url = "\(baseURL)/api/Auth/register"
        let request = RegisterRequest(fullName: fullName, email: email, password: password)
        
        AF.request(url, method: .post, parameters: request, encoder: JSONParameterEncoder.default)
            .validate()
            .responseDecodable(of: AuthResponse.self) { response in
                switch response.result {
                case .success(let authResponse):
                    if let token = authResponse.token {
                        // Сохраняем токен
                        self.saveToken(token)
                        completion(.success(authResponse))
                    } else {
                        let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: authResponse.error ?? "Unknown error"])
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    // MARK: - Обновление профиля
    
    func updateProfile(salary: Int, cushion: Int, financialGoal: String, financialGoalAmount: Int, financialGoalMonths: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = "\(baseURL)/api/Auth/profile"
        let request = ProfileUpdateRequest(
            salary: salary,
            cushion: cushion,
            financialGoal: financialGoal,
            financialGoalAmount: financialGoalAmount,
            financialGoalMonths: financialGoalMonths
        )
        
        guard let token = getToken() else {
            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
            completion(.failure(error))
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)"
        ]
        
        AF.request(url, method: .put, parameters: request, encoder: JSONParameterEncoder.default, headers: headers)
            .validate()
            .response { response in
                switch response.result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    func sendTransactionPrompt(_ prompt: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = "\(baseURL)/api/ai/parse-transaction"
        
        guard let token = getToken() else {
            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
            completion(.failure(error))
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        
        let parameters: [String: Any] = [
            "prompt": prompt
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .response { response in
                switch response.result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    func fetchProfile(completion: @escaping (Result<ProfileResponse, Error>) -> Void) {
        let url = "\(baseURL)/api/Auth/profile"
        
        guard let token = getToken() else {
            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
            completion(.failure(error))
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)"
        ]
        
        AF.request(url, method: .get, headers: headers)
            .validate()
            .responseDecodable(of: ProfileResponse.self) { response in
                switch response.result {
                case .success(let profile):
                    completion(.success(profile))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    func getExpensesByCategory(completion: @escaping (Result<[ExpenseItem], Error>) -> Void) {
        let url = "\(baseURL)/api/transactions"
        
        guard let token = getToken() else {
            completion(.failure(AuthError.notAuthenticated))
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Accept": "application/json"
        ]
        
        print("Sending request to: \(url)") // 1. Логируем URL
        
        AF.request(url, method: .get, headers: headers)
            .validate()
            .responseData { response in
                print("Received response: \(response)") // 2. Логируем весь ответ
                
                switch response.result {
                case .success(let data):
                    do {
                        // 3. Выводим сырой JSON для проверки
                        if let jsonString = String(data: data, encoding: .utf8) {
                            print("Raw JSON response: \(jsonString)")
                        }
                        
                        let decoder = JSONDecoder()
                        let transactions = try decoder.decode([Transaction].self, from: data)
                        print("Decoded \(transactions.count) transactions") // 4. Количество транзакций
                        
                        // 5. Проверяем суммы транзакций
                        transactions.forEach { print("ID: \($0.id), Amount: \($0.amount), Category: \($0.category.name)") }
                        
                        // Группировка с расширенной диагностикой
                        let groupedDict = Dictionary(grouping: transactions, by: { $0.category.name })
                        print("Found \(groupedDict.count) categories") // 6. Количество категорий
                        
                        let expenseItems = groupedDict.map { (name, transactions) in
                            let total = transactions.reduce(0) { $0 + $1.amount }
                            print("Category '\(name)': \(transactions.count) transactions, total: \(total)") // 7. Сумма по категории
                            return ExpenseItem(
                                name: name,
                                value: Double(total),
                                color: self.getColorForCategory(categoryName: name))
                        }
                        
                        print("Generated \(expenseItems.count) expense items") // 8. Итоговое количество
                        completion(.success(expenseItems))
                        
                    } catch {
                        print("Decoding failed: \(error)") // 9. Ошибки декодирования
                        completion(.failure(error))
                    }
                    
                case .failure(let error):
                    print("Request failed: \(error.localizedDescription)") // 10. Ошибки запроса
                    if response.response?.statusCode == 401 {
                        self.logout()
                        completion(.failure(AuthError.tokenExpired))
                    } else {
                        completion(.failure(error))
                    }
                }
            }
    }
    
    private func getColorForCategory(categoryName: String) -> Color {
        switch categoryName.lowercased() {
        case "food":
            return .blueStats1
        case "transport":
            return .blueStats2
        case "housing", "жилье":
            return .blueStats3
        case "other":
            return .blueStats4
        default:
            return .gray
        }
    }
    
    // MARK: - Работа с токеном
    
    private func saveToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: "authToken")
    }
    
    func getToken() -> String? {
        return UserDefaults.standard.string(forKey: "authToken")
    }
    
    func isLoggedIn() -> Bool {
        return getToken() != nil
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: "authToken")
    }
}


