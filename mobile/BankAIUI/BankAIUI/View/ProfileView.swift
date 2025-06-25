//
//  ProfileView.swift
//  BankAIUI
//
//  Created by Gleb Korotkov on 21.06.2025.
//

import SwiftUI 

struct ProfileView: View {
    @State private var user = UserProfile(
        firstName: "Иван",
        lastName: "Иванов",
        email: "ivan.ivanov@example.com",
        monthlySalary: 150000,
        currency: "₽"
    )
    
    @State private var isEditing = false
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var profileImage: Image?
    
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
                
                Spacer()
            }
            .padding()
        }
        .navigationBarTitle("Профиль", displayMode: .inline)
        .navigationBarItems(trailing: editButton)
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
            ImagePicker(image: $inputImage)
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
                        TextField("Введите имя", text: $user.firstName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 200)
                    } else {
                        Text(user.firstName)
                    }
                }
                
                HStack {
                    Text("Фамилия:")
                        .foregroundColor(.gray)
                    Spacer()
                    if isEditing {
                        TextField("Введите фамилию", text: $user.lastName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 200)
                    } else {
                        Text(user.lastName)
                    }
                }
                
                HStack {
                    Text("Email:")
                        .foregroundColor(.gray)
                    Spacer()
                    if isEditing {
                        TextField("Введите email", text: $user.email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 200)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    } else {
                        Text(user.email)
                    }
                }
                
                HStack {
                    Text("Зарплата:")
                        .foregroundColor(.gray)
                    Spacer()
                    if isEditing {
                        HStack {
                            TextField("Сумма", value: $user.monthlySalary, formatter: NumberFormatter())
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
                        Text("\(user.monthlySalary.formatted()) \(user.currency)")
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
    
    private func loadImage() {
        guard let inputImage = inputImage else { return }
        profileImage = Image(uiImage: inputImage)
    }
    
    private func saveProfile() {
        // Здесь можно добавить логику сохранения в базу данных
        withAnimation {
            isEditing = false
        }
    }
}

// MARK: - Модель данных
struct UserProfile {
    var firstName: String
    var lastName: String
    var email: String
    var monthlySalary: Double
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
