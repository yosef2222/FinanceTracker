//
//  SignUpView.swift
//  BankAIUI
//
//  Created by Gleb Korotkov on 14.06.2025.
//

import SwiftUI

struct SignUpView: View {
    @Binding var showSignup: Bool
    @Binding var showMainScreen: Bool
    
    @State private var emailID: String = ""
    @State private var fullName: String = ""
    @State private var password: String = ""
    @State private var showQuestionnaire: Bool = false
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15, content:  {
            if !showQuestionnaire {
                registrationView
            } else {
                QuestionnaireView(showMainScreen: $showMainScreen) {
                    showQuestionnaire = false
                }
                .transition(.move(edge: .trailing))
            }
        })
        .padding(.vertical, 15)
        .padding(.horizontal, 25)
        .toolbar(.hidden, for: .navigationBar)
        .animation(.easeInOut, value: showQuestionnaire)
    }
    
    private var registrationView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Button(action: {
                showSignup = false
            }, label: {
                Image(systemName: "arrow.left")
                    .font(.title2)
                    .foregroundStyle(.gray)
            })
            .padding(.top, 10)
            
            Text("SignUp")
                .font(.largeTitle)
                .fontWeight(.heavy)
                .padding(.top, 25)
            
            Text("Please sign up to continue")
                .font(.callout)
                .fontWeight(.semibold)
                .foregroundStyle(.gray)
                .padding(.top, -5)
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            VStack(spacing: 24) {
                CustomTF(sfIcon: "at", hint: "Email ID", value: $emailID)
                
                CustomTF(sfIcon: "person", hint: "Full Name",  value: $fullName)
                    .padding(.top, 5)
                
                CustomTF(sfIcon: "lock", hint: "Password", IsPassword: true,  value: $password)
                    .padding(.top, 5)
                
                if isLoading {
                    ProgressView()
                } else {
                    GradientButton(title: "Continue", icon: "arrow.right") {
                        registerUser()
                    }
                    .hSpacing(.trailing)
                    .disableWithOpacity(emailID.isEmpty || password.isEmpty || fullName.isEmpty)
                }
            }
            .padding(.top, 20)
            
            HStack(spacing: 6) {
                Text("Already have an account")
                
                Button("Login") {
                    showSignup.toggle()
                }
                .fontWeight(.bold)
                .tint(.appBlue)
            }
            .font(.callout)
            .hSpacing()
            
            Spacer(minLength: 0)
        }
    }
    
    private func registerUser() {
        isLoading = true
        errorMessage = nil
        
        NetworkManager.shared.register(
            fullName: password, email: fullName,
            password: emailID
        ) { result in
            isLoading = false
            
            switch result {
            case .success:
                showQuestionnaire = true
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
}



