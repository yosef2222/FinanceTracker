//
//  AudioRecorder.swift
//  BankAIUI
//
//  Created by Gleb Korotkov on 21.06.2025.
//
import SwiftUI

struct HomeView: View {
    @State private var isVoiceMode = true
    @State private var messageText = ""
    @State private var isKeyboardVisible = false
    @State private var bottomPadding: CGFloat = 0
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    Text("BankAI")
                        .font(.largeTitle.bold())
                    VStack {
                        // Здесь может быть ваш основной контент
                        Spacer()
                        
                        // Переключатель режимов
                        Toggle(isOn: $isVoiceMode) {
                            Text(isVoiceMode ? "Голосовой режим" : "Текстовый режим")
                        }
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                        .padding()
                    }
                    .frame(maxHeight: .infinity)
                }
                
                // Нижняя панель ввода
                inputPanel
            }
            .navigationTitle("Главная")
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                withAnimation(.easeInOut(duration: 0.25)) {
                    isKeyboardVisible = true
                    bottomPadding = 10
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                withAnimation(.easeInOut(duration: 0.25)) {
                    isKeyboardVisible = false
                    bottomPadding = 0
                }
            }
        }
    }
    
    // Панель ввода (голос/текст)
    private var inputPanel: some View {
        VStack(spacing: 0) {
            if !isVoiceMode {
                // Текстовое поле
                HStack {
                    TextField("Введите сообщение...", text: $messageText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.blue)
                            .clipShape(Circle())
                    }
                    .padding(.trailing, 8)
                }
                .padding(.bottom, 60)
                .background(Color(.systemBackground))
                .transition(.move(edge: .bottom))
            } else {
                // Кнопка голосового ввода
                Button(action: startVoiceInput) {
                    Image(systemName: "mic.fill")
                        .foregroundColor(.white)
                        .padding(35)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
                .padding(.bottom, 60)
                .transition(.scale)
            }
        }
        .padding(.bottom, bottomPadding)
        .background(
            Color(.systemBackground)
                .edgesIgnoringSafeArea(.bottom)
        )
        .animation(.easeInOut, value: isVoiceMode)
    }
    
    private func startVoiceInput() {
        print("Голосовой ввод начат")
    }
    
    private func sendMessage() {
        print("Отправлено: \(messageText)")
        messageText = ""
        hideKeyboard()
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
