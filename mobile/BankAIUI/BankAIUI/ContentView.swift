//
//  ContentView.swift
//  BankAIUI
//
//  Created by Gleb Korotkov on 13.06.2025.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State private var showSignup: Bool = false
    @State private var showMainScreen: Bool = false
    
    var body: some View {
        NavigationStack {
            LoginView(showSignup: $showSignup, showMainScreen: $showMainScreen)
                .navigationDestination(isPresented: $showSignup) {
                    SignUpView(showSignup: $showSignup, showMainScreen: $showMainScreen)
                }
                .navigationDestination(isPresented: $showMainScreen) {
                    MainView()
                        .navigationBarBackButtonHidden(true)
                }
        }
        .overlay{
            if !showMainScreen{
                CircleView()
                    .animation(.easeInOut(duration: 0.3), value: showSignup)
            }
        }
    }
    
    @ViewBuilder
    func CircleView() -> some View {
        Circle()
            .fill(.linearGradient(colors: [.appBlue, .appBlue, .blue], startPoint: .top, endPoint: .bottom))
            .frame(width: 200, height: 200)
            .offset(x: showSignup ? 90 : -90, y: -90)
            .blur(radius: 15)
            .hSpacing(showSignup ? .trailing : .leading)
            .vSpacing(.top)
    }
}

#Preview {
ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

