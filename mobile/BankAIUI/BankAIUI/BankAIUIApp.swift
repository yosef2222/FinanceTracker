//
//  BankAIUIApp.swift
//  BankAIUI
//
//  Created by Gleb Korotkov on 13.06.2025.
//

import SwiftUI

@main
struct BankAIApp: App {
    @StateObject private var authState = AuthState()
    
    var body: some Scene {
        WindowGroup {
            if authState.isAuthenticated {
                MainView()
            } else {
                ContentView()
            }
        }
    }
}
class AuthState: ObservableObject {
    @Published var isAuthenticated: Bool
    
    init() {
        let token = UserDefaults.standard.string(forKey: "authToken")
        self.isAuthenticated = token != nil
    }
}
