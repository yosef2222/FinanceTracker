//
//  AudioRecorder.swift
//  BankAIUI
//
//  Created by Gleb Korotkov on 21.06.2025.
//
import SwiftUI
import AVFoundation
import Speech

class AudioRecorderViewModel: ObservableObject {
    @Published var isVoiceMode = true
    @Published var messageText = ""
    @Published var isRecording = false
    @Published var lastError = ""
    @Published var showAlert = false
    @Published var isEditingText = false
    
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ru-RU"))!
    
    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    func startEditing() {
        isEditingText = true
    }
    
    func endEditing() {
        isEditingText = false
    }
    
    func requestPermissions() {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                if status != .authorized {
                    self?.lastError = "Разрешение на распознавание речи не предоставлено"
                    self?.showAlert = true
                }
            }
        }
        
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                if !granted {
                    self?.lastError = "Разрешение на доступ к микрофону не предоставлено"
                    self?.showAlert = true
                }
            }
        }
    }
    
    private func startRecording() {
        // Останавливаем предыдущую запись, если она активна
        if isRecording {
            stopRecording()
        }
        
        DispatchQueue.main.async {
            self.messageText = ""
            self.lastError = ""
            self.isRecording = true
            self.isEditingText = false
        }
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            handleError("Ошибка настройки аудиосессии: \(error.localizedDescription)")
            return
        }
        
        recognitionTask?.cancel()
        recognitionTask = nil
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            handleError("Не удалось создать запрос распознавания")
            return
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        let inputNode = audioEngine.inputNode
        inputNode.removeTap(onBus: 0)
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            handleError("Ошибка запуска аудиодвижка: \(error.localizedDescription)")
            return
        }
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                if self.isRecording {
                    self.handleError("Ошибка распознавания: \(error.localizedDescription)")
                    self.stopRecording()
                }
                return
            }
            
            if let result = result {
                DispatchQueue.main.async {
                    self.messageText = result.bestTranscription.formattedString
                }
                
                if result.isFinal {
                    self.stopRecording()
                }
            }
        }
    }
    
    private func stopRecording() {
        guard isRecording else { return }
        
        DispatchQueue.main.async {
            self.isRecording = false
            self.isEditingText = true
        }
        
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        
        recognitionTask?.cancel()
        recognitionTask = nil
        
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            handleError("Ошибка деактивации аудиосессии: \(error.localizedDescription)")
        }
    }
    
    private func handleError(_ message: String) {
        DispatchQueue.main.async {
            self.lastError = message
            self.showAlert = true
            self.isRecording = false
        }
    }
    
    func sendMessage() {
        guard !messageText.isEmpty else { return }
        
        if isRecording {
            stopRecording()
        }
        
        NetworkManager.shared.sendTransactionPrompt(messageText) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("Текст успешно отправлен: \(self?.messageText ?? "")")
                    self?.messageText = ""
                    self?.isEditingText = false
                    
                case .failure(let error):
                    print("Ошибка отправки: \(error.localizedDescription)")
                    self?.lastError = "Ошибка отправки: \(error.localizedDescription)"
                    self?.showAlert = true
                }
            }
        }
    }
}

struct HomeView: View {
    @StateObject private var viewModel = AudioRecorderViewModel()
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    VStack(spacing: 20) {
                        Text("BankAI")
                            .font(.largeTitle.bold())
                            .padding(.top)
                        
                        if !viewModel.lastError.isEmpty {
                            Text("Ошибка: \(viewModel.lastError)")
                                .foregroundColor(.red)
                                .padding()
                        }
                        
                        // Поле для текста с возможностью редактирования
                        if viewModel.isVoiceMode {
                            if viewModel.isEditingText || !viewModel.messageText.isEmpty {
                                TextEditor(text: $viewModel.messageText)
                                    .frame(minHeight: 100, maxHeight: 200)
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(10)
                                    .padding(.horizontal)
                                    .focused($isTextFieldFocused)
                                    .onTapGesture {
                                        viewModel.startEditing()
                                        isTextFieldFocused = true
                                    }
                            } else {
                                Text("Нажмите на микрофон, чтобы начать запись")
                                    .foregroundColor(.gray)
                                    .padding()
                                    .frame(maxWidth: .infinity, minHeight: 100)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(10)
                                    .padding(.horizontal)
                            }
                        } else {
                            TextEditor(text: $viewModel.messageText)
                                .frame(minHeight: 100, maxHeight: 200)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                                .padding(.horizontal)
                                .focused($isTextFieldFocused)
                        }
                        
                        Spacer()
                    }
                }
                
                VStack(spacing: 16) {
                    Toggle(isOn: $viewModel.isVoiceMode) {
                        Text(viewModel.isVoiceMode ? "Голосовой режим" : "Текстовый режим")
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                    .padding(.horizontal)
                    
                    if viewModel.isVoiceMode {
                        HStack(spacing: 20) {
                            Button(action: viewModel.toggleRecording) {
                                Image(systemName: viewModel.isRecording ? "stop.fill" : "mic.fill")
                                    .font(.title)
                                    .foregroundColor(.white)
                                    .padding(20)
                                    .background(viewModel.isRecording ? Color.red : Color.blue)
                                    .clipShape(Circle())
                            }
                            
                            // Кнопка отправки (видна только когда есть текст)
                            if !viewModel.messageText.isEmpty {
                                Button(action: {
                                    viewModel.sendMessage()
                                }) {
                                    Text("Отправить")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding(.vertical, 12)
                                        .padding(.horizontal, 24)
                                        .background(Color.green)
                                        .cornerRadius(25)
                                }
                                .transition(.opacity)
                            }
                        }
                        .padding(.bottom)
                    } else {
                        // В текстовом режиме - только кнопка отправки
                        if !viewModel.messageText.isEmpty {
                            Button(action: viewModel.sendMessage) {
                                Text("Отправить")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green)
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal)
                            .padding(.bottom)
                        }
                    }
                }
                .background(Color(.systemBackground))
                .animation(.easeInOut, value: viewModel.messageText.isEmpty)
            }
            .navigationTitle("Главная")
            .onAppear {
                viewModel.requestPermissions()
            }
            .alert("Ошибка", isPresented: $viewModel.showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.lastError)
            }
            .onTapGesture {
                isTextFieldFocused = false
                viewModel.endEditing()
            }
        }
    }
}
