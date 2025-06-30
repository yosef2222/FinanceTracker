//
//  StatsView.swift
//  BankAIUI
//
//  Created by Gleb Korotkov on 21.06.2025.
//



import SwiftUI
import Alamofire


// Экран "Статистика"
struct FinancialPieChartView<Data: Identifiable>: View where Data: FinancialDataProtocol {
    let title: String
    let data: [Data]
    let currencySymbol: String
    @State private var selectedItem: Data.ID?
    
    var body: some View {
        VStack(spacing: 15) {
            Text(title)
                .font(.title2.bold())
            
            ZStack {
                ForEach(data) { item in
                    PieSlice(
                        startAngle: angle(for: item, isStart: true),
                        endAngle: angle(for: item, isStart: false)
                    )
                    .fill(item.color)
                    .overlay(
                        PieSlice(
                            startAngle: angle(for: item, isStart: true),
                            endAngle: angle(for: item, isStart: false)
                        )
                        .stroke(Color.white, lineWidth: 2)
                    )
                    .scaleEffect(selectedItem == item.id ? 1.05 : 1.0)
                    .animation(.spring(), value: selectedItem)
                }
            }
            .frame(width: 220, height: 220)
            .padding(.vertical, 10)
            
            // Общая сумма
            Text("Итого: \(formattedTotalAmount) \(currencySymbol)")
                .font(.headline)
                .padding(.bottom, 5)
            
            // Легенда с категориями
            categoriesLegend
        }
        .chartContainerStyle()
    }
    
    // MARK: - Вычисляемые свойства
    
    private var totalAmount: Double {
        data.reduce(0) { $0 + $1.value }
    }
    
    private var formattedTotalAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: totalAmount)) ?? ""
    }
    
    // MARK: - Компоненты
    
    private var categoriesLegend: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(data) { item in
                categoryRow(for: item)
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func categoryRow(for item: Data) -> some View {
        HStack {
            // Цветной круг категории
            Circle()
                .fill(item.color)
                .frame(width: 16, height: 16)
            
            // Название категории
            Text(item.name)
                .font(.subheadline)
                .frame(width: 75, alignment: .leading)
            
            Spacer()
            
            // Сумма
            Text("\(formattedValue(item.value)) \(currencySymbol)")
                .font(.subheadline.bold())
            
            // Процент
            Text("(\(percentage(for: item))%)")
                .font(.caption)
                .foregroundColor(.gray)
                .frame(width: 50)
        }
        .categoryRowStyle(isSelected: selectedItem == item.id)
        .onTapGesture {
            withAnimation {
                selectedItem = selectedItem == item.id ? nil : item.id
            }
        }
    }
    
    // MARK: - Вспомогательные функции
    
    private func angle(for item: Data, isStart: Bool) -> Angle {
        let itemsBefore = data.prefix { $0.id != item.id }
        let sumBefore = itemsBefore.reduce(0) { $0 + $1.value }
        let sum = isStart ? sumBefore : sumBefore + item.value
        return .degrees(sum / totalAmount * 360 - 90)
    }
    
    private func percentage(for item: Data) -> String {
        String(format: "%.1f", item.value / totalAmount * 100)
    }
    
    private func formattedValue(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = value.truncatingRemainder(dividingBy: 1) == 0 ? 0 : 2
        return formatter.string(from: NSNumber(value: value)) ?? ""
    }
}

// MARK: - Протокол для финансовых данных
protocol FinancialDataProtocol: Identifiable {
    var id: UUID { get }
    var name: String { get }
    var value: Double { get }
    var color: Color { get }
}

// MARK: - Примеры моделей данных

// Для расходов
struct ExpenseItem: FinancialDataProtocol {
    let id = UUID()
    let name: String
    let value: Double
    let color: Color
}

// Для доходов
struct IncomeItem: FinancialDataProtocol {
    let id = UUID()
    let name: String
    let value: Double
    let color: Color
}

// Для кредитов
struct DebtItem: FinancialDataProtocol {
    let id = UUID()
    let name: String
    let value: Double // Остаток к оплате
    let color: Color
}

// MARK: - Пример использования

struct StatsView: View {
    @State private var expenses: [ExpenseItem] = []
    @State private var adviceText: String = ""
    @State private var isLoadingExpenses: Bool = false
    @State private var isLoadingAdvice: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    // Добавим временные данные для отладки
    let debugExpenses = [
        ExpenseItem(name: "Еда", value: 2500, color: .blueStats1),
        ExpenseItem(name: "Транспорт", value: 1500, color: .blueStats2),
        ExpenseItem(name: "Жилье", value: 4000, color: .blueStats3)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 1. Секция с диаграммой расходов
                    if expenses.isEmpty {
                        if isLoadingExpenses {
                            ProgressView()
                                .frame(height: 200)
                        } else {
                            VStack {
                                Text("Нет данных о расходах")
                                    .foregroundColor(.gray)
                                // Отображение тестовых данных для проверки
                                FinancialPieChartView(
                                    title: "Тестовые данные",
                                    data: debugExpenses,
                                    currencySymbol: "₽"
                                )
                            }
                        }
                    } else {
                        FinancialPieChartView(
                            title: "Ваши расходы",
                            data: expenses,
                            currencySymbol: "₽"
                        )
                    }
                    
                    // 2. Кнопка "Дать Совет"
                    Button(action: {
                        fetchAdvice()
                    }) {
                        if isLoadingAdvice {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Дать Совет")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .disabled(isLoadingAdvice)
                    
                    // 3. Поле для отображения совета
                    TextEditor(text: $adviceText)
                        .frame(minHeight: 200)
                        .disabled(true)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .padding(.horizontal)
                        .background(Color(.systemBackground))
                }
                .padding()
            }
            .navigationTitle("Статистика")
            .alert("Ошибка", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                loadExpenses()
            }
        }
    }
    
    private func loadExpenses() {
        isLoadingExpenses = true
        print("Начало загрузки расходов...")
        
        NetworkManager.shared.getExpensesByCategory { result in
            DispatchQueue.main.async {
                isLoadingExpenses = false
                
                switch result {
                case .success(let loadedExpenses):
                    print("Успешно загружено категорий: \(loadedExpenses.count)")
                    loadedExpenses.forEach { print("Категория: \($0.name), Сумма: \($0.value)") }
                    
                    if loadedExpenses.isEmpty {
                        print("Получен пустой массив расходов")
                        self.errorMessage = "Нет данных о расходах"
                        self.showError = true
                    } else {
                        self.expenses = loadedExpenses
                    }
                    
                case .failure(let error):
                    print("Ошибка загрузки: \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                    
                    // Для отладки покажем тестовые данные при ошибке
                    self.expenses = debugExpenses
                }
            }
        }
    }
    
    private func fetchAdvice() {
        isLoadingAdvice = true
        adviceText = ""
        print("Запрос совета...")
        
        guard let token = NetworkManager.shared.getToken() else {
            errorMessage = "Необходимо авторизоваться"
            showError = true
            isLoadingAdvice = false
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "accept": "*/*"
        ]
        
        AF.request("http://localhost:5163/api/ai/advice",
                  method: .get,
                  headers: headers)
        .validate()
        .responseDecodable(of: AdviceResponse.self) { response in
            DispatchQueue.main.async {
                isLoadingAdvice = false
                
                switch response.result {
                case .success(let adviceResponse):
                    print("Совет получен успешно")
                    adviceText = adviceResponse.advice
                    
                case .failure(let error):
                    print("Ошибка получения совета: \(error.localizedDescription)")
                    
                    // Для отладки - тестовый совет
                    adviceText = """
                    Пример совета:
                    1. Сократите расходы на транспорт
                    2. Оптимизируйте траты на еду
                    3. Создайте резервный фонд
                    """
                    
                    errorMessage = "Не удалось загрузить совет: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
}

struct AdviceResponse: Decodable {
    let advice: String
}


// MARK: - Модификаторы для стилей
extension View {
    /// Стиль контейнера для диаграммы
    func chartContainerStyle() -> some View {
        self
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(15)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            .padding(.horizontal)
    }
    
    /// Стиль строки категории
    func categoryRowStyle(isSelected: Bool) -> some View {
        self
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(isSelected ? Color.gray.opacity(0.15) : Color.clear)
            .cornerRadius(8)
    }
    
    /// Центрирование по горизонтали с возможностью указания отступов
    func centeredHorizontally(padding: CGFloat = 0) -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, padding)
    }
}

// MARK: - Вспомогательные структуры

/// Форма сегмента круговой диаграммы
struct PieSlice: Shape {
    var startAngle: Angle
    var endAngle: Angle
    var innerRadius: CGFloat = 0
    var outerRadius: CGFloat = 1
    
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let inner = radius * innerRadius
        let outer = radius * outerRadius
        
        var path = Path()
        path.move(to: center)
        path.addArc(
            center: center,
            radius: outer,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        
        if innerRadius > 0 {
            path.addLine(to: center)
            path.addArc(
                center: center,
                radius: inner,
                startAngle: endAngle,
                endAngle: startAngle,
                clockwise: true
            )
        }
        
        path.closeSubpath()
        return path
    }
}

/// Вспомогательная структура для предварительного просмотра
struct FinancialPieChart_Previews: PreviewProvider {
    static var previews: some View {
        let expenses = [
            ExpenseItem(name: "Еда", value: 2500, color: .red),
            ExpenseItem(name: "Транспорт", value: 1500, color: .blue),
            ExpenseItem(name: "Жилье", value: 4000, color: .green)
        ]
        
        let incomes = [
            IncomeItem(name: "Зарплата", value: 30000, color: Color(red: 0.2, green: 0.7, blue: 0.3)),
            IncomeItem(name: "Инвестиции", value: 5000, color: Color(red: 0.1, green: 0.4, blue: 0.8))
        ]
        
        return Group {
            StatsView()
                .preferredColorScheme(.light)
            
            StatsView()
                .preferredColorScheme(.dark)
        }
    }
}

// MARK: - Дополнительные расширения

extension Color {
    /// Инициализатор из hex-строки
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension Double {
    /// Форматирование валюты
    func formattedCurrency(symbol: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = symbol
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: self)) ?? "\(self) \(symbol)"
    }
}
