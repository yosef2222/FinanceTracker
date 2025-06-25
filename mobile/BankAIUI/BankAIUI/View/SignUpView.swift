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
            
            VStack(spacing: 24) {
                CustomTF(sfIcon: "at", hint: "Email ID", value: $emailID)
                
                CustomTF(sfIcon: "person", hint: "Full Name",  value: $fullName)
                    .padding(.top, 5)
                
                CustomTF(sfIcon: "lock", hint: "Password", IsPassword: true,  value: $password)
                    .padding(.top, 5)
                
                GradientButton(title: "Continue", icon: "arrow.right") {
                    showQuestionnaire = true
                }
                .hSpacing(.trailing)
                .disableWithOpacity(emailID.isEmpty || password.isEmpty || fullName.isEmpty)
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
}

// MARK: - Questionnaire Views

struct QuestionnaireView: View {
    let completion: () -> Void
    @State private var currentStep: Int = 1
    @State private var monthlyIncome: String = ""
    @State private var hasLoans: Bool = false
    @State private var hasSaving: Bool = false
    @State private var savingsGoal: String = ""
    @State private var savingsGoalTimePlan: String = ""
    @State private var savingsGoalTime: String = ""
    @State private var investmentExperience: String = ""
    @State private var financialGoal: String = ""
    @Binding var showMainScreen: Bool
    
    init(showMainScreen: Binding<Bool>, completion: @escaping () -> Void) {
        self._showMainScreen = showMainScreen
        self.completion = completion
    }
    
    var body: some View {
        VStack {
            
            TabView(selection: $currentStep) {
                // Шаг 1 - Финансовая цель
                QuestionView(
                    question: "Какая у вас основная финансовая цель?",
                    options: ["Накопления", "Инвестиции", "Погашение долгов", "Пенсия, создание подушки безопасности"],
                    selectedOption: $financialGoal,
                    nextAction: { currentStep = 2 }
                )
                .tag(1)
                
                // Шаг 2 - Сроки
                QuestionView(
                    question: "Какие вы сроки ставите(напиши кол-во месяцев)?",
                    input: $savingsGoalTime,
                    isNumberInput: true,
                    nextAction: { currentStep = 3 }
                )
                .tag(2)
                
                // Шаг 3 - Кредиты
                QuestionView(
                    question: "Имеете ли вы кредиты/ипотеку?",
                    isBooleanQuestion: true,
                    booleanValue: $hasLoans,
                    nextAction: { currentStep = hasLoans ? 4 : 5 }
                )
                .tag(3)
                
                // Шаг 4 - Сбережения (если есть кредиты)
                QuestionView(
                    question: "Сколько денег вы должны накопить?",
                    input: $savingsGoal,
                    isNumberInput: true,
                    nextAction: { currentStep = 5 }
                )
                .tag(4)
                
                // Шаг 5 - Подушка безопасности
                QuestionView(
                    question: "Есть ли у вас финансовая подушка безопасности?",
                    isBooleanQuestion: true,
                    booleanValue: $hasSaving,
                    nextAction: { currentStep = hasSaving ? 6 : 7 }
                )
                .tag(5)
                
                // Шаг 6 - Срок подушки (если есть)
                QuestionView(
                    question: "На сколько месяцев жизни её хватит?",
                    input: $savingsGoalTimePlan,
                    isNumberInput: true,
                    nextAction: { currentStep = 7 }
                )
                .tag(6)

                // Шаг 7 - Доход (последний шаг)
                QuestionView(
                    question: "Сколько вы зарабатываете в месяц?",
                    input: $monthlyIncome,
                    isNumberInput: true,
                    nextAction: {
                        // Здесь вызываем completion И устанавливаем showMainScreen
                        showMainScreen = true
                        completion()
                    }
                )
                .tag(7)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            ProgressBar(currentStep: currentStep, totalSteps: 7)
                .padding(.horizontal)
                .padding(.bottom, 20)
        }
    }
}

struct ProgressBar: View {
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width, height: 6)
                    .opacity(0.3)
                    .foregroundColor(.gray)
                
                Rectangle()
                    .frame(
                        width: min(CGFloat(currentStep) / CGFloat(totalSteps) * geometry.size.width, geometry.size.width),
                        height: 6
                    )
                    .foregroundColor(.appBlue)
                    .animation(.linear, value: currentStep)
            }
            .cornerRadius(3)
        }
        .frame(height: 6)
    }
}

struct QuestionView: View {
    let question: String
    @Binding var input: String
    var isNumberInput: Bool = false
    var isBooleanQuestion: Bool = false
    @Binding var booleanValue: Bool
    var options: [String]?
    @Binding var selectedOption: String
    let nextAction: () -> Void
    
    // Основной инициализатор
    init(
        question: String,
        input: Binding<String> = .constant(""),
        isNumberInput: Bool = false,
        isBooleanQuestion: Bool = false,
        booleanValue: Binding<Bool> = .constant(false),
        options: [String]? = nil,
        selectedOption: Binding<String> = .constant(""),
        nextAction: @escaping () -> Void
    ) {
        self.question = question
        self._input = input
        self.isNumberInput = isNumberInput
        self.isBooleanQuestion = isBooleanQuestion
        self._booleanValue = booleanValue
        self.options = options
        self._selectedOption = selectedOption
        self.nextAction = nextAction
    }
    
    // Упрощенный инициализатор для текстовых вопросов
    init(
        question: String,
        input: Binding<String>,
        isNumberInput: Bool = false,
        nextAction: @escaping () -> Void
    ) {
        self.init(
            question: question,
            input: input,
            isNumberInput: isNumberInput,
            isBooleanQuestion: false,
            booleanValue: .constant(false),
            options: nil,
            selectedOption: .constant(""),
            nextAction: nextAction
        )
    }
    
    // Упрощенный инициализатор для вопросов да/нет
    init(
        question: String,
        isBooleanQuestion: Bool,
        booleanValue: Binding<Bool>,
        nextAction: @escaping () -> Void
    ) {
        self.init(
            question: question,
            input: .constant(""),
            isNumberInput: false,
            isBooleanQuestion: isBooleanQuestion,
            booleanValue: booleanValue,
            options: nil,
            selectedOption: .constant(""),
            nextAction: nextAction
        )
    }
    
    // Упрощенный инициализатор для вопросов с вариантами
    init(
        question: String,
        options: [String],
        selectedOption: Binding<String>,
        nextAction: @escaping () -> Void
    ) {
        self.init(
            question: question,
            input: .constant(""),
            isNumberInput: false,
            isBooleanQuestion: false,
            booleanValue: .constant(false),
            options: options,
            selectedOption: selectedOption,
            nextAction: nextAction
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(question)
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.bottom, 20)
            
            if isBooleanQuestion {
                HStack(spacing: 20) {
                    Button(action: {
                        booleanValue = true
                        nextAction()
                    }) {
                        Text("Да")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(booleanValue ? Color.appBlue : Color.gray.opacity(0.2))
                            .foregroundColor(booleanValue ? .white : .primary)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        booleanValue = false
                        nextAction()
                    }) {
                        Text("Нет")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(!booleanValue ? Color.appBlue : Color.gray.opacity(0.2))
                            .foregroundColor(!booleanValue ? .white : .primary)
                            .cornerRadius(10)
                    }
                }
            } else if let options = options {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        selectedOption = option
                        nextAction()
                    }) {
                        Text(option)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedOption == option ? Color.appBlue : Color.gray.opacity(0.2))
                            .foregroundColor(selectedOption == option ? .white : .primary)
                            .cornerRadius(10)
                    }
                }
            } else {
                TextField(isNumberInput ? "Введите сумму" : "Введите ответ", text: $input)
                    .keyboardType(isNumberInput ? .decimalPad : .default)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.bottom, 20)
                
                Button(action: nextAction) {
                    HStack {
                        Text("Далее")
                        Image(systemName: "arrow.right")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.appBlue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(input.isEmpty)
                .opacity(input.isEmpty ? 0.6 : 1)
            }
            
            Spacer()
        }
        .padding()
    }
}

struct FinalStepView: View {
    let completion: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("Регистрация завершена!")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Спасибо за ответы. Теперь мы можем предложить вам персонализированные рекомендации.")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
            
            Button(action: completion) {
                Text("Начать использовать приложение")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.appBlue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 30)
        }
        .padding()
    }
}
