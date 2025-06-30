//
//  LoginRequest.swift
//  BankAIUI
//
//  Created by Gleb Korotkov on 30.06.2025.
//


import Foundation

// Модель для запроса входа
struct LoginRequest: Codable {
    let email: String
    let password: String
}

// Модель для запроса регистрации
struct RegisterRequest: Codable {
    let fullName: String
    let email: String
    let password: String
}

// Модель для обновления профиля
struct ProfileUpdateRequest: Codable {
    let salary: Int
    let cushion: Int
    let financialGoal: String
    let financialGoalAmount: Int
    let financialGoalMonths: Int
}

// Модель ответа с токеном
struct AuthResponse: Codable {
    let token: String?
    let error: String?
}

struct ProfileResponse: Codable {
    let fullName: String
    let email: String
    let salary: Int
    let cushion: Int
    let financialGoal: String?
    let financialGoalAmount: Int?
    let financialGoalMonths: Int?
}

struct Transaction: Decodable {
    let id: String
    let amount: Int
    let date: String
    let merchant: String?
    let description: String?
    let category: Category
    
    struct Category: Decodable {
        let id: String
        let name: String
        let color: String?
        let icon: String?
    }
}
