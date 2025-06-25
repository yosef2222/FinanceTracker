//
//  SwiftUIView.swift
//  BankAIUI
//
//  Created by Gleb Korotkov on 13.06.2025.
//

import SwiftUI

struct LoginView: View {
    @Binding var showSignup: Bool
    @Binding var showMainScreen: Bool
    @State private var emailID: String = ""
    @State private var password: String = ""
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
            VStack(spacing: 24) {
                CustomTF(sfIcon: "at", hint: "Email ID", value: $emailID)
                
                CustomTF(sfIcon: "lock", hint: "Password", IsPassword: true,  value: $password)
                    .padding(.top, 5)
                
                Button("Forgot Password?") {
                    
                }
                .font(.callout)
                .fontWeight(.heavy)
                .tint(.appBlue)
                .hSpacing(.trailing)
                
                GradientButton(title: "Login", icon: "arrow.right") {
                    if LoginTry(){
                        showMainScreen.toggle()
                    }
                }
                .hSpacing(.trailing)
                .disableWithOpacity(emailID.isEmpty || password.isEmpty)
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
}



func LoginTry() -> Bool{
    return true
}
