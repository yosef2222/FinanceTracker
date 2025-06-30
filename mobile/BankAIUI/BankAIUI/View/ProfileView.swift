//
//  ProfileView.swift
//  BankAIUI
//
//  Created by Gleb Korotkov on 21.06.2025.
//

import SwiftUI 

import SwiftUI

struct ProfileView: View {
    @State private var user = UserProfile(
        fullName: "",
        email: "",
        salary: 0,
        currency: "₽"
    )
    
    @State private var isEditing = false
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var profileImage: Image?
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Заголовок
                Text("Мой профиль")
                    .font(.largeTitle.bold())
                    .padding(.top, 20)
                
                // Аватарка
                profileAvatar
                    .onTapGesture {
                        showingImagePicker = true
                    }
                
                if isLoading {
                    ProgressView()
                } else {
                    // Форма с данными
                    profileForm
                    
                    // Кнопка сохранения
                    if isEditing {
                        Button(action: saveProfile) {
                            Text("Сохранить изменения")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationBarTitle("Профиль", displayMode: .inline)
        .navigationBarItems(trailing: editButton)
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
            ImagePicker(image: $inputImage)
        }
        .alert("Ошибка", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            loadProfile()
            loadSavedImage()
        }
    }
    
    // MARK: - Компоненты
    
    private var profileAvatar: some View {
        ZStack {
            if let profileImage = profileImage {
                profileImage
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .foregroundColor(.gray)
            }
        }
        .frame(width: 120, height: 120)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.blue, lineWidth: 2))
        .overlay(
            Image(systemName: "pencil.circle.fill")
                .font(.title)
                .foregroundColor(.blue)
                .padding(4)
                .background(Color.white)
                .clipShape(Circle()),
            alignment: .bottomTrailing
        )
    }
    
    private var profileForm: some View {
        VStack(spacing: 15) {
            Group {
                HStack {
                    Text("Имя:")
                        .foregroundColor(.gray)
                    Spacer()
                    if isEditing {
                        TextField("Введите имя", text: $user.fullName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 200)
                    } else {
                        Text(user.fullName)
                    }
                }
                
                HStack {
                    Text("Email:")
                        .foregroundColor(.gray)
                    Spacer()
                    Text(user.email)
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Text("Зарплата:")
                        .foregroundColor(.gray)
                    Spacer()
                    if isEditing {
                        HStack {
                            TextField("Сумма", value: $user.salary, formatter: NumberFormatter())
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 120)
                                .keyboardType(.numberPad)
                            
                            Picker("Валюта", selection: $user.currency) {
                                Text("₽").tag("₽")
                                Text("$").tag("$")
                                Text("€").tag("€")
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .frame(width: 80)
                        }
                    } else {
                        Text("\(user.salary.formatted()) \(user.currency)")
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .padding(.horizontal)
    }
    
    private var editButton: some View {
        Button(action: {
            withAnimation {
                isEditing.toggle()
            }
        }) {
            Text(isEditing ? "Готово" : "Изменить")
        }
    }
    
    // MARK: - Функции
    
    private func loadProfile() {
        isLoading = true
        NetworkManager.shared.fetchProfile { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let profile):
                    self.user = UserProfile(
                        fullName: profile.fullName,
                        email: profile.email,
                        salary: profile.salary,
                        currency: "₽"
                    )
                case .failure(let error):
                    errorMessage = "Не удалось загрузить профиль: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
    
    private func loadImage() {
        guard let inputImage = inputImage else { return }
        profileImage = Image(uiImage: inputImage)
        
        // Сохраняем изображение в UserDefaults
        if let imageData = inputImage.jpegData(compressionQuality: 0.5) {
            UserDefaults.standard.set(imageData, forKey: "profileImage")
        }
    }
    
    private func loadSavedImage() {
        if let imageData = UserDefaults.standard.data(forKey: "profileImage"),
           let uiImage = UIImage(data: imageData) {
            profileImage = Image(uiImage: uiImage)
        }
    }
    
    private func saveProfile() {
        // Здесь можно добавить логику обновления профиля через API
        withAnimation {
            isEditing = false
        }
        
        // Обновляем профиль через API
        NetworkManager.shared.updateProfile(
            salary: user.salary,
            cushion: 0,
            financialGoal: "", 
            financialGoalAmount: 0,
            financialGoalMonths: 0
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("Профиль успешно обновлен")
                case .failure(let error):
                    errorMessage = "Ошибка при обновлении профиля: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
}

// MARK: - Модель данных
struct UserProfile {
    var fullName: String
    var email: String
    var salary: Int
    var currency: String
}


// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - Предварительный просмотр
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileView()
        }
        .previewDisplayName("Светлая тема")
        
        NavigationView {
            ProfileView()
        }
        .preferredColorScheme(.dark)
        .previewDisplayName("Темная тема")
    }
}
