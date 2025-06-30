//
//  SwiftUIView.swift
//  BankAIUI
//
//  Created by Gleb Korotkov on 13.06.2025.
//

import SwiftUI
import Alamofire

struct LoginView: View {
    @Binding var showSignup: Bool
    @Binding var showMainScreen: Bool
    @State private var emailID: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15, content:  {
            Spacer(minLength: 0)
            
            Text("Login")
                .font(.largeTitle)
                .fontWeight(.heavy)
            
            Text("Please sign in to continue")
                .font(.callout)
                .fontWeight(.semibold)
                .foregroundStyle(.gray)
                .padding(.top, -5)
            
            // Отображение ошибки, если есть
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.vertical, 5)
            }
            
            VStack(spacing: 24) {
                CustomTF(sfIcon: "at", hint: "Email ID", value: $emailID)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                CustomTF(sfIcon: "lock", hint: "Password", IsPassword: true, value: $password)
                    .textContentType(.password)
                    .padding(.top, 5)
                
                Button("Forgot Password?") {
                    // TODO: Реализовать восстановление пароля
                }
                .font(.callout)
                .fontWeight(.heavy)
                .tint(.appBlue)
                .hSpacing(.trailing)
                
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    GradientButton(title: "Login", icon: "arrow.right") {
                        loginUser()
                    }
                    .hSpacing(.trailing)
                    .disableWithOpacity(emailID.isEmpty || password.isEmpty)
                }
            }
            .padding(.top, 20)
            
            HStack(spacing: 6) {
                Text("Don't have an account")
                
                Button("SignUP") {
                    showSignup.toggle()
                }
                .fontWeight(.bold)
                .tint(.appBlue)
            }
            .font(.callout)
            .hSpacing()
            
            Spacer(minLength: 0)
        })
        .padding(.vertical, 15)
        .padding(.horizontal, 25)
        .toolbar(.hidden, for: .navigationBar)
    }
    
    private func loginUser() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        isLoading = true
        errorMessage = nil
        
        NetworkManager.shared.login(
            email: emailID,
            password: password
        ) { result in
            isLoading = false
            
            switch result {
            case .success:
                // Успешный вход - переходим на главный экран
                withAnimation {
                    showMainScreen = true
                }
            case .failure(let error):
                // Обработка ошибок
                handleLoginError(error)
            }
        }
    }
    
    private func handleLoginError(_ error: Error) {
        if let afError = error as? AFError {
            switch afError {
            case .responseValidationFailed(reason: .unacceptableStatusCode(let code)):
                if code == 401 {
                    errorMessage = "Invalid email or password"
                } else {
                    errorMessage = "Server error. Please try again later."
                }
            default:
                errorMessage = "Network error. Please check your connection."
            }
        } else {
            errorMessage = error.localizedDescription
        }
    }
}
