//
//  QuestionnaireView.swift
//  BankAIUI
//
//  Created by Gleb Korotkov on 30.06.2025.
//

import SwiftUI
import Alamofire

struct QuestionnaireView: View {
    let completion: () -> Void
    @State private var currentStep: Int = 1
    @State private var monthlyIncome: String = ""
    @State private var hasLoans: Bool = false
    @State private var hasSaving: Bool = false
    @State private var loanAmount: String = ""
    @State private var cushionMonths: String = ""
    @State private var financialGoal: String = ""
    @State private var goalAmount: String = ""
    @State private var goalTime: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @Binding var showMainScreen: Bool
    
    private let financialGoalOptions = [
        "Накопления",
        "Инвестиции",
        "Погашение долгов",
        "Пенсия, создание подушки безопасности"
    ]
    
    init(showMainScreen: Binding<Bool>, completion: @escaping () -> Void) {
        self._showMainScreen = showMainScreen
        self.completion = completion
    }
    
    var body: some View {
        ZStack {
            VStack {
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding()
                }
                
                TabView(selection: $currentStep) {
                    // Шаг 1 - Финансовая цель
                    QuestionView(
                        question: "Какая у вас основная финансовая цель?",
                        options: financialGoalOptions,
                        selectedOption: $financialGoal,
                        nextAction: { currentStep = 2 }
                    )
                    .tag(1)
                    
                    // Шаг 2 - Сумма для цели
                    QuestionView(
                        question: "Какую сумму вы хотите накопить?",
                        input: $goalAmount,
                        isNumberInput: true,
                        nextAction: { currentStep = 3 }
                    )
                    .tag(2)
                    
                    // Шаг 3 - Срок для цели
                    QuestionView(
                        question: "За сколько месяцев вы хотите достичь цели?",
                        input: $goalTime,
                        isNumberInput: true,
                        nextAction: { currentStep = 4 }
                    )
                    .tag(3)
                    
                    // Шаг 4 - Кредиты
                    QuestionView(
                        question: "Имеете ли вы кредиты/ипотеку?",
                        isBooleanQuestion: true,
                        booleanValue: $hasLoans,
                        nextAction: { currentStep = hasLoans ? 5 : 6 }
                    )
                    .tag(4)
                    
                    // Шаг 5 - Сумма кредитов (если есть)
                    QuestionView(
                        question: "Какой у вас ежемесячный платеж по кредитам?",
                        input: $loanAmount,
                        isNumberInput: true,
                        nextAction: { currentStep = 6 }
                    )
                    .tag(5)
                    
                    // Шаг 6 - Подушка безопасности
                    QuestionView(
                        question: "Есть ли у вас финансовая подушка безопасности?",
                        isBooleanQuestion: true,
                        booleanValue: $hasSaving,
                        nextAction: { currentStep = hasSaving ? 7 : 8 }
                    )
                    .tag(6)
                    
                    // Шаг 7 - Срок подушки (если есть)
                    QuestionView(
                        question: "На сколько месяцев жизни её хватит?",
                        input: $cushionMonths,
                        isNumberInput: true,
                        nextAction: { currentStep = 8 }
                    )
                    .tag(7)

                    // Шаг 8 - Доход
                    QuestionView(
                        question: "Сколько вы зарабатываете в месяц?",
                        input: $monthlyIncome,
                        isNumberInput: true,
                        nextAction: {
                            updateProfile()
                        }
                    )
                    .tag(8)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                ProgressBar(currentStep: currentStep, totalSteps: 8)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
            }
            
            if isLoading {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                
                ProgressView()
                    .scaleEffect(1.5)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
            }
        }
    }
    
    private func updateProfile() {
        guard let salary = Int(monthlyIncome),
              let goalAmountValue = Int(goalAmount),
              let goalTimeValue = Int(goalTime) else {
            errorMessage = "Пожалуйста, проверьте введенные данные"
            return
        }
        
        let cushion = hasSaving ? Int(cushionMonths) ?? 0 : 0
        
        isLoading = true
        errorMessage = nil
        
        NetworkManager.shared.updateProfile(
            salary: salary,
            cushion: cushion,
            financialGoal: financialGoal,
            financialGoalAmount: goalAmountValue,
            financialGoalMonths: goalTimeValue
        ) { result in
            isLoading = false
            
            switch result {
            case .success:
                withAnimation {
                    showMainScreen = true
                    completion()
                }
            case .failure(let error):
                errorMessage = "Ошибка сохранения: \(error.localizedDescription)"
            }
        }
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(question)
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.bottom, 20)
            
            if isBooleanQuestion {
                booleanQuestionView
            } else if let options = options {
                optionsQuestionView(options: options)
            } else {
                inputQuestionView
            }
            
            Spacer()
        }
        .padding()
    }
    
    private var booleanQuestionView: some View {
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
    }
    
    private func optionsQuestionView(options: [String]) -> some View {
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
    }
    
    private var inputQuestionView: some View {
        VStack(spacing: 20) {
            TextField(isNumberInput ? "Введите сумму" : "Введите ответ", text: $input)
                .keyboardType(isNumberInput ? .decimalPad : .default)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.bottom, 20)
            
            Button(action: {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                nextAction()
            }) {
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
