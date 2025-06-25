//
//  MainView.swift
//  BankAIUI
//
//  Created by Gleb Korotkov on 15.06.2025.
//

import SwiftUI
import Speech
import AVFoundation


struct MainView: View {
    @State private var selectedTab: Tab = .home
    
    enum Tab {
        case home
        case stats
        case profile
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Главная", systemImage: "house.fill")
                }
                .tag(Tab.home)
            
            StatsView()
                .tabItem {
                    Label("Статистика", systemImage: "chart.bar.fill")
                }
                .tag(Tab.stats)
            
            ProfileView()
                .tabItem {
                    Label("Профиль", systemImage: "person.fill")
                }
                .tag(Tab.profile)
        }
        .accentColor(.appBlue) // Цвет выделения
    }
}


